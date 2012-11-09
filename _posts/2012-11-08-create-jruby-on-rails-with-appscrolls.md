---
layout: post
title: "Create JRuby on Rails with AppScrolls"
description: ""
author: "Dr Nic Williams"
author_code: drnic
banner:
  title: AppScrolls &amp; JRuby
  text: AppScrolls now detects JRuby for all scrolls and deployment options
  image: /assets/images/jruby-logo-300w.png
  background: parchment
published: true
publish_date: "2012-11-08"
category: "articles"
tags: []
theme:
  name: smart-business-template
---
{% include JB/setup %}

[AppScrolls](http://appscrolls.org/), formerly Rails Wizard, now automatically detects that you want a JRuby application and all scrolls behave appropriately for JRuby.

{% highlight bash %}
rvm install jruby
rvm jruby
gem install appscrolls
appscrolls new mynewapp
appscrolls new mynewapp -s cfoundry
appscrolls new mynewapp -s eycloud
{% endhighlight %}

JRuby is recognized by many as the Ruby for production systems. Sun Microsystems, Engine Yard and Red Hat have all funded JRuby core development for almost 10 years. The JVM has had billions invested in it. The next step is to make JRuby and Rails easier to get started together. As always, that's what AppScrolls is for!

