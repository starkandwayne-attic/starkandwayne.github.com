---
layout: post
title: "Bare minimum Clound Foundry - provisioning services"
description: "Most applications need services: databases, message buses, and caches. In this article I look at how they work in isolation from the rest of Cloud Foundry."
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
sliders:
- title: "Provisioning Services"
  text: "Most applications need services such as databases, message buses, and caches. Let's look at how services work in Cloud Foundry in isolation."
  image: /assets/images/cloudfoundry-235w.png
slider_background: sheep # or parchment,abyss,sky-horizon-sky from /assets/sliders
publish_date: "2012-11-14"
category: "articles"
tags: []
theme:
  name: smart-business-template
---
{% include JB/setup %}

There are two primary tasks that a PaaS such as Cloud Foundry performs: to run your application code, and to bind those applications to services.

From an application's perspective, a service could be access to PostgreSQL, Redis, or RabbitMQ that runs within Cloud Foundry. Or it could be a database or message bus running outside of Cloud Foundry. Or it could be a 3rd-party hosted application, such as MongoHQ.
