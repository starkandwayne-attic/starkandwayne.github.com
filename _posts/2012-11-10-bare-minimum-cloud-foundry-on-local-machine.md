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
