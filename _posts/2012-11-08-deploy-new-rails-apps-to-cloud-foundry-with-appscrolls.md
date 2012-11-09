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
banner:
  title: AppScrolls &amp; CloudFoundry
  text: AppScrolls can now create applications that are automatically deployed to any Cloud Foundry target.
  image: /assets/images/cloudfoundry-235w.png
  background: parchment
published: true
publish_date: 2012-11-08
tags: [cloudfoundry, appscrolls]
theme:
  name: smart-business-template
---
{% include JB/setup %}

[AppScrolls](http://appscrolls.org/), formerly Rails Wizard, can now create applications that are automatically deployed to any Cloud Foundry target.

{% highlight bash %}
gem install appscrolls
appscrolls new mynewapp -s cfoundry postgresql
appscrolls new mynewapp -s cfoundry postgresql twitter-bootstrap
{% endhighlight %}

After three years of using public PaaS - Engine Yard Cloud and Heroku - I'm now consulting inside "Big Enterprise", but with a twist. We are running [Cloud Foundry](http://cloudfoundry.org/) inside our own data centers. So it is time to port many of my beloved dev tools to Cloud Foundry.

[AppScrolls](http://appscrolls.org/), formerly Rails Wizard, lets me create a new Ruby on Rails application with many gems already installed and configured, local databases created and migrated, and the initial app already deployed into production (see the [eycloud recipe](https://github.com/drnic/appscrolls/blob/master/scrolls/eycloud.rb) for [Engine Yard Cloud](http://www.engineyard.com/products/cloud)).

The `cfoundry` scroll does the following:

* packages/vendors all gems locally (necessary for older Cloud Foundry installations)
* includes a production section to `database.yml` and an initializer (as per [CF blog post](http://blog.cloudfoundry.com/2012/04/19/deploying-jruby-on-rails-applications-on-cloud-foundry/ "Using JRuby for Rails Applications on Cloud Foundry | CloudFoundry.com Blog")) (necessary for JRuby where auto-discovery does not work)
* deploys the new application to your current target Cloud Foundry

Cloud Foundry doesn't require Git like Heroku, nor require your source code be hosted somewhere like Engine Yard Cloud. So you will need to add the `github` scroll to go through the creation of a new GitHub repository.

There are still a couple of manual steps during the Cloud Foundry app deployment. I might get annoyed enough by those one day and patch VMC so the whole cfoundry scroll does not require any manual intervention. Or thanks in advance if you  you fix it first!

Let me know in the comments if the scroll works great or in the <a href="https://github.com/drnic/appscrolls/issues?labels=&amp;milestone=&amp;state=open">AppScrolls Issues Tracker</a> if it doesn't work so great.
