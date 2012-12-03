---
layout: post
title: "Bare minimum Clound Foundry - provisioning services"
description: "Most applications need services: databases, message buses, and caches. In this article I look at how they work in isolation from the rest of Cloud Foundry."
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
sliders:
- title: "Provisioning Services"
  text: "Most applications need services such as databases, message buses, and caches. Let's look at how services work in Cloud Foundry in isolation."
  image: /assets/images/cloudfoundry-235w.png
slider_background: sheep # or parchment,abyss,sky-horizon-sky from /assets/sliders
publish_date: "2012-11-14"
published: false
category: "articles"
tags: []
theme:
  name: smart-business-template
---
{% include JB/setup %}

There are two primary tasks that a PaaS such as Cloud Foundry performs: to run your application code, and to bind those applications to services.

From an application's perspective, a service could be access to PostgreSQL, Redis, or RabbitMQ that runs within Cloud Foundry. Or it could be a database or message bus running outside of Cloud Foundry. Or it could be a 3rd-party hosted application, such as MongoHQ. Access to a filesystem is a service.

An application could manually configure itself to connect ("bind" in Cloud Foundry vernacular) to services. If you deploy a Rails application, your application could come with a `config/database.yml` that configures to a pre-existing (legacy!) SQL database being managed by your DBAs or a 3rd party provider.

There is also a very helpful feature of Cloud Foundry to enable provisioning and binding of services to applications. Your new application needs a new PostgreSQL database? Quickly provisioned and then quickly bound to your application.

In this article I wanted to investigate the way that very different services have a uniform way to be provisioned and bound, even though they are all different from each other.

## Gateways and Nodes

Service gateways advertise the existence of a service. That is a PostgreSQL Gateway advertises that PostgreSQL is available for applications. Service nodes perform provisioning requests. That is a PostgreSQL Node creates new databases within a running PostgreSQL for each provisioning request.

Service gateways route provisioning requests to Service Nodes.

Applications then talk directly to the Service. That is, the gateways and nodes are only for management and administration. They are not part of the implementation of each service.

## Where is the code?

The specific services that come with Cloud Foundry are implemented in [vcap-services](https://github.com/cloudfoundry/vcap-services). Each service implementation reuses a common [vcap-services-base](https://github.com/cloudfoundry/vcap-services-base) library.

{% highlight bash %}
git clone git://github.com/cloudfoundry/vcap-services.git
git clone git://github.com/cloudfoundry/vcap-services-base.git
{% endhighlight %}

## Running a Service Node

In this tutorial we will play with an example service [echo](https://github.com/cloudfoundry/vcap-services/tree/master/echo) which has a node `bin/echo_node` and gateway `bin/echo_gateway`, but there is no actual service (redis, postgresql) underneath.

We need a configuration file for our Echo Node process at `config/echo_node.yml` (which is the same as the default [echo_node.yml](https://github.com/cloudfoundry/vcap-services/blob/master/echo/config/echo_node.yml) with a different base directory locations)

{% highlight yaml %}
---
plan: free
capacity: 100
local_db: sqlite3:/tmp/provisioning-cloudfoundry-services/var/vcap/services/echo/echo_node.db
mbus: nats://localhost:4222
base_dir: /tmp/provisioning-cloudfoundry-services/var/vcap/services/echo/
index: 0
logging:
  level: debug
pid: /tmp/provisioning-cloudfoundry-services/var/vcap/sys/run/echo_node.pid
node_id: echo_node_1
port: 5002

supported_versions: ["1.0"]
default_version: "1.0"
{% endhighlight %}

To run the Echo Node, and NATS if not already running:

{% highlight bash %}
$ nats-server &
$ cd vcap-services/echo
$ bundle
$ cd ../..
$ ./vcap-services/echo/bin/echo_node -c config/echo_node.yml
{% endhighlight %}

## Provisioning Services via Service Nodes

Nodes are the part of Cloud Foundry that represent the actual services being provided. They track how much of the service is available for provisioning and they allow requests for provisioning and unprovisioning.

Each Node will respond to "SERVICE_NAME.discover" message on NATS and reply with its identifying information and its remaining capacity.

{% highlight ruby %}
NATS.request("EchoaaS.discover") do |response|
  puts "EchoaaS.discover response: #{response}"
end
{% endhighlight %}

The `response` is JSON that identifies the following:

{% highlight javascript %}
{
  "id":"echo_node_1",           // identification
  "plan":"free",                // the "plan" of the service it can offer
  "supported_versions":["1.0"]  // the underlying version of the service (for mongodb it might be "1.8")
  "available_capacity":95,      // the remaining capacity of the underlying service remaining
  "capacity_unit":1,            // how much capacity is allocated by each provisioning request
}
{% endhighlight %}


Each Node listens for events specifically for it:

{% highlight ruby %}
"SERVICE_NAME.provision.NODE_ID"
"SERVICE_NAME.unprovision.NODE_ID"
"SERVICE_NAME.bind.NODE_ID"
"SERVICE_NAME.unbind.NODE_ID"
"SERVICE_NAME.restore.NODE_ID"
"SERVICE_NAME.disable_instance.NODE_ID"
"SERVICE_NAME.enable_instance.NODE_ID"
"SERVICE_NAME.import_instance.NODE_ID"
"SERVICE_NAME.update_instance.NODE_ID"
"SERVICE_NAME.cleanupnfs_instance.NODE_ID"
"SERVICE_NAME.purge_orphan.NODE_ID"
{% endhighlight %}

To discover and provision a Service would be:

{% highlight ruby %}
NATS.request("EchoaaS.discover") do |response|
  # {"available_capacity":100,"capacity_unit":1,"id":"echo_node_1","plan":"free","supported_versions":["1.0"]}
  node = JSON.parse(response)
  node_id = node["id"] # echo_node_1
  
  provision_request = {
    plan: node["plan"]
  }
  NATS.request("EchoaaS.provision.#{node_id}", provision_request.to_json) do |response|
    # {"credentials":{"host":"192.168.1.32","port":5002,"name":"9ef703dd-0efe-432b-ba73-24cfe049b4bd","node_id":"echo_node_1"},"success":true}
    result = JSON.parse(response)
    if result["success"]
      puts "credentials: #{result['credentials'].inspect}"
    else
      puts "failed to provision: #{result.inspect}"
    end
    NATS.stop
  end
end
{% endhighlight %}


## Running a Service Gateway


Each Gateway runs an HTTP endpoint.

{% highlight ruby %}
# vcap-services-base/lib/base/asynchronous_service_gateway.rb

# Provisions an instance of the service
post "/gateway/v1/configurations" do

# Unprovisions a previously provisioned instance of the service
delete '/gateway/v1/configurations/:service_id' do

# Binds a previously provisioned instance of the service to an application
post '/gateway/v1/configurations/:service_id/handles' do

# Unbinds a previously bound instance of the service
delete '/gateway/v1/configurations/:service_id/handles/:handle_id' do

# create a snapshot
post "/gateway/v1/configurations/:service_id/snapshots" do

# Get snapshot details
get "/gateway/v1/configurations/:service_id/snapshots/:snapshot_id" do

# Update snapshot name
post "/gateway/v1/configurations/:service_id/snapshots/:snapshot_id/name" do

# Enumreate snapshot
get "/gateway/v1/configurations/:service_id/snapshots" do

# Rollback to a snapshot
put "/gateway/v1/configurations/:service_id/snapshots/:snapshot_id" do

# Delete a snapshot
delete "/gateway/v1/configurations/:service_id/snapshots/:snapshot_id" do

# Create a serialized url for a service snapshot
post "/gateway/v1/configurations/:service_id/serialized/url/snapshots/:snapshot_id" do

# Get serialized url for a service snapshot
get "/gateway/v1/configurations/:service_id/serialized/url/snapshots/:snapshot_id" do

# Import serialized data from url
put "/gateway/v1/configurations/:service_id/serialized/url" do

# Get Job details
get "/gateway/v1/configurations/:service_id/jobs/:job_id" do

# Restore an instance of the service
post '/service/internal/v1/restore' do

# Recovery an instance if node is crashed.
post '/service/internal/v1/recover' do

post '/service/internal/v1/check_orphan' do

delete '/service/internal/v1/purge_orphan' do

# Service migration API
post "/service/internal/v1/migration/:node_id/:instance_id/:action" do

get "/service/internal/v1/migration/:node_id/instances" do
{% endhighlight %}

## Adding a Service to Cloud Foundry

There is [documentation](https://github.com/cloudfoundry/oss-docs/tree/master/vcap/adding_a_system_service) available for how to add a Service into your Cloud Foundry. It covers how to modify the legacy dev_setup chef cookbooks.

I'd recommend that you be using the BOSH release [cf-release](https://github.com/cloudfoundry/cf-release) for managing your Cloud Foundry rather than chef cookbooks. There is an example repository showing how to add a service to your own cf-release repository.
