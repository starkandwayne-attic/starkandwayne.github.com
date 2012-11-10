---
layout: post
title: "Getting to know the Cloud Controller in Cloud Foundry"
description: |
  Users interact with Cloud Foundry via the Cloud Controller. This article
  gives an overview of how it works and how to configure it.
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
sliders:
- title: "Learn the Cloud Controller"
  text: |
    Users interact with Cloud Foundry via the Cloud Controller. This article
    gives an overview of how it works and how to configure it.
  image: /assets/images/cloudfoundry-235w.png
- title: "Configure the Cloud Controller"
  text: |
    YAML and more YAML. Let's look at what makes up the configuration
    of the Cloud Controll.er
  image: /assets/images/cloudfoundry-235w.png
slider_background: sky-horizon
publish_date: "2012-12-10"
category: "articles"
tags: [cloudfoundry]
theme:
  name: smart-business-template
---
{% include JB/setup %}

Users interact with Cloud Foundry via the Cloud Controller. This article
gives an overview of how it works and how to configure it.

This article only discusses the current stable [cloud_controller](https://github.com/cloudfoundry/cloud_controller), not the up-coming replacement [cloud_controller_ng](https://github.com/cloudfoundry/cloud_controller_ng).

## Overview


## Code dive!

Start with fetching the source code and viewing the API routes.

{% highlight bash %}
$ gerrit clone ssh://$(whoami)@reviews.cloudfoundry.org:29418/cloud_controller
or
$ git clone git://github.com/cloudfoundry/cloud_controller.git
$ cd cloud_controller/cloud_controller
$ bundle
$ rake db:migrate
No path to CLOUD_CONTROLLER_CONFIG supplied.  Using default properties.
...
$ rake routes | grep GET
No path to CLOUD_CONTROLLER_CONFIG supplied.  Using default properties.
   cloud_info GET    /info(.:format)   {:action=>"info", :controller=>"default"}
   list_users GET    /users(.:format)  {:action=>"list", :controller=>"users"}
    user_info GET    /users/*email     {:controller=>"users", :action=>"info"}
    list_apps GET    /apps(.:format)   {:action=>"list", :controller=>"apps"}
...
{% endhighlight %}

## Running the Cloud Controller

The Cloud Controller is a Ruby on Rails application, and as such you could try running it as you would run any other Rails app. The Cloud Foundry convention is to provide an executable to run instead.

```
$ bin/cloud_controller -c /path/to/config/cloud_controller.yml -p 5000
```

It requires two flags - the all encompassing configuration file (see below) and the port.

The Cloud Controller is run behind the [thin web server](http://code.macournoyer.com/thin/).

This script's primary task is to ensure that `$CLOUD_CONTROLLER_CONFIG` is setup before loading the Rails app. 

## Configuring Cloud Controller

The Cloud Controller expects a single configuration file. As shown above it displays a warning if `$CLOUD_CONTROLLER_CONFIG` environment variable is not provided.

Conversely, this Ruby on Rails app does not use any other traditional configuration files such as `database.yml`.

In the BOSH [cf-release](https://github.com/cloudfoundry/cf-release), this configuration file is the [cloud_controller.yml.erb](https://github.com/cloudfoundry/cf-release/blob/master/jobs/cloud_controller/templates/cloud_controller.yml.erb) template. But that file is very unreadable to me as an example.

If no configuration file is provided via `$CLOUD_CONTROLLER_CONFIG` the [configuration used](https://github.com/cloudfoundry/cloud_controller/blob/master/cloud_controller/config/appconfig.rb#L26-46) looks like:

{% highlight yaml %}
---
:database_environment:
  :test:
    :adapter: sqlite3
    :database: db/test.sqlite3
    :encoding: utf8
  :development:
    :adapter: sqlite3
    :database: db/cloudcontroller.sqlite3
    :encoding: utf8
:allow_registration: true
:builtin_services:
  :mysql:
    :token: '0xdeadbeef'
  :postgresql:
    :token: '0xdeadbeef'
  :redis:
    :token: '0xdeadbeef'
  :mongodb:
    :token: '0xdeadbeef'
  :rabbitmq:
    :token: '0xdeadbeef'
  :neo4j:
    :token: '0xdeadbeef'
  :atmos:
    :token: '0xdeadbeef'
  :filesystem:
    :token: '0xdeadbeef'
  :vblob:
    :token: '0xdeadbeef'
:service_lifecycle:
  :max_upload_size: 1
  :upload_token: dlfoosecret
  :upload_timeout: 60
  :serialization_data_server:
  - 127.0.0.1:8080
:directories:
  :droplets: /var/vcap/shared/droplets
  :resources: /var/vcap/shared/resources
  :tmpdir: /var/vcap/data/cloud_controller/tmp
  :staging_manifests: /Users/drnic/Projects/gems/cloudfoundry/cloud_controller/cloud_controller/spec/support/manifests
:runtimes_file: /Users/drnic/Projects/gems/cloudfoundry/cloud_controller/cloud_controller/spec/support/runtimes.yml
:defaulted:
- :external_uri
- :description
- :support_address
- :rails_environment
- :local_route
- :allow_external_app_uris
- :staging
- :external_port
- :directories
- :mbus
- :logging
- :keys
- :pid
- :admins
- :https_required
- :https_required_for_admins
- :default_account_capacity
- :uaa
:external_uri: api.vcap.me
:description: VMware's Cloud Application Platform
:support_address: http://support.cloudfoundry.com
:rails_environment: development
:local_route: 127.0.0.1
:allow_external_app_uris: false
:staging:
  :max_staging_runtime: 60
  :queue: staging
:external_port: 9022
:mbus: nats://localhost:4222/
:logging:
  :level: debug
:keys:
  :password: da39a3ee5e6b4b0d3255bfef95601890afd80709
  :token: default_key
:pid: /var/vcap/sys/run/cloudcontroller.pid
:admins: []
:https_required: false
:https_required_for_admins: false
:default_account_capacity:
  :memory: 2048
  :app_uris: 4
  :services: 16
  :apps: 20
:uaa:
  :enabled: 'true'
  :url: http://uaa.vcap.me
  :resource_id: cloud_controller
  :token_secret: tokensecret
  :client_secret: cloudcontrollerclientsecret
:new_initial_placement: false
:cc_partition: default
:bulk_api:
  :auth:
    :user: bulk_api
    :password: !binary |-
      NTQyZTQyY2Q5M2U0MDkwZjAxMTU3MzI3OWQ2ZGM2YWE=
:app_uris:
  :allow_external: false
  :reserved_list: []
:max_droplet_size: 536870912
{% endhighlight %}


## Pending

This article is pending the following patches to Cloud Foundry repositories

* [Bump em-hiredis/hiredis](http://reviews.cloudfoundry.org/11306 "Gerrit Code Review")
