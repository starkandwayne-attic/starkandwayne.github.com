---
layout: post
title: "Adding Rubinius to Cloud Foundry"
description: "In adding Rubinius to Cloud Foundry it seems that a new runtime to Cloud Foundry requires a few changes in a few places." # Used in /articles.html listing
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
sliders:
- title: "Rubinius on Cloud Foundry"
  text: In adding Rubinius to Cloud Foundry it seems that a new runtime to Cloud Foundry requires a few changes in a few places.
  image: /assets/images/cloudfoundry-235w.png
slider_background: abyss # or parchment,abyss,sky-horizon-sky from /assets/sliders
published: false
publish_date: "2012-11-13"
category: "articles"
tags: [cloudfoundry, ruby]
theme:
  name: smart-business-template
---
{% include JB/setup %}

[Rubinius](http://rubini.us/ "Rubinius : Use Ruby&#8482;") is a new, maturing implementation of Ruby that is "an environment for the Ruby programming language providing performance, accessibility, and improved programmer productivity". In this article, I look at what it took to add a new Ruby runtime into Cloud Foundry. 

In Cloud Foundry there are two axes of specifying how a user's application should be run:

* runtimes - ruby, java, python, php, node.js
* frameworks - ruby on rails, play, spring, wsgi

Adding Rubinius to Cloud Foundry is adding another runtime. As it happens, a runtime that is very similar to two existing runtimes `ruby18` (ruby 1.8.7) and `ruby19` (ruby1.9.2).

Code bases/projects to be changed when adding a new runtime:

* [cf-release](https://github.com/cloudfoundry/cf-release) - the official installer/deployer of Cloud Foundry, which includes the package descriptions of runtimes, as well as configuration files for available runtimes
* [vcap](https://github.com/cloudfoundry/vcap) - alternate installer of Cloud Foundry, which includes the chef-based installer `dev_setup` which duplicates `cf-release` but for Chef; it also submodules other repositories.

We need to update all the Ruby frameworks to support Rubinius.

Fundamentally, `cf-release` and `dev_setup` are responsible for configuring what runtimes are available to Cloud Foundry.

There is existing documentation for [adding a runtime](https://github.com/cloudfoundry/oss-docs/tree/master/vcap/adding_a_runtime) that focuses on the `dev_setup` Chef recipes.

None of the actual code bases, such as [cloud_controller](https://github.com/cloudfoundry/cloud_controller) or  [vcap-staging](https://github.com/cloudfoundry/vcap-staging) need to be updated when we add a new runtime that is a variation of an existing supported runtime.
