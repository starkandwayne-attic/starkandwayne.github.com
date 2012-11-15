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

From an application's perspective, a service could be access to PostgreSQL, Redis, or RabbitMQ that runs within Cloud Foundry. Or it could be a database or message bus running outside of Cloud Foundry. Or it could be a 3rd-party hosted application, such as MongoHQ. Access to a filesystem is a service.

An application could manually configure itself to connect ("bind" in Cloud Foundry vernacular) to services. If you deploy a Rails application, your application could come with a `config/database.yml` that configures to a pre-existing (legacy!) SQL database being managed by your DBAs or a 3rd party provider.

There is also a very helpful feature of Cloud Foundry to enable provisioning and binding of services to applications. Your new application needs a new PostgreSQL database? Quickly provisioned and then quickly bound to your application.

In this article I wanted to investigate the way that very different services have a uniform way to be provisioned and bound, even though they are all different from each other.

## Gateways and Nodes

Service gateways advertise the existence of a service. That is a PostgreSQL Gateway advertises that PostgreSQL is available for applications. Service nodes perform provisioning requests. That is a PostgreSQL Node creates new databases within a running PostgreSQL for each provisioning request.

Service gateways route provisioning requests to Service Nodes.

Applications then talk directly to the Service. That is, the gateways and nodes are only for management and administration. They are not part of the implementation of each service.

## Where is the code?

The specific services that come with Cloud Foundry are implemented in [vcap-services](https://github.com/cloudfoundry/vcap-services). Each service implementation reuses a common [vcap-services-base](https://github.com/cloudfoundry/vcap-services-base) library.

{% highlight bash %}
git clone git://github.com/cloudfoundry/vcap-services.git
git clone git://github.com/cloudfoundry/vcap-services-base.git
{% endhighlight %}


## Coming in the future

Perhaps move to another article

* Service gateways advertise different versions of a service to Cloud Controller
* Service nodes advertise which versions they support to gateway
* User selects which version they want to provision
* Plans are a set of service parameters/configuration (size, max concurrent requests, cache size)
* Gateway routes provisioning request to Node based on version and plan
