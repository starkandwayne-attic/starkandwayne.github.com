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
publish_date: "2013-04-05"
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
$ appscrolls new mysidekiqapp -s puma cf postgresql rails_basics redis sidekiq git
{% endhighlight %}

The only prerequisites:

* you have postgresql and redis running locally
* you have a Cloud Foundry account somewhere
* your `vmc` app is already logged in to that Cloud Foundry account

At the end, you'll see two new applications/processes running on your Cloud Foundry:

{% highlight bash %}
$ vmc apps
+---------------------+----+---------+------------------------+---------------------------------------------+
| Application         | #  | Health  | URLS                   | Services                                    |
+---------------------+----+---------+------------------------+---------------------------------------------+
| mysidekiqapp        | 1  | RUNNING | mysidekiqapp.drnic.dev | mysidekiqapp-postgresql, mysidekiqapp-redis |
| mysidekiqapp-worker | 1  | RUNNING |                        | mysidekiqapp-postgresql, mysidekiqapp-redis |
+---------------------+----+---------+------------------------+---------------------------------------------+
{% endhighlight %}

The application is now running at http://mysidekiqapp.drnic.dev and the Sidekiq dashboard is running at http://mysidekiqapp.drnic.dev/sidekiq/SECRET (for whatever you entered for the secret).

Want to learn more about what just happened? Read onwards!

