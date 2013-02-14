---
layout: post
title: "DIY PaaS - staging an app"
description: "In this article I introduce the core piece of Cloud Foundry that knows the difference between a Ruby on Rails application and a Java Play application, and more importantly, how to prepare and run those applications: The Stager."
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
sliders:
- title: "The Stager"
  text: "Exploration of the bare minimum of Cloud Foundry required to run it on your laptop"
  image: /assets/images/cloudfoundry-235w.png
- title: "Staging apps"
  text: "Cloud Foundry takes your application and 'stages' it before distributing to DEAs for deployment. Let's look at what is going on."
  image: /assets/images/cloudfoundry-235w.png
slider_background: sky-horizon
published: false
publish_date: "2013-02-14"
category: "articles"
tags: [diy-paas, cloudfoundry]
theme:
  name: smart-business-template
---
{% include JB/setup %}

Perhaps the best way to feel confident using Cloud Foundry is to know how it works. And perhaps the best way to learn how it works is to rebuilt it from the ground up. In the [DIY PaaS](/tags.html#diy-paas-ref) articles, we will re-build Cloud Foundry from the ground up piece-by-piece. This is article number 2, and we're going to take a specific application, stage it into a generic droplet, and run it.

## TL;DR

At the core of Cloud Foundry, or your own DIY PaaS, is a way to run arbitrary applications - Ruby, Java, PHP. The DEA, which actually runs applications, doesn't know anything about types of applications. Something else needs to create the droplets for the DEAs which know about Ruby language and about Ruby on Rails framework, for example.

It's a stager that creates droplets.

## Skip the tutorial, just run something quickly for me!

You're busy. You want to see something shiny. Here, run this and you'll see a Stager and a DEA running, and being told to stage and then run a Ruby/Sinatra application via a message bus:

{% highlight bash %}
cd /tmp
git clone https://github.com/StarkAndWayne/staging-apps-in-cloudfoundry.git
cd staging-apps-in-cloudfoundry
git submodule update --init
./bin/bundle
foreman start

# in another terminal
bin/request_stager_to_stage_app
...
[2013-02-14 11:25:28] Setting up temporary directories
[2013-02-14 11:25:28] Downloading application
[2013-02-14 11:25:28] Unpacking application
[2013-02-14 11:25:28] Staging application
[2013-02-14 11:25:29] # Logfile created on 2013-02-14 11:25:29 -0800 by logger.rb/31641
[2013-02-14 11:25:29] Auto-reconfiguration disabled because app does not use Bundler.
[2013-02-14 11:25:29] Please provide a Gemfile.lock to use auto-reconfiguration.
[2013-02-14 11:25:29] Creating droplet
[2013-02-14 11:25:29] Uploading droplet
[2013-02-14 11:25:31] Done!
{% endhighlight %}

Now, if you'd like to learn more about what just happened, then let's get started!

## Preparation

Everything in this tutorial can be done on your local computer. The wonders of cloud computing are for another day. I already have Ruby 1.9.3 installed on my laptop and available in my `$PATH`.

As I go along, I'll clone/submodule the Cloud Foundry repositories that I need and show the bare minimum configuration files. The final product is available in a [git repository](https://github.com/StarkAndWayne/deploying-to-a-cloudfoundry-dea) as a demonstration of the minimum parts of Cloud Foundry required to run an application.

## Feeding the DEA with droplets

Each time you "add an instance" [(1)](#footer-add-instances) of a running application, the DEA takes a packaged version of an application (a droplet), unpacks it, and runs a single `startup` script. The DEA knows nothing about Ruby or Java or PHP; it only knows about the `startup` script within the package. How does the package get created?

The package that includes an executable `startup` script and the original application is known to the DEA as a "droplet". It is created during a staging step. It is the staging step that knows about Ruby and Java and PHP applications and how to run them. This article investigates how Cloud Foundry stages an application and creates the package for DEAs.

The stager is nicely isolated from the rest of Cloud Foundry. Its only external dependencies are:

* NATS server
* HTTP endpoint for getting a zipped version of the application
* HTTP endpoint for posting the droplet package

As I go along, I'll reference the projects/repositories that I need and show configuration files and helper scripts.

## Creating a droplet

The heart of the staging code is in [vcap-staging](https://github.com/cloudfoundry/vcap-staging)

The goal of `vcap-staging` is to create a new folder structure that contains:

* the user's application (in `app` dirctory)
* `startup` & `stop` scripts for the runtime/framework of the application
* `logs` dirctory for the application's `STDOUT` & `STDERR` logs
* `tmp` dirctory for... temporary things; its the `$TMPDIR` for the application

To stage a specific application framework you choose a `StagingPlugin` subclass, initialize it and invoke `#stage_application`.

For example, I can stage an example sinatra application (in [apps/sinatra](https://github.com/StarkAndWayne/staging-apps-in-cloudfoundry/tree/master/apps/sinatra))

{% highlight ruby %}
staging_plugin_class = StagingPlugin.load_plugin_for("sinatra")
staging_plugin = staging_plugin_class.from_file(cfg_filename)
staging_plugin.stage_application # requires $PLATFORM_CONFIG
{% endhighlight %}

There are two prerequisites for the code above: the `cfg_filename` YAML file and another YAML file located at `$PLATFORM_CONFIG`.

An example config file for `$PLATFORM_CONFIG` is:

{% highlight yaml %}
---
cache: /tmp/staging-apps-in-cloudfoundry/.vcap_gems
insight_agent: /var/vcap/packages/insight_agent/insight-agent.zip
{% endhighlight %}

An example config file (for `cfg_filename`) is:

{% highlight yaml %}
source_dir: 'apps/sinatra/app'
dest_dir: '/tmp/staging-apps-in-cloudfoundry/staging/sinatra'
environment:
  services: []
  framework_info:
    name: sinatra
    runtimes:
      - ruby18:
          default: true
      - ruby19:
          default: false
    detection:
      - "*.rb": "\\s*require[\\s\\(]*['\"]sinatra(/base)?['\"]" # .rb files in the root dir containing a require?
      - config/environment.rb: false # and config/environment.rb must not exist
  runtime_info:
    name: 'ruby19'
    executable: 'ruby'
    version: '1.9.3'
  resources:
    memory: 256
    disk: 256
    fds: 1024
{% endhighlight %}

The resulting `startup` script is for our Sintra application is:

{% highlight bash %}
#!/bin/bash
export RACK_ENV="${RACK_ENV:-production}"
export RUBYOPT="-rubygems -I$PWD/ruby -rstdsync"
export TMPDIR="$PWD/tmp"
mkdir ruby
echo "\$stdout.sync = true" >> ./ruby/stdsync.rb
cd app
%VCAP_LOCAL_RUNTIME% app.rb $@ > ../logs/stdout.log 2> ../logs/stderr.log &
STARTED=$!
echo "$STARTED" >> ../run.pid
wait $STARTED
{% endhighlight %}

What is `%VCAP_LOCAL_RUNTIME%`?

This token is replaced by the DEA when it unpacks the staged package to use the runtime selected for the application. In this example, this might be the ruby executable for either the `ruby18` or `ruby19` runtimes.

## Staging as a service

This staging code is not run within the DEA, nor is it run within the public API (called the Cloud Controller). It is its own service within a running Cloud Foundry installation.

We can fetch the Cloud Foundry [stager service source code](https://github.com/cloudfoundry/stager):

{% highlight bash %}
git clone git://github.com/cloudfoundry/stager.git
cd stager
bundle
cd ..
{% endhighlight %}

It is `stager` (distributed also as a rubygem `vcap_stager`) that uses the `StagingPlugin` library demonstrated above.

Like the DEA, the stager uses NATS to communicate. So let's start `nats-server` and our stager.

{% highlight bash %}
$ nats-server &
$ env BUNDLE_GEMFILE=./stager/Gemfile ./stager/bin/stager -c config/stager.yml
["Starting nats-server version 0.4.28 on port 4222"]
[2012-11-13 17:08:57.317744] vcap.stager.server INFO -- Subscribed to staging
[2012-11-13 17:08:57.319005] vcap.stager.server INFO -- Server running
{% endhighlight %}

What is `config/stager.yml`?

{% highlight yaml %}
---
logging:
  level: debug2
pid_filename: /tmp/staging-apps-in-cloudfoundry/stager/stager.pid
nats_uri: nats://127.0.0.1:4222
max_staging_duration: 120
max_active_tasks: 10
queues: ['staging']
secure: false
{% endhighlight %}

Above we are running one stager. You can run multiple stagers within Cloud Foundry. Each of them watches a NATS queue `staging` (configuration `queues` above) and pops the requests off into an internal thread pool (configuration `max_active_tasks` sets the thread pool size, if you're into optimizations based on the RAM & CPU of server running the stager).

That is, we can tell a stager to stage an application in preparation for deploying it to a DEA by publishing a message to NATS on a queue 'staging'.

## Talking to the Stager service

We use NATS to submit a request to a stager:

{% highlight ruby %}
request = {
  "app_id"       => app_id,
  "properties"   => properties,
  "download_uri" => dl_uri,
  "upload_uri"   => ul_hdl.upload_uri,
}

NATS.request('staging', request.to_json) do |result|
  output = JSON.parse(result)
end
{% endhighlight %}

The `properties` document is equivalent to the `cfg_filename` contents from the `vcap-staging` example above. 

See below for a fleshed out example. But first we need to look at `download_uri` and `upload_uri`.

What makes playing with the stager in isolation tricky is that you need to host the original source code via an HTTP URI (`download_uri` above). And even more tricky, you need to provide an HTTP endpoint for uploading the resulting staged package, (`upload_uri` above), which will then be used by DEAs.

In Cloud Foundry, the download/upload endpoints are in the Cloud Controller.

{% highlight ruby %}
# routes.rb
post   'staging/droplet/:id/:upload_id' => 'staging#upload_droplet', :as => :upload_droplet
get    'staging/app/:id'                => 'staging#download_app',   :as => :download_unstaged_app
{% endhighlight %}

So, for our little isolation test of the stager we need a [simple HTTP server](https://github.com/StarkAndWayne/staging-apps-in-cloudfoundry/blob/master/apps/staging_client_service/app.rb) to pretend to be the Cloud Controller.

{% highlight ruby %}
# apps/staging_client_service/app.rb
require 'sinatra'

get '/download_unstaged_app/:id' do
  puts "UNSTAGED APP BEING REQUESTED"
  p params
  unstaged_app_tgz = File.expand_path("../../sinatra-app.zip", __FILE__)
  send_file(unstaged_app_tgz)
end

post '/upload_droplet/:id/:upload_id' do
  puts "RECEIVING DROPLET"
  p params
  src_path = params[:upload][:droplet][:tempfile]
  droplet = params[:upload][:droplet][:tempfile].read
  puts "RECEIVED DROPLET: stager uploaded staged droplet #{src_path}"
end
{% endhighlight %}

Run our staging client app (our fake Cloud Controller, so to speak), in addition to the NATS server and stager application that are already running:

{% highlight bash %}
ruby apps/staging_client_service/app.rb -p 9292
{% endhighlight %}

We now have the three running pieces of the stager demonstration:

* nats-server
* stager
* fake stager client endpoints

Finally, we need a [little script](https://github.com/StarkAndWayne/staging-apps-in-cloudfoundry/blob/master/bin/request_stager_to_stage_app) to request the stager downloads a zipped application, and upload the staged version of it (called a "droplet") to our fake stager client.

{% highlight ruby %}
#!/usr/bin/env ruby

# USAGE: bin/request_stager_to_stage_app

require "nats/client"
require "json"

QUEUE = 'staging' # as agreed in config/stager.yml

app_id = "my-sinatra-app"
stager_client = "http://localhost:9292"
upload_id = "upload_id"

NATS.start do
  NATS.subscribe('>') { |msg, reply, sub| puts "Msg received on [#{sub}] : '#{msg}'" }

  staging_request = {
    app_id: app_id,
    download_uri: "#{stager_client}/download_unstaged_app/#{app_id}",
    upload_uri: "#{stager_client}/upload_droplet/#{app_id}/#{upload_id}",

    # properties == 'environment' from config/stage-sinatra.yml
    properties: { 
      services: [],
      framework_info: {
        name: "sinatra",
        ...
      },
      runtime_info: {
        name: 'ruby19',
        executable: 'ruby',
        version: '1.9.3'
      },
      resources: {
        memory: 256,
        disk: 256,
        fds: 1024
      }
    }
  }

  NATS.request(QUEUE, staging_request.to_json) do |result|
    output = JSON.parse(result)
    puts output["task_log"]
    NATS.stop
  end
end
{% endhighlight %}

It is the `staging_request` that tells the stager:

* where to download a zipfile containing the application to be staged (`download_uri`)
* where to upload the staged application, called a droplet
* application details, such as framework (rails, lift, etc)

When we run our script it returns the task log from the stager, to tell us how the staging process went and to confirm that the droplet has been uploaded to where we told the stager to upload it.

{% highlight bash %}
$ ./bin/request_stager_to_stage_app
...
[2012-11-13 22:13:08] Setting up temporary directories
[2012-11-13 22:13:08] Downloading application
[2012-11-13 22:13:08] Unpacking application
[2012-11-13 22:13:08] Staging application
[2012-11-13 22:13:10] # Logfile created on 2012-11-13 22:13:10 -0800 by logger.rb/31641
[2012-11-13 22:13:10] Auto-reconfiguration disabled because app does not use Bundler.
[2012-11-13 22:13:10] Please provide a Gemfile.lock to use auto-reconfiguration.
[2012-11-13 22:13:10] Creating droplet
[2012-11-13 22:13:10] Uploading droplet
[2012-11-13 22:13:12] Done!
{% endhighlight %}

## Summary

Cloud Foundry has a standalone service, stager, that listens for requests on NATS to stage a zipped application into a droplet - a package that contains the original application together with `startup` and `stop` scripts.

The only external dependencies are:

* NATS server
* HTTP endpoint for getting a zipped version of the application
* HTTP endpoint for posting the droplet package

The stager has two main code bases:

* [stager](https://github.com/cloudfoundry/stager) - staging as a service, aka `vcap-stager` rubygem
* [vcap-staging](https://github.com/cloudfoundry/vcap-staging) - framework plugins for how to stage an application

## Next, combining the stager and the DEA

In the next [DIY PaaS](/tags.html#diy-paas-ref) article, we will take the next logical step: create a droplet and make a DEA download it and run it

Follow [@starkandwayne](https://twitter.com/starkandwayne) for the release of the next article and other blog posts from the wonderful world Cloud Foundry.

## Footnotes

<p id="footer-add-instances">(1) I don't agree with this terminology in Cloud Foundry. When you add "instances" to a running application, you are actually adding running processes. If you've used Heroku, this is akin to adding dynos. To me, "instances" means virtual machines or servers. In Cloud Foundry, it means "processes of your app". In future Cloud Foundry, it will be a Linux container running an application process.</p>

