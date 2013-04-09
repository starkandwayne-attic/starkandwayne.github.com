---
layout: post
title: "Run Sidekiq on Cloud Foundry"
description: "Simple steps to use Sidekiq in your Rails app on Cloud Foundry; even faster with AppScroll!"
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
# main_picture: /assets/articles/images/car.jpg
sliders:
- title: "Run Sidekiq on Cloud Foundry"
  text: Simple steps to use Sidekiq in your Rails app on Cloud Foundry
  image: /assets/images/sidekiq-235w.png
- title: "Quick start via AppScrolls"
  text: Use AppScrolls to include Sidekiq on your next Rails app
  image: /assets/images/sidekiq-235w.png
slider_background: parchment
published: true
publish_date: "2013-04-09"
category: "articles"
tags: [cloudfoundry, appscrolls, sidekiq, rails]
theme:
  name: smart-business-template
---
{% include JB/setup %}

For the same reason I like [Puma](http://starkandwayne.com/articles/2013/03/27/puma-in-cloud-foundry/ "Stark & Wayne's Did you know you can use Puma in Cloud Foundry?") as my Rails web server, I like using Sidekiq for my background jobs. The reason? They use threads. Puma can handle multiple web requests simultaneously and Sidekiq can handle multiple background jobs simultaneously.

This article shows how I add Sidekiq to my Rails app and run its background worker process(es) on Cloud Foundry. It even includes the brilliant Sidekiq dashboard.

## Just show me something that works

But first, I've added Sidekiq support into AppScrolls. So you'll see how quickly you can create a new Rails app, include full Sidekiq support and have the web app and worker process running on Cloud Foundry in less than a minute!

Run the following and you'll have a new Rails app running on Cloud Foundry with a Sidekiq worker process.

{% highlight bash %}
$ gem install appscrolls
$ appscrolls new skiq -s puma cf postgresql rails_basics redis sidekiq git
{% endhighlight %}

The only prerequisites:

* you have postgresql and redis running locally
* you have a Cloud Foundry account somewhere, for example http://cloudfoundry.com
* your `vmc` app is already logged in to that Cloud Foundry account

At the end, you'll see two new applications/processes running on your Cloud Foundry:

{% highlight bash %}
$ vmc apps
+-------------+----+---------+-----------------------+-----------------------------+
| Application |    | Health  | URLS                  | Services                    |
+-------------+----+---------+-----------------------+-----------------------------+
| skiq        | 1  | RUNNING | skiq.cloudfoundry.com | skiq-redis, skiq-postgresql |
| skiq-worker | 1  | RUNNING |                       | skiq-redis, skiq-postgresql |
+-------------+----+---------+-----------------------+-----------------------------+
{% endhighlight %}

The application is now running at [http://skiq.cloudfoundry.com](http://skiq.cloudfoundry.com) and the Sidekiq dashboard is running at [http://skiq.cloudfoundry.com/sidekiq/SECRET](http://skiq.cloudfoundry.com/sidekiq/) (for whatever you entered for the secret; I entered nothing).

Want to learn more about what just happened? Read onwards!

## How to manually add Sidekiq support to your Cloud Foundry Rails app?

The overview is:

* Add Redis to your app
* Add Sidekiq to your app, similar to how it is documented on [RailsCasts](http://railscasts.com/episodes/366-sidekiq "#366 Sidekiq - RailsCasts")
* Create/bind Redis to your app running on Cloud Foundry
* Run Sidekiq as a separate standalone process on Cloud Foundry, bound to the same services as your app uses

### Add Redis & Sidekiq to your app

Add the following gems to your `Gemfile`:

{% highlight ruby %}
gem "redis"
gem "sidekiq"
gem "slim"
gem "sinatra", ">= 1.3.0", :require => false
{% endhighlight %}

and run `bundle install`.

Into your `config/routes.rb` file add the following:

{% highlight ruby %}
require "sidekiq/web"
mount Sidekiq::Web, at: "/sidekiq/SECRET"
require "sidekiq/api"
match "queue-status" => proc { [200, {"Content-Type" => "text/plain"}, [Sidekiq::Queue.new.size < 100 ? "OK" : "UHOH" ]] }
{% endhighlight %}

The second line includes a simple token authentication system to protect your Sidekiq dashboard from casual onlookers. Replace SECRET with a long string of your choice. For more complex authentication, look at the Sidekiq wiki.

The last line is a neat tip I found for providing a simple HTTP endpoint that you can poll for health status.

To support Redis locally and in your Cloud Foundry deployment, I use the following `config/initializers/redis.rb` file:

{% highlight ruby %}
if ENV['VCAP_SERVICES']
  $vcap_services ||= JSON.parse(ENV['VCAP_SERVICES'])
  redis_service_name = $vcap_services.keys.find { |svc| svc =~ /redis/i }
  redis_service = $vcap_services[redis_service_name].first
  $redis_config = {
    host: redis_service['credentials']['host'],
    port: redis_service['credentials']['port'],
    password: redis_service['credentials']['password']
  }
else
  $redis_config = {
    host: '127.0.0.1',
    port: 6379
  }
end

$redis = Redis.new($redis_config)
{% endhighlight %}

Finally, to configure Sidekiq I add the following `config/initializers/sidekiq.rb` file:

{% highlight ruby %}
if $redis_config[:password]
  redis_url = "redis://:#{$redis_config[:password]}@#{$redis_config[:host]}:#{$redis_config[:port]}/0"
else
  redis_url = "redis://#{$redis_config[:host]}:#{$redis_config[:port]}/0"
end
Sidekiq.redis = { url: redis_url, namespace: 'sidekiq' }
{% endhighlight %}

This is exactly what AppScrolls is doing when you use the `sidekiq` and `cf` scrolls together.

### Add Redis to your Cloud Foundry deployment

Adding new services to an existing application is really easy (I am using the VMC 0.3.23 client commands here):

{% highlight ruby %}
$ vmc create-service redis --name APPNAME-redis --bind APPNAME
{% endhighlight %}

It will create a new Redis database, bind it to your `APPNAME` application and restart your application!

### Run a Sidekiq worker

You can run an arbitrary process/daemon on Cloud Foundry using the "standalone" framework. To run a Sidekiq worker, we want to re-deploy our Rails app as a new Cloud Foundry application in "standalone" mode; and tell it to run the `sidekiq` daemon.

This is actually easier said than done, sadly. So, cheat with me!

Here is a second `manifest.yml` file you can use (just like the one that AppScrolls generates for you). I name it `manifest.worker.yml`:

{% highlight yaml %}
---
applications:
  .:
    name: APPNAME-worker
    framework:
      name: standalone
      info:
        mem: 64M
        description: Standalone Application
        exec: 
    url: 
    path: .
    runtime: ruby19
    command: bundle exec sidekiq -e production
    mem: 256M
    instances: 1
    services:
      APPNAME-postgresql:
        type: postgresql
      APPNAME-redis:
        type: redis
{% endhighlight %}

Note, you want to include the same `services:` in this file as your Rails application is bound to. Your Sidekiq worker runs the same code as your Rails application and it may want to use one or more of the same services. The most important of these is the Redis service, which is used to manage the queues of requested background jobs.

To deploy our worker process:

{% highlight bash %}
$ vmc push --manifest manifest.worker.yml --path .
{% endhighlight %}

Congratulations! You have now added Sidekiq to your Rails app running on Cloud Foundry!

## Living with Sidekiq on Cloud Foundry

The primary thing to remember is that you are technically running two Cloud Foundry applications:

* your main Rails application
* your Sidekiq worker

Both run from your app code. Which means that when you want to deploy new app code, you also need to re-deploy your Sidekiq workers.

{% highlight bash %}
# vmc 0.3.X
$ vmc update --manifest manifest.yml
$ vmc update --manifest manifest.worker.yml
# cf 0.6+ or vmc 0.4+
$ cf push --manifest manifest.yml
$ cf push --manifest manifest.worker.yml
{% endhighlight %}

It also means you can easily scale your web app and your workers independently:

{% highlight ruby %}
$ vmc instances APPNAME 5
$ vmc instances APPNAME-worker 2
{% endhighlight %}

As you become a more advanced user of Sidekiq, you can change the `command:` to tune Sidekiq (for example, change the default concurrency of 25). You can even create multiple `manifest.worker.yml` files to run different Sidekiq configurations (primarily, to run different queues).

## Anything else?

If you have any tips on running Sidekiq or standalone applications on Cloud Foundry, please drop them in the comments! I'd love to hear from you.
