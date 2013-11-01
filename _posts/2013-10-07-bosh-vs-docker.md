---
layout: post
title: "BOSH vs Docker vs Packer: packaging immutable services"
description: "Is the next age of packaging immutable services"
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
# main_picture: /assets/articles/images/car.jpg
sliders:
- title: "BOSH vs Docker vs Packer"
  text: packaging immutable services
  image: /assets/images/cloudfoundry-235w.png
slider_background: ny # or parchment,abyss,sky-horizon-sky from /assets/sliders
publish_date: "2013-10-07"
category: "articles"
tags: [cloudfoundry docker]
theme:
  name: smart-business-template
---
{% include JB/setup %}

"I skate to where the puck is going to be, not where it has been." - [Wayne Gretzky](http://en.wikipedia.org/wiki/Wayne_Gretzky)

In our profession of running production systems, there are many things continuously changing. Continuous delivery means our bespoke web services/apps are changing several times a day. The engineering teams are rewriting everything in flight. You are either switching from SQL to NoSQL, or back again. Your total system footprint is growing in scale and complexity. You're trying out new ways to monitor and alert. More monitoring and less alerting, preferably. Within the swirl of continuous change we take quiet comfort in the few things that don't change. For example, installing pre-packaged software.

Somewhere out there is a group of people curating a set of software packages that "just work". This is a blissful thought. Sadly, for many of us, its decreasingly accurate. The converse is true. Our production systems are increasingly departing from RHEL and Ubuntu standard packages and away from their base operating systems/kernels. This trend away from curated constructs to self-created systems is hopefully temporary. It is expensive for everyone to be creating their own bespoke Chef/Puppet implementation of PostgresSQL. But I do not think we will return to "standard packages". Instead we will stabilize around new curated constructs: packaged services.

Another trend is towards [immutable servers](http://martinfowler.com/bliki/ImmutableServer.html "ImmutableServer")/[disposable components](http://chadfowler.com/blog/2013/06/23/immutable-deployments/ "Trash Your Servers and Burn Your Code: Immutable Infrastructure and Disposable Components - Chad Fowler"). The two linked articles discuss the problems and solutions at the granularity of servers or virtual servers. The latter term "disposable components" does allow from some flexibility in thinking. We want the components of our production systems to be immutable. "Build a new, upgraded system and throw the old one away."

These two trends were triggered because there is new technology to help the people with the actual problem.

## The road we travel

We started creating our own bespoke services and their packages [because we had to](https://github.com/jordansissel/fpm#backstory). Puppet and Chef allow us to converge our servers towards the exact services we want to run.

This same work can be pre-baked before a server is provisioned with tools like [fpm](https://github.com/jordansissel/fpm) and [brew2deb](https://github.com/tmm1/brew2deb).


## In the end?

What hasn't happened yet is the creation of the next Red Hat or Canonical. The company that curates, packages, sells and supports immutable services.

