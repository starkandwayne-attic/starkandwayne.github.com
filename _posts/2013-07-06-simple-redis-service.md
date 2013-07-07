---
layout: post
title: "Simple redis service for Cloud Foundry built on bosh"
description: "Cloud Foundry CLI plugin for creating & binding Redis to your apps using bosh" # Used in /articles.html listing
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
sliders:
- title: "Simple redis service"
  text: Cloud Foundry CLI plugin for creating & binding Redis to your apps using bosh
  image: /assets/images/cloudfoundry-235w.png
- title: "using bosh to power services"
  text: Uses bosh to provision dedicated Redis servers as needed
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
$ gem install redis-cf-plugin
$ bosh target 1.2.3.4
$ bosh login
$ cf prepare-redis
$ cf create-redis --size medium --security-group redis-service
$ cf bind-redis-env-var myapp --env-var REDISTOGO
$ cf delete-redis
{% endhighlight %}

The source for the CLI plugin is at [https://github.com/drnic/redis-cf-plugin](https://github.com/drnic/redis-cf-plugin).

The source for running redis upon bosh is [https://github.com/cloudfoundry-community/redis-boshrelease](https://github.com/cloudfoundry-community/redis-boshrelease).

## Where is redis server described?

When you run `cf prepare-redis` above, the bosh release that describes redis is uploaded to your bosh. There is no cloning git repositories or creating bosh releases. It quickly pulls down a bosh package and a bosh job that describe running redis and upload them to your bosh.

In future, each new plugin version may include new improvements to the bosh release. You run `cf prepare-redis` each time you install a new plugin gem.

Of note are three files in the bosh release:

* `redis.conf` template is in [jobs/redis/templates/config/redis.conf.erb](https://github.com/cloudfoundry-community/redis-boshrelease/blob/master/jobs/redis/templates/config/redis.conf.erb)
* the monit control script is in [jobs/redis/templates/bin/redis_ctl](https://github.com/cloudfoundry-community/redis-boshrelease/blob/master/jobs/redis/templates/bin/redis_ctl)
* the packaging/compilation script for redis-server is in [packages/redis/packaging](https://github.com/cloudfoundry-community/redis-boshrelease/blob/master/packages/redis/packaging)

## How is redis server and properties described?

Put simply, the plugin is automating the creation of a bosh deployment file (and deploying/deleting it). So anything you can do with bosh you can do with do here. `cf create-redis` creates a `deployments/redis/redis-123456.yml` deployment file in the local folder (say an application folder).

So you can edit it and run `bosh deploy` to make any fancy changes. Also, future versions of the plugin will provide ways to update or scale any given redis service to make that simpler.

The plugin uses the current `bosh deployment` to determine which redis deployment it is functioning on.

## How are instance sizes described?

You'll note in the example above that `--size medium` is used to describe the size of the server to run redis. In AWS there is no `medium` instance flavor; nor might your OpenStack have a instance flavor `medium`.

Initially there are four instance sizes supported - `small`, `medium`, `large` and `xlarge` - and these map to different things on different infrastructures. By default, in AWS and OpenStack, they map to instance flavors `m1.small`, `m1.medium`, `m1.large` and `m1.xlarge` respectively.

In future, the list of instance sizes and what they map to in your infrastructure (AWS, OpenStack, vSphere) it will be configurable.

## Limitations of initial v0.1.0 release

* only supports binding via an environment variable (`$REDIS_URI` by default); waiting on Service Connector APIs & client libraries to come along before integration via `$VCAP_SERVICES`
* must use same bosh used to deploy Cloud Foundry because its initially only supporting bosh DNS to describe the redis server host
* there is no `cf update-service` yet, although you can modify the generated deployment file and run `bosh deploy`
* it only includes aws & openstack - to add support for vsphere please add templates into redis-boshrelease first
* no way yet to customize the list of available instance sizes

## Credits

The idea of using ERb templates to generate the large bosh deployment files, and the idea of managing the experience from the `cf` command line come from the [bootstrap-cf-plugin](https://github.com/cloudfoundry/bootstrap-cf-plugin).
