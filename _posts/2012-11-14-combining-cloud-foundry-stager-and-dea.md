---
layout: post
title: "Combining Cloud Foundry Stager and DEA"
description: The Stager converts apps into droplets. The DEA for deploys the droplets. In this article we put them together.
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
# main_picture: /assets/articles/images/car.jpg
sliders:
- title: "Stage then deploy"
  text: The Stager converts apps into droplets. The DEA for deploys the droplets. Let's put them together.
  image: /assets/images/cloudfoundry-235w.png
slider_background: sky-horizon-and-grass # or parchment,abyss,sky-horizon-sky from /assets/sliders
publish_date: "2012-11-14"
category: "articles"
tags: [cloudfoundry]
theme:
  name: smart-business-template
---
{% include JB/setup %}

We are going to run the small set of services and a script that composes them together to get the following output:

{% highlight bash %}
$ ./bin/deploy_app
[2012-11-14 10:14:24] Setting up temporary directories
[2012-11-14 10:14:24] Downloading application
[2012-11-14 10:14:24] Unpacking application
[2012-11-14 10:14:24] Staging application
[2012-11-14 10:14:26] # Logfile created on 2012-11-14 10:14:26 -0800 by logger.rb/31641
[2012-11-14 10:14:26] Auto-reconfiguration disabled because app does not use Bundler.
[2012-11-14 10:14:26] Please provide a Gemfile.lock to use auto-reconfiguration.
[2012-11-14 10:14:26] Creating droplet
[2012-11-14 10:14:27] Uploading droplet
[2012-11-14 10:14:29] Done!
New app registered at: http://192.168.1.70:57421
{% endhighlight %}


## DEA requesting a droplet

In the first tutorial on the DEA, I sort of cheated. I did not ask the DEA to fetch the packaged application; rather I put the packaged application on the file system just where it would look for a cached copy.

In this article we want the DEA to do the normal task of downloading the packaged application - called a droplet.

In Cloud Foundry, the Cloud Controller provides an HTTP endpoint for the DEA to download droplets.

{% highlight ruby %}
# config/routes.rb
get    'staged_droplets/:id/:hash' => 'apps#download_staged', :as => :app_download_staged
{% endhighlight %}

We will add a similar route to our fake staging client for the DEA to use.

{% highlight ruby %}
get '/staged_droplets/:id/:hash' do
  p params
  # TODO get path for staged_droplet
  send_file(staged_droplet)
{% endhighlight %}

We can deploy the Sintra app at `apps/sinatra-app.zip` by running a script that combines the staging step and DEA deployment step together:

```
$ ./bin/deploy_app
[2012-11-14 10:14:24] Setting up temporary directories
[2012-11-14 10:14:24] Downloading application
[2012-11-14 10:14:24] Unpacking application
[2012-11-14 10:14:24] Staging application
[2012-11-14 10:14:26] # Logfile created on 2012-11-14 10:14:26 -0800 by logger.rb/31641
[2012-11-14 10:14:26] Auto-reconfiguration disabled because app does not use Bundler.
[2012-11-14 10:14:26] Please provide a Gemfile.lock to use auto-reconfiguration.
[2012-11-14 10:14:26] Creating droplet
[2012-11-14 10:14:27] Uploading droplet
[2012-11-14 10:14:29] Done!
New app registered at: http://192.168.1.70:57421
```
