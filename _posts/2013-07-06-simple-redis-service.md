---
layout: post
title: "Simple redis service built on bosh"
description: "Create & delete Redis services using bosh" # Used in /articles.html listing
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
sliders:
- title: "Simple redis service"
  text: Create & delete Redis services using bosh
  image: /assets/images/cloudfoundry-235w.png
- title: "Bind dedicate redis to CF"
  text: Easy to bind redis service to your Cloud Foundry apps
  image: /assets/images/cloudfoundry-235w.png
slider_background: ny # or parchment,abyss,sky-horizon-sky from /assets/sliders
publish_date: "2013-07-06"
category: "articles"
tags: [cloudfoundry, redis, bosh]
theme:
  name: smart-business-template
---
{% include JB/setup %}

Let's keep Cloud Foundry services simple. If you want a service then you let's get it by running in a dedicate server/instance. Use small virtual machines for small requirements and big virtual machines with big network IOPS for large requirements.

This is clean to implement. It is simple to administrate. It makes it easy to upgrade each service independently of all the others.

The initial implementation is for Redis. A simple plugin to the Cloud Foundry CLI `cf` that talks to bosh to create and delete servers that are running redis.

Here is an example scenario for installing the plugin, login to bosh (ask your sysadmin for credentials), uploading the redis release to bosh, and then creating and deleting as many redis servers as you and your team need.

{% highlight bash %}
$ gem install bosh_cli "~> 1.5.0.pre" --source https://s3.amazonaws.com/bosh-jenkins-gems/ 
$ gem install bosh_cli_plugin_redis

$ bosh prepare redis
$ bosh create redis
$ bosh show redis uri
redis://:c1da049a75b3@0.redis.default.demoredis.microbosh:6379/0
$ cf set-env myapp REDIS_URI redis://:c1da049a75b3@0.redis.default.redis-123.microbosh:6379/0

$ cf unset-env myapp REDIS_URI
$ bosh delete redis
{% endhighlight %}

The source for the CLI plugin is at [https://github.com/drnic/bosh_cli_plugin_redis](https://github.com/drnic/bosh_cli_plugin_redis).

The source for running redis upon bosh is [https://github.com/cloudfoundry-community/redis-boshrelease](https://github.com/cloudfoundry-community/redis-boshrelease).

## Where is redis server described?

When you run `bosh prepare redis` above, the bosh release that describes redis is uploaded to your bosh. There is no cloning git repositories or creating bosh releases. It quickly pulls down a bosh package and a bosh job that describe running redis and upload them to your bosh.

In future, each new plugin version may include new improvements to the bosh release. You run `bosh prepare redis` each time you install a new plugin gem.

Of note are three files in the bosh release:

* `redis.conf` template is in [jobs/redis/templates/config/redis.conf.erb](https://github.com/cloudfoundry-community/redis-boshrelease/blob/master/jobs/redis/templates/config/redis.conf.erb)
* the monit control script is in [jobs/redis/templates/bin/redis_ctl](https://github.com/cloudfoundry-community/redis-boshrelease/blob/master/jobs/redis/templates/bin/redis_ctl)
* the packaging/compilation script for redis-server is in [packages/redis/packaging](https://github.com/cloudfoundry-community/redis-boshrelease/blob/master/packages/redis/packaging)

## How is redis server and properties described?

Put simply, the plugin is automating the creation of a bosh deployment file (and deploying/deleting it). So anything you can do with bosh you can do with do here. `bosh create redis` creates a `deployments/redis/redis-123456.yml` deployment file in the local folder (say an application folder).

So you can edit it and run `bosh deploy` to make any fancy changes. Also, future versions of the plugin will provide ways to update or scale any given redis service to make that simpler.

The plugin uses the current `bosh deployment` to determine which redis deployment it is functioning on.

## How are instance sizes described?

You'll note in the example above that `--size medium` is used to describe the size of the server to run redis. In AWS there is no `medium` instance flavor; nor might your OpenStack have a instance flavor `medium`.

You might ask "how do I specify an m1.medium on AWS?" or "how do I use the instances sizes my OpenStack administrator has given me?"

In the initial release of the plugin there are four instance sizes supported - `small`, `medium`, `large` and `xlarge` - and these map to different things on different infrastructures. By default, in AWS and OpenStack, they map to instance flavors `m1.small`, `m1.medium`, `m1.large` and `m1.xlarge` respectively.

Soon it will be entirely configurable what instance sizes are available and how they map to instance flavors on your infrastructure.

## Known limitations of current v0.2 release

* no public IP support - so can only access the redis server from other bosh deployments (such as Cloud Foundry) from the same bosh (via its internal DNS)
* there is no `bosh update redis` yet, although you can modify the generated deployment file and run `bosh deploy`
* it only includes default aws & openstack templates - to add support for vsphere please add templates into redis-boshrelease first
* no way yet to customize the list of available instance sizes

These are all fixable limitations. I'm sorry if you're adversely affected by them today.

## Credits

The idea of using ERb templates to generate the large bosh deployment files, and the idea of managing the experience from the `cf` command line come from the [bootstrap-cf-plugin](https://github.com/cloudfoundry/bootstrap-cf-plugin).

I prefer this tool as a `bosh` CLI plugin than a `cf` CLI plugin. Its performing tasks upon bosh. In future I would like a service available to `cf` users which adheres to cf user roles and organizations/spaces and provisions/destroys services such as redis via bosh.

I don't like that this plugin, nor bootstrap-cf-plugin, nor bosh-cloudfoundry must exist. Ultimately I want any bosh release to be very easy to use without an additional CLI plugin.

