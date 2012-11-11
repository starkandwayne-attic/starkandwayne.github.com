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

As I go along, I'll clone/submodule the repositories that I need and show the configuration files.

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

# Optional as of http://reviews.cloudfoundry.org/11316
logging:
  level: debug

# Optional as of http://reviews.cloudfoundry.org/11315
intervals:
  heartbeat: 10
  advertise: 5

# Optional as of http://reviews.cloudfoundry.org/11317
max_memory: 4096
{% endhighlight %}

When we run our dea command again we specify this configuration file...

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

But first, how do we deploy an application into the DEA? Via NATS client calls.

## Using NATS to deploy to a DEA

Each DEA listens for [various messages](https://github.com/cloudfoundry/dea/blob/master/lib/dea/agent.rb#L267-276) on NATS.

To tell a DEA to deploy an application, you publish a NATS message that contains its UUID, `dea.UUID.start`. In a full Cloud Foundry, it is the Cloud Controller that publishes this message. The Cloud Controller is the public API for user requests - deploy new apps, update existing apps, and scaling existing apps.

The bulk of the `dea.UUID.start` message is created in [AppManager#new_message](https://github.com/cloudfoundry/cloud_controller/blob/master/cloud_controller/app/models/app_manager.rb#L369-385).

An example `dea.UUID.start` JSON message could be:

{% highlight json %}
{
  droplet: 'APP_ID',
  name: 'mylocalapp',
  uris: '????',
  running: 'ruby19',
  running_info: { ???? },
  framework: ????,
  prod: false,
  sha1: 'HASH',
  executableFile: '???',
  executableUri: "/staged_droplets/APP_ID/HASH",
  version: '1-1',
  services: [],
  limits: { 'mem': 256 },
  env: [],
  users: ['drnicwilliams@gmail.com'],
  cc_partition: 'default',
  debug: ???,
  console: ???,
  index: 0
}
{% endhighlight %}


https://github.com/cloudfoundry/cloud_controller/blob/master/cloud_controller/app/models/app_manager.rb#L369-385
{% highlight ruby %}

{% endhighlight %}
