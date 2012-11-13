---
layout: post
title: "Bare minimum Cloud Foundry on local machine"
description: "Exploration of the bare minimum of Cloud Foundry required to run it on your laptop"
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
sliders:
- title: "Cloud Foundry on laptop"
  text: "Exploration of the bare minimum of Cloud Foundry required to run it on your laptop"
  image: /assets/images/cloudfoundry-235w.png
slider_background: sky-horizon-sky
publish_date: "2012-11-10"
category: "articles"
tags: []
theme:
  name: smart-business-template
---
{% include JB/setup %}

There are many parts to Cloud Foundry when its running in production. But doesn't it just run apps? If I can run those apps on my laptop already, then how much work is it to run Cloud Foundry on my laptop and deploy apps to it, that run on my laptop. I mean, how hard could it be?

I thought this might be an interesting experiment in configuring Cloud Foundry so I could understand it better.

For this article I already have Ruby 1.9.3 & PostgreSQL 9.2 installed on my laptop and available in my `$PATH`.

As I go along, I'll clone/submodule the repositories that I need and show the configuration files. The final product is available in a [git repository](https://github.com/StarkAndWayne/deploying-to-a-cloudfoundry-dea) as a demonstration of the minimium parts of Cloud Foundry required to deploy an application.

## The DEA

If I know anything about Cloud Foundry its that applications are run via a DEA.

NOTE, I am putting all folders within an initial self-contained folder so I can delete everything easily.

{% highlight bash %}
$ cd /path/to/somewhere # self-contained
$ mkdir config          # for all configuration files to come
$ mkdir -p var/dea      # for staging & running apps
$ mkdir -p var/log      # for logs
$ mkdir -p var/run      # for pid files
$ git clone git://github.com/cloudfoundry/dea.git
$ cd dea
$ bundle
$ cd ..
$ ./dea/bin/dea
Config file location not specified. Please run with --config argument or set CLOUD_FOUNDRY_CONFIG_PATH
{% endhighlight %}

Ahh, introduction to running Cloud Foundry lesson 1 - YAML configuration files. Lots of YAML configuration files.

Ignore the out-of-date [example dea config file](https://github.com/cloudfoundry/dea/blob/master/config/example.yml), and look at the [dea.yml.erb](https://github.com/cloudfoundry/cf-release/blob/master/jobs/dea/templates/dea.yml.erb) from Cloud Foundry's own cf-release BOSH release. I used `config/dea-laptop.yaml` as below.

{% highlight yaml %}
---
# Base directory where all applications are staged and hosted
base_dir: /path/to/somewhere/var/dea
pid: /path/to/somewhere/var/run/dea.pid

runtimes:
  - ruby19

max_memory: 1024

# Optional as of http://reviews.cloudfoundry.org/11316
logging:
  level: debug

{% endhighlight %}

Running `dea` again whilst using this configuration file is a lot more successful!

{% highlight bash %}
$ ./dea/bin/dea -c config/dea-laptop.yml
Starting VCAP DEA (0.99)
Pid file: /path/to/somewhere/var/run/dea.pid
Using ruby @ /Users/drnic/.rvm/rubies/ruby-1.9.3-p286/bin/ruby
Using network: 192.168.1.70
Socket Limit:256
Max Memory set to 4.0G
Utilizing 1 cpu cores
Restricting to single tenant
Using directory: /path/to/somewhere/var/dea/
Initial usage of droplet fs is: 0%
File service started on port: 
EXITING! NATS error: Could not connect to server on nats://localhost:4222
{% endhighlight %}

And we move on to the next piece of Cloud Foundry... NATS!

## NATS

NATS is a simple pub-sub messaging system used by Cloud Foundry for communication between services. For example the DEA wouldn't even start unless it could find NATS.

By default, the DEA looks for a NATS server on http://localhost:4222. Coincidentally, when we run the nats-server (below) it starts up on port 4222.

{% highlight bash %}
$ git clone git://github.com/derekcollison/nats.git
$ cd nats
$ bundle
$ cd ..
$ ./nats/bin/nats-server -d
["Starting nats-server version 0.4.28 on port 4222"]
["Switching to daemon mode"]
{% endhighlight %}

Now when we re-run the DEA it runs successfully in the foreground, listening to NATS for instructions.

{% highlight bash %}
$ ./dea/bin/dea -c config/dea-laptop.yml
...
Initial usage of droplet fs is: 0%
File service started on port:
{% endhighlight %}

When a DEA is launched it automatically joins the Cloud Foundry environment that it belongs to. The way it identifies itself is via NATS. When any part of Cloud Foundry launches, including each DEA, it publishes a `vcap.component.announce` message.

To see the NATS messages published by our DEA, add the following executable script at `bin/nats_all`

{% highlight ruby %}
#!/usr/bin/env ruby

require "nats/client"

NATS.start do
  NATS.subscribe('>') { |msg, reply, sub| puts "Msg received on [#{sub}] : '#{msg}'" }
end
{% endhighlight %}

In a new terminal, run this script. In another terminal, kill the DEA and restart it (Ctrl+C to kill it). The following output appears in the `nats_all` terminal.

{% highlight bash %}
$ ruby bin/nats_all
Msg received on [vcap.component.announce] : 
'{"type":"DEA","index":null,"uuid":"UUID","host":"192.168.1.70:62556",
"credentials":["USERNAME","PASSWORD"],"start":"2012-11-10 23:16:11 -0800"}'
Msg received on [dea.start] : 
'{"id":"UUID","ip":"192.168.1.70","port":null,"version":0.99}'
Msg received on [dea.advertise] : 
'{"id":"UUID","available_memory":4096,"runtimes":["ruby19"],"prod":null}'
Msg received on [dea.advertise] : 
'{"id":"UUID","available_memory":4096,"runtimes":["ruby19"],"prod":null}'
{% endhighlight %}

On the first message, `vcap.component.announce`, the DEA published its host (`192.168.1.70:62556`) and username/password credentials.

The last lines are the constant status announcement that the DEA publishes to inform Cloud Foundry that it is still available to deploy more applications; with 4G of RAM still available (the default amount).

All Cloud Foundry components can be polled for their health `/healthz` and their configuration data `/varz`.

{% highlight bash %}
$ curl http://USERNAME:PASSWORD@192.168.1.70:62556/healthz
ok

$ curl http://USERNAME:PASSWORD@192.168.1.70:62556/varz
{
  "type": "DEA",
  ...
  "running_apps": [

  ],
  "frameworks": {

  },
  "runtimes": {

  },
  "uptime": "0d:0h:0m:0s",
  "mem": 69056,
  "cpu": 96.4
}
{% endhighlight %}

Our DEA thinks it has no runtimes for running applications (such as Ruby or Java), and no frameworks (such as Ruby on Rails, Sinatra or Play). So we'll need to fix that before we can deploy an application.

But first, we need to discover a DEA to be able to talk to it; and second we need to  deploy an application into the DEA. WE do both via NATS client calls.

## Discovering a DEA

Each DEA listens (subscribes) for [various messages](https://github.com/cloudfoundry/dea/blob/master/lib/dea/agent.rb#L267-276) on NATS.

A useful little script to discover all the available DEAs (on a NATS server) is below. It is in the tutorial repository at [bin/dea_discover](https://github.com/StarkAndWayne/deploying-to-a-cloudfoundry-dea/blob/master/bin/dea_discover).

It broadcasts a NATS message `dea.discover` and waits for a reply.

{% highlight ruby %}
#!/usr/bin/env ruby

require "nats/client"
require "json"

NATS.start do
  NATS.subscribe('>') { |msg, reply, sub| puts "Msg received on [#{sub}] : '#{msg}'" }
  message = {
    'runtime_info' => {
      'name' => 'ruby19',
      'executable' => 'ruby',
      'version_output' => 'ruby 1.9.3p286'
    },
    'limits' => {
      'mem' => 256
    },
    'droplet' => 'DROPLET_ID_1234'
  }
  NATS.request('dea.discover', message.to_json) do |response|
    puts "Got dea.discover response: #{response}"
  end
end
{% endhighlight %}

Since NATS is independent of Ruby, you could also discover DEAs using the following Node.js script ([bin/discover_dea.js](https://github.com/StarkAndWayne/deploying-to-a-cloudfoundry-dea/blob/master/bin/dea_discover.js))

{% highlight javascript %}
var nats = require('nats').connect();

// Simple Subscriber
nats.subscribe('>', function(msg, reply, subject) {
  console.log('Msg received on [' + subject + '] : ' + msg);
});

var message = {
  'runtime_info': {
    'name': 'ruby19',
    'executable': 'ruby',
    'version_output': 'ruby 1.9.3p286'
  },
  'limits': {
    'mem': 256
  },
  'droplet': 'DROPLET_ID_1234'
};
nats.request('dea.discover', JSON.stringify(message), function(response) {
  console.log("Got dea.discover response: " + response);
});
{% endhighlight %}

The output from both includes the response from our one DEA.

{% highlight plain %}
Got dea.discover response: {"id":"56a44db58ce330df22426c01b3c66b6c","ip":"192.168.1.70","port":null,"version":0.99}
{% endhighlight %}

This `response` includes the UUID for each DEA in the `id` key. We now use this UUID to tell that DEA to run an application.

## Using NATS to deploy to a DEA

An example script for deploying a local application is at [bin/start_app](https://github.com/StarkAndWayne/deploying-to-a-cloudfoundry-dea/blob/master/bin/start_app). This section introduces that script.

To tell a DEA to deploy an application, you publish a NATS message that contains its UUID, `dea.UUID.start`. In a full Cloud Foundry, it is the Cloud Controller that publishes this message. The Cloud Controller is the public API for user requests - deploy new apps, update existing apps, and scaling existing apps. The bulk of the `dea.UUID.start` message is created in [AppManager#new_message](https://github.com/cloudfoundry/cloud_controller/blob/master/cloud_controller/app/models/app_manager.rb#L369-385).

An example `dea.UUID.start` JSON/Ruby message for deploying a Ruby/Sinatra application could be:

{% highlight ruby %}
dea_app_start = {
  droplet: droplet_id,
  index: 0,
  services: [],
  version: '1-1',
  sha1: sha1,
  executableFile: '???',
  executableUri: "/staged_droplets/#{droplet_id}/#{sha1}",
  name: app_name,
  uris: ["#{app_name}.vcap.me"],
  env: [],
  users: ['drnicwilliams@gmail.com'],
  runtime_info: {
    name: 'ruby19',
    executable: 'ruby',
    version_output: 'ruby 1.9.3p286'
  },
  framework: 'sinatra',
  running: 'ruby19',
  limits: { mem: 256 },
  cc_partition: 'default'
}
{% endhighlight %}

More interesting is to put this together with a sequence of NATS requests to discover a DEA, tell it to deploy an application, and watch for its internal `host:port` being announced.

We first request `dea.discover` and when a DEA responds we the `dea.UUID.start` message which only that DEA subscribes. We watch for `router.register` messages to discover what `host:port` the application is running on.

{% highlight ruby %}
#!/usr/bin/env ruby

require "nats/client"
require "json"
...
# see bin/start_app for creating local tarball
...

NATS.start do
  NATS.subscribe('>') { |msg, reply, sub| puts "Msg received on [#{sub}] : '#{msg}'" }

  dea_discover = {
    # from above
  }
  NATS.request('dea.discover', dea_discover.to_json) do |response|
    dea_uuid = JSON.parse(response)['id']
    
    dea_app_start = {
      # see example above
    }

    # after "dea.UUID.start" below, wait for host:port to be announced
    NATS.subscribe("router.register") do |msg|
      new_app = JSON.parse(msg)
      host, port = new_app["host"], new_app["port"]
      puts "New app registered at: http://#{host}:#{port}"
      NATS.stop
    end

    # Request deployment
    NATS.publish("dea.#{dea_uuid}.start", dea_app_start.to_json)
  end
end
{% endhighlight %}

An example output of this script would be:

{% highlight bash %}
$ ./bin/start_app sinatra
...
New app registered at: http://192.168.1.70:54186
{% endhighlight %}

Now, the application that [bin/start_app](https://github.com/StarkAndWayne/deploying-to-a-cloudfoundry-dea/blob/master/bin/start_app) deploys is a Sinatra application. But its not _just_ a Sinatra application, it is a specially "staged" application that is ready for the DEA.

What isn't clear in the `bin/start_app` script is how the DEA knows how to run a Ruby/Sinatra application.

The short answer is it doesn't. The DEA knows nothing about Ruby or Java or PHP.

I'll try to write up the "staging" concept of Cloud Foundry, as implemented in [vcap-staging](https://github.com/cloudfoundry/vcap-staging). It is `vcap-staging` that knows how to launch a Ruby on Rails or Sinatra application on Ruby, not the DEA.

So when the DEA deploys an application, that application must be prepared in advance.

The DEA has three basic steps to deploy an application:

* get a tarball (tgz) from a local cache, shared cache or via remote HTTP
* unpack the tarball
* run `./startup`

In Cloud Foundry, `vcap-staging` creates the executable `startup` script specific to the type of application being deployed. That is, if you want to add a new programming language or a new framework, your first stop is `vcap-staging`.

In this tutorial, I have pre-staged the Sinatra application and the `start_app` script copies it from its location and runs `./startup`.

The staged Sinatra application is at [apps/sinatra](https://github.com/StarkAndWayne/deploying-to-a-cloudfoundry-dea/tree/master/apps/sinatra) and includes the [startup script](https://github.com/StarkAndWayne/deploying-to-a-cloudfoundry-dea/blob/master/apps/sinatra/startup) that vcap-staging would have generated for a simple Sinatra application that doesn't use bundler.

## Summary

Deploying an application to a DEA has a few simple requirements.

* Run a NATS server
* Run a DEA using a simple YAML configuration
* Create a `startup` script and a copy of your application together in a folder
* Publish NATS message `dea.DEA_UUID.start` to tell the application to deploy the application from its local cached/pre-staged version (or a remote tar)

Its not as simple as perhaps it could be; but it is relatively understandable as to how the pieces fit together. You use NATS to find and communicate with a DEA. You tell it what tarball to use to unpack and run via a `startup` script. Pretty simple.
