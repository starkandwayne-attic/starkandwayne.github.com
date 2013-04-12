---
layout: post
title: "Coming soon in Bosh"
description: "3 mths since last release and new stuff is coming soon!" # Used in /articles.html listing
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
# main_picture: /assets/articles/images/car.jpg
sliders:
- title: "Coming soon in Bosh"
  text: What's coming soon for Bosh users
  image: /assets/images/cloudfoundry-235w.png
slider_background: ny # or parchment,abyss,sky-horizon-sky from /assets/sliders
publish_date: "2013-04-09"
category: "articles"
tags: [bosh]
theme:
  name: smart-business-template
---
{% include JB/setup %}

I'm a big fan of Bosh, its vision, the people who created at VMWare and the people who are now working on it at Pivotal Initiative. It's a full lifecycle deployment tool for large systems. You can describe every part of the system - packages, processes, servers, and networking - in absolute terms; and then migrate that system from one specific description to another. Upgrade packages, or upgrade process configuration, or scale out servers, or upsize servers, or change networking. It's very awesome. And for the last few months a new group of engineers have been working solidly on Bosh. I started to have a look at what's coming soon and thought you might be interested too!

## Single version number

All parts of bosh are in a single repository but there are many subprojects that make up Bosh (a CLI that you use, an agent that runs on each VM that is being managed, all the parts that run within Bosh itself, etc). Most are released as RubyGems and have each had different versions and the gems were released independently of each other. There were also the stemcells that were published (server images that contain the bosh agent) which version numbers that didn't map to any other version number.

So you never really knew what version of each part worked with microbosh stemcell or a base bosh stemcell.

The next version of Bosh will be shipped as v1.5.0 and every part of it will be tagged v1.5.0: the CLI, the microbosh stemcell, the base stemcell, and the bosh projects themselves. It should now be much more obvious what versions work with each other!

Some things are easier to upgrade than others and different people are responsible for their upgrade. And what is the sequence of upgrades? Do you have to upgrade to the latest bosh_cli gem, then upgrade your running bosh, and then upgrade the stemcells of your running deployments (such as Cloud Foundry)?

I think you are not likely to want to upgrade stemcells too often (it might take a few hours to replace every VM in your 100 or 1000 VM deployment of Cloud Foundry); but will want to keep upgrading your CLI and BOSH itself.

How can we test that all these parts work together? How might we test that newer versions of BOSH work with older stemcells? Automated testing of course.

## Automated tests

An incredible amount of energy has been spent in the last few months on new test harnesses for Bosh. Some of it is [running on Travis](https://travis-ci.org/cloudfoundry/bosh) and the much longer running tasks are running on a (currently private) Jenkins.

As the test suite gets better and better, the resulting stemcells and code bases are better and better candidates for continuous deployment of bosh.

But my favourite part of the new automated test work is the automated build system for artifacts - stemcells and AWS AMIs are being constantly published!

They are a little hard to find, so let me show you how to get them.


