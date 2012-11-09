---
layout: post
title: "Deploy all new Rails apps Cloud Foundry with AppScrolls"
description: ""
main_picture: /assets/articles/images/car.jpg
author: "Dr Nic Williams"
author_code: drnic
category: articles
published: true
publish_date: 2012-11-08
tags: []
theme:
  name: smart-business-template
---
{% include JB/setup %}
{% # https://github.com/mojombo/jekyll/wiki/Liquid-Extensions %}

[AppScrolls](http://appscrolls.org/), formerly Rails Wizard, can now create applications that are automatically deployed to any Cloud Foundry target.

    gem install appscrolls
    appscrolls new mynewapp -s cfoundry

After three years of using public PaaS - Engine Yard Cloud and Heroku - I'm now consulting inside "Big Enterprise", but with a twist. We are running [Cloud Foundry](http://cloudfoundry.org/) inside our own data centers. So it is time to port many of my beloved dev tools to Cloud Foundry.

[AppScrolls](http://appscrolls.org/), formerly Rails Wizard, lets me create a new Ruby on Rails application with many gems already installed and configured, local databases created and migrated, and the initial app already deployed into production (see the [eycloud recipe](https://github.com/drnic/appscrolls/blob/master/scrolls/eycloud.rb) for [Engine Yard Cloud](http://www.engineyard.com/products/cloud)).

The `cfoundry` scroll does the following:

* vendors all gems, via `bundle package`
* includes a `production:` section to `database.yml` and an initializer (as per [CF blog post](http://blog.cloudfoundry.com/2012/04/19/deploying-jruby-on-rails-applications-on-cloud-foundry/ "Using JRuby for Rails Applications on Cloud Foundry | CloudFoundry.com Blog"))
* runs an initial deploy (`vmc push`) to your current target Cloud Foundry

There are still a couple of manual, repetitive steps during the CF deployment. I might get annoyed by those one day and patch VMC so the whole thing is automated. Or perhaps you fix it first!

