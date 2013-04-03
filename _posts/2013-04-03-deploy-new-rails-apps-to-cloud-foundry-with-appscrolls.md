---
layout: post
title: "Deploy new Rails apps to Cloud Foundry with AppScrolls"
description: |
  AppScrolls can now rapidly create Ruby on Rails applications that are automatically
  deployed to any Cloud Foundry target.
icon: cloud
author: "Dr Nic Williams"
author_code: drnic
category: snippets
sliders:
- title: AppScrolls &amp; Cloud Foundry
  text: AppScrolls can now create applications that are automatically deployed to any Cloud Foundry target.
  image: /assets/images/cloudfoundry-235w.png
slider_background: parchment
publish_date: 2013-04-03
tags: [cloudfoundry, appscrolls, puma, rails]
theme:
  name: smart-business-template
---
{% include JB/setup %}

[AppScrolls](http://appscrolls.org/), formerly Rails Wizard, can now create applications that are automatically deployed to any Cloud Foundry target.

{% highlight bash %}
gem install appscrolls
appscrolls new mynewapp -s cf puma postgresql rails_basics
{% endhighlight %}

In less than a minute, your application will be up and running on your target Cloud Foundry (a public or private one).

If you're a fan of AppScrolls, you'll notice that I've also added a Puma scroll based on the discovery of [how to make Puma the default server for a Rails app](http://starkandwayne.com/articles/2013/03/27/puma-in-cloud-foundry/ "Stark & Wayne's Did you know you can use Puma in Cloud Foundry?").

So in one fell swoop you can create a new Rails app, use Puma and have it running on your public/private Cloud Foundry!
