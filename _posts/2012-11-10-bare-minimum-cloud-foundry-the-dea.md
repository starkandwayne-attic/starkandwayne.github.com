---
layout: post
title: "DIY PaaS - running apps with a DEA"
description: "Learn to create own PaaS by exploring the bare minimum of Cloud Foundry - introducing the DEA and NATS"
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
sliders:
- title: "The DEA"
  text: "Exploration of the bare minimum of Cloud Foundry required to run it on your laptop"
  image: /assets/images/cloudfoundry-235w.png
slider_background: sky-horizon-sky
published: true
publish_date: "2013-02-04"
category: "articles"
tags: [diy-paas, cloudfoundry]
theme:
  name: smart-business-template
---
{% include JB/setup %}

Perhaps the best way to feel confident using Cloud Foundry is to know how it works. And perhaps the best way to learn how it works is to rebuilt it from the ground up. In the [DIY PaaS](/tags.html#diy-paas-ref) articles, we will re-build Cloud Foundry from the ground up piece-by-piece. This is article number 1!

Everything in this tutorial can be done on your local computer. The wonders of cloud computing are for another day. I already have Ruby 1.9.3 installed on my laptop and available in my `$PATH`.

As I go along, I'll clone/submodule the Cloud Foundry repositories that I need and show the bare minimum configuration files. The final product is available in a [git repository](https://github.com/StarkAndWayne/deploying-to-a-cloudfoundry-dea) as a demonstration of the minimum parts of Cloud Foundry required to run an application.

## The DEA

If you should know anything about Cloud Foundry its that applications are run via a Droplet Execution Agent (DEA). This is a small process that runs on any server or hardware where you want to deploy applications.

A DEA is like a next-generation process manager. You tell a DEA which application to run, it then fetches that application

This tutorial is about configuring a DEA and telling it to run an application. If you can imagine the bigger picture

NOTE, I am putting all folders within an initial self-contained folder so I can delete everything easily.

{% highlight bash %}
$ mkdir -p /tmp/deploying-to-a-cloudfoundry-dea
$ cd /tmp/deploying-to-a-cloudfoundry-dea
$ mkdir config             # for all configuration files to come
$ mkdir -p var/dea         # for staging & running apps
$ mkdir -p var/log         # for logs
$ mkdir -p var/run         # for pid files
$ git clone git://github.com/cloudfoundry/dea.git
$ cd dea
$ bundle
$ cd /tmp/deploying-to-a-cloudfoundry-dea
$ ./dea/bin/dea
Config file location not specified. Please run with --config argument or set CLOUD_FOUNDRY_CONFIG_PATH
{% endhighlight %}

Ahh, introduction to running Cloud Foundry lesson 1 - YAML configuration files. Lots of YAML configuration files.

Ignore the out-of-date [example dea config file](https://github.com/cloudfoundry/dea/blob/master/config/example.yml), and look at the [dea.yml.erb](https://github.com/cloudfoundry/cf-release/blob/master/jobs/dea/templates/dea.yml.erb) from Cloud Foundry's own cf-release BOSH release. I created [config/dea-laptop.yml](https://github.com/StarkAndWayne/deploying-to-a-cloudfoundry-dea/blob/master/config/dea-laptop.yml) as below.

{% highlight yaml %}
---
# Base directory where all applications are staged and hosted
base_dir: /tmp/deploying-to-a-cloudfoundry-dea/var/dea
pid: /tmp/deploying-to-a-cloudfoundry-dea/var/run/dea.pid

runtimes:
  - ruby19

multi_tenant: true

max_memory: 1024

# Optional as of http://reviews.cloudfoundry.org/11316
logging:
  level: debug

{% endhighlight %}

Running `dea` again whilst using this configuration file is a lot more successful!

{% highlight %}
$ ./dea/bin/dea -c config/dea-laptop.yml
Starting VCAP DEA (0.99)
Pid file: /tmp/deploying-to-a-cloudfoundry-dea/var/run/dea.pid
Using ruby @ /Users/drnic/.rvm/rubies/ruby-1.9.3-p286/bin/ruby
Using network: 192.168.1.70
Socket Limit:256
Max Memory set to 4.0G
Utilizing 1 cpu cores
Restricting to single tenant
Using directory: /tmp/deploying-to-a-cloudfoundry-dea/var/dea/
Initial usage of droplet fs is: 0%
File service started on port: 
EXITING! NATS error: Could not connect to server on nats://localhost:4222
{% endhighlight %}

And we move on to the next piece of Cloud Foundry, the messaging bus called NATS!

## NATS

[NATS](https://github.com/derekcollison/nats) is a simple pub-sub messaging system used by Cloud Foundry for communication between services.

By default, the DEA looks for a NATS server on http://localhost:4222. Port 4222 is coincidently the default port that `nats-server` (see below) binds too. NATS is currently a rubygems, but let's fetch its source code via git into our project folder:

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

In a new terminal, run this script. In the original terminal, kill the DEA and restart it (Ctrl+C to kill it). The following output appears in the `nats_all` terminal.

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
  "host": "192.168.1.77:51619",
  "credentials": [
    "a6d616c5403ee99a08ef2c38553bcaeb",
    "4e32849cecb5c38f54e7e5e74d0ff5a7"
  ],
  "mem": 42744,
  "cpu": 0.0,
  "apps_max_memory": 1024,
  "apps_reserved_memory": 0,
  "apps_used_memory": 0,
  "num_apps": 0,
  "running_apps": [

  ]
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

## DEA knows about its running an application

If you now ask the DEA for its `varz` status again, it will tell you about the application that it is running, and the runtimes and frameworks that it is feeling confident about:

{% highlight bash %}
$ curl http://USERNAME:PASSWORD@192.168.1.70:62556/varz
{
  ...
  "running_apps": [
    {
      "state": "RUNNING",
      "runtime": "ruby19",
      "framework": "sinatra",
    }
  ],
  "frameworks": {
    "sinatra": {
      ...
    }
  },
  "runtimes": {
    "ruby19": {
      ...
    }
  },
  ...
}
{% endhighlight %}


## Summary

Deploying an application to a DEA has a few simple requirements.

* Run a NATS server
* Run a DEA using a simple YAML configuration
* Create a `startup` script and a copy of your application together in a folder
* Publish NATS message `dea.DEA_UUID.start` to tell the application to deploy the application from its local cached/pre-staged version (or a remote tar)

Its not as simple as perhaps it could be; but it is relatively understandable as to how the pieces fit together. You use NATS to find and communicate with a DEA. You tell it what tarball to use to unpack and run via a `startup` script. Pretty simple.

## Next, staging any application for the DEA

In the next [DIY PaaS](/tags.html#diy-paas-ref) article, we will take the next logical step: what is a droplet and how did it get created?

If you want to skip ahead, look in the [Cloud Foundry github account](https://github.com/cloudfoundry/) for the repositories related to the term "staging" or "stager".

Follow [@starkandwayne](https://twitter.com/starkandwayne) for the release of the next article and other blog posts from the wonderful world Cloud Foundry.