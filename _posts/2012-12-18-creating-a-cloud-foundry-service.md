---
layout: post
title: "Creating a Cloud Foundry Service"
description: Inside look into creating a Cloud Foundry Service with Ruby
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
sliders:
- title: "Creating a Service"
  text: Inside look into creating a Cloud Foundry Service with Ruby
  image: /assets/images/cloudfoundry-235w.png
slider_background: ny # or parchment,abyss,sky-horizon-sky from /assets/sliders
publish_date: "2012-12-18"
category: "articles"
tags: [cloudfoundry]
theme:
  name: smart-business-template
---
{% include JB/setup %}

Out of the box, Cloud Foundry comes with a dozen services that you can enable for any of your applications to use.

*  atmos
*  couchdb
*  elasticsearch
*  filesystem
*  memcached
*  mongodb
*  mysql
*  neo4j
*  postgresql
*  rabbit
*  redis
*  vblob

*  echo
*  serialization_data_server

*  marketplace
*  ng
*  service_broker
*  tests
*  tools

The basic processes that a running for each service are:

* A gateway, which wraps a service-specific provisioner class
* A node per service plan, which wraps a service-specific node class
* A worker for background tasks such as importing data (postgresql, mysql, mongodb, redis)
* A backup manager (postgresql, mysql, mongodb, redis)

