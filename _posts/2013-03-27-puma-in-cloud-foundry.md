---
layout: post
title: "Did you know you can use Puma in Cloud Foundry?"
description: "Puma is a great web server for Ruby/Rails applications and you can use it with Cloud Foundry today" # Used in /articles.html listing
icon: signal # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
# main_picture: /assets/articles/images/car.jpg
sliders:
- title: "Use Puma in Cloud Foundry"
  text: Puma is a great web server for Ruby/Rails applications and you can use it with Cloud Foundry today
  image: /assets/images/puma-235w.png
slider_background: parchment
publish_date: "2013-03-27"
category: "articles"
tags: [cloudfoundry, puma]
theme:
  name: smart-business-template
---
{% include JB/setup %}

When Cloud Foundry was first released in April 2011, it supported both Ruby 1.8 and Ruby 1.9 but it only supported the thin server. This was the same server that was originally only supported by Heroku. Mike Perham wrote a [great article on the Puma server](http://www.mikeperham.com/2012/12/12/12-gems-of-christmas-1-puma/ "12 Gems of Christmas #1 &#8211; puma | Mike Perham") last Christmas and it turns out it is really easy to use Puma within Cloud Foundry.

Summary of steps:

* turn on threadsafe mode
* add puma gem to Gemfile & install gems
* update script/rails to change default to Puma
* push to Cloud Fooundry
* check logs to confirm that it is using Puma!

## Preparation

First, let's turn on threadsafe mode so we get the humming threaded goodness (which is far better with runtime ruby19)

{% highlight ruby %}
# Enable threaded mode
config.threadsafe!
{% endhighlight %}

Add the Puma gem to your Gemfile:

{% highlight ruby %}
gem "puma"
{% endhighlight %}

NOTE, also remove `gem "thin"` if you had that.

Update your Gemfile.lock:

{% highlight text %}
bundle install
{% endhighlight %}

## Changing the default server

By default, Rails uses the all-ruby web server Webrick that comes as a standard library with each Ruby installation. [We can change that default](http://stackoverflow.com/questions/14146700/how-to-change-the-default-rails-server-in-rails-3/14911994#14911994 "How to change the default rails server in Rails 3? - Stack Overflow") and we do that by editing the `script/rails` command.

Add the following two lines into your script/rails command:

{% highlight ruby %}
require 'rack/handler'
Rack::Handler::WEBrick = Rack::Handler.get(:puma)
{% endhighlight %}

The `script/rails` command will now look like:

{% highlight ruby %}
#!/usr/bin/env ruby

APP_PATH = File.expand_path('../../config/application',  __FILE__)
require File.expand_path('../../config/boot',  __FILE__)

require 'rack/handler'
Rack::Handler::WEBrick = Rack::Handler.get(:puma)

require 'rails/commands'
{% endhighlight %}

## Running under Puma

You can now test that "rails server" defaults to Puma:

{% highlight text %}
$ rails s
=> Booting Puma
=> Rails 3.2.8 application starting in development on http://0.0.0.0:3000
=> Call with -d to detach
=> Ctrl-C to shutdown server
Puma 1.6.3 starting...
* Min threads: 0, max threads: 16
...
{% endhighlight %}

Hooray, we booted Puma by default.

Now we can push this up to Cloud Foundry and it too will use Puma by default!

{% highlight text %}
$ vmc update # for vmc v0.3.X
$ vmc push   # for vmc v0.4+
{% endhighlight %}

Each Puma process defaults to maximum 16 threads. You can also scale out the number of Puma processes using the `vmc instances` command. 

{% highlight text %}
vmc instances NAME 5  # changes to 5 instances
vmc instances NAME +5  # adds 5 more instances
vmc instances NAME -4  # removes 4 instances
{% endhighlight %}


Remember, please stop using ruby 1.8. It is EOL soon and there will be no more security patches.

Today is a great day to delete and recreate all your Cloud Foundry ruby apps with the ruby19 runtime.
