---
layout: post
title: "Bare minimum Cloud Foundry - Staging an app"
description: "A detailed look at how applications deployed by a DEA are prepared/staged into a special format"
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
sliders:
- title: "How app staging works"
  text: "Cloud Foundry takes your application and 'stages' it before distributing to DEAs for deployment. Let's look at what is going on."
  image: /assets/images/cloudfoundry-235w.png
- title: "Inside look at staging"
  text: "Cloud Foundry takes your application and 'stages' it before distributing to DEAs for deployment. Let's look at what is going on."
  image: /assets/images/cloudfoundry-235w.png
slider_background: sky-horizon
publish_date: "2012-11-13"
category: "articles"
tags: [cloudfoundry]
theme:
  name: smart-business-template
---
{% include JB/setup %}

In the previous article in the "Bare Minimum Cloud Foundry" series, I introduced the truly barest minimum of Cloud Foundry to deploy applications - the Droplet Execution Agent (DEA) and the pub-sub message bus NATS.

Each time you "add an instance" [(1)](#footer-add-instances) of a running application, the DEA takes a tarballed version of an application, unpacks it, and runs a single `startup` script. The DEA knows nothing about Ruby or Java or PHP; it only knows about the `startup` script within a tarball. How does the tarball get created?

The tarball, which includes an executable `startup` script, is created during a staging step. It is the staging step that knows about Ruby and Java and PHP applications and how to run them. This article investigates how Cloud Foundry stages an application and creates the tarball for DEAs.

As I go along, I'll clone/submodule the repositories that I need and show the configuration files. The final product is available in a [git repository](https://github.com/StarkAndWayne/staging-apps-in-cloudfoundry) as a demonstration of the minimium parts of Cloud Foundry required to deploy an application via staging.

## VCAP Staging

The staging code is in [vcap-staging](https://github.com/cloudfoundry/vcap-staging)

```
git clone git://github.com/cloudfoundry/vcap-staging.git
cd vcap-staging
bundle
cd ..
```

The goal of `vcap-staging` is to create a new folder structure that contains:

* the user's application (in `app` dirctory)
* `startup` & `stop` scripts for the runtime/framework of the application
* `logs` dirctory for the application's `STDOUT` & `STDERR` logs
* `tmp` dirctory for... temporary things; its the `$TMPDIR` for the application

To stage a specific application framework you choose a `StagingPlugin` subclass, initialize it and invoke `#stage_application`.

For example, I can stage an example sinatra application (in [apps/sinatra](https://github.com/StarkAndWayne/deploying-to-a-cloudfoundry-dea/tree/master/apps/sinatra))

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

The resulting `startup` script is:

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

This token is replaced by the DEA when it unpacks the staged tarball to use the runtime selected for the application. In this example, this might be the ruby executable for either the `ruby18` or `ruby19` runtimes.

<p name="#footer-add-instances">(1) I don't agree with this terminology in Cloud Foundry. When you add "instances" to a running application, you are actually adding running processes. If you've used Heroku, this is akin to adding dynos. To me, "instances" means virtual machines or servers. In Cloud Foundry, it means "processes of your app". In future Cloud Foundry, it will be a Linux container running an application process.</p>