---
layout: post
title: "Testing Jenkins jobs"
description: "Is it possible to use Jenkins to actually test other Jenkins jobs?" # Used in /articles.html listing
icon: old-man # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
# main_picture: /assets/articles/images/car.jpg
sliders:
- title: "Testing Jenkins jobs"
  text: Is it possible to use Jenkins to actually test other Jenkins jobs?
  image: /assets/images/jenkins-256w.png
slider_background: ny # or parchment,abyss,sky-horizon-sky from /assets/sliders
publish_date: "2013-04-12"
category: "articles"
published: false
tags: [jenkins]
theme:
  name: smart-business-template
---
{% include JB/setup %}

We are using Jenkins to run our tests and to trigger deployments (to Cloud Foundry in our case). We have jobs that trigger other jobs. Those downstream jobs have complex shell scripts. And one of those shell scripts had a bug.

Shouldn't we test our CI jobs just like we use CI to test our code?
