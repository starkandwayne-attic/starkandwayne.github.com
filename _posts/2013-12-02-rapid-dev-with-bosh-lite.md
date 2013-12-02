---
layout: post
title: "Rapidly develop BOSH releases with bosh-gen and bosh-lite"
description: "Watch this short 17min video to see how quickly you can create, deploy and release a system with BOSH"
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
# main_picture: /assets/articles/images/car.jpg
sliders:
- title: "Rapid dev with bosh-lite"
  text: Quickly you can create, deploy and release a system with BOSH
  image: /assets/images/cloudfoundry-235w.png
slider_background: ny # or parchment,abyss,sky-horizon-sky from /assets/sliders
publish_date: "2013-12-02"
category: "articles"
tags: []
theme:
  name: smart-business-template
---
{% include JB/setup %}

It's almost faster to create a BOSH release, iteratively deploy it and test it, then share a final documented release with the world than it is learn "what is BOSH again?" At Stark & Wayne we love BOSH, so here we go again to show how delicious this technology is for the development side. In just 17 minutes, I will start from scratch and create a clustered Redis deployment: one master and two slaves. I'll also show how to "create a final release" that anyone else can then use.

This efficiency is thanks to two tools:

* [bosh-lite](https://github.com/cloudfoundry/bosh-lite#bosh-lite) - a local version of BOSH running under Vagrant
* [bosh-gen](https://github.com/cloudfoundry-community/bosh-gen#bosh-generators) - a CLI for generating new BOSH releases, and the packages and jobs within it.

## Easy for any config management exploration

Even if you're not looking to use BOSH for your production systems, the bosh-lite/bosh-gen combination is a great way to experiment with single node and clustered node versions of your systems or some new services you've discovered.

## Errata

The tutorial can be followed along with generous use of the pause button and some errata below.

The video does not show me modifying `examples/bosh-lite-cluster.yml` file to add the `properties.redis.master` property:

{% highlight yaml %}
properties:
  redis:
    master: 10.244.0.6
{% endhighlight %}

As you develop your own releases you should update the generated examples files so that your README "just works" for other people.

Also, remember to create the S3 bucket for your project. If you ran `bosh-gen new myproject` then you need to create an S3 bucket called `myproject-boshrelease`.

## The video

<iframe width="540" height="380" src="//www.youtube.com/embed/q6NUKzTqaTI" frameborder="0" allowfullscreen="1"></iframe>


