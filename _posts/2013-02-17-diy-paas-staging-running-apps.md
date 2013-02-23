---
layout: post
title: "DIY PaaS - staging & running apps"
description: "TWO. SENTENCES." # Used in /articles.html listing
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
# main_picture: /assets/articles/images/car.jpg
sliders:
- title: "DEA v2"
  text: Stager, buildpacks and warden containers
  image: /assets/images/cloudfoundry-235w.png
slider_background: ny # or parchment,abyss,sky-horizon-sky from /assets/sliders
published: false
publish_date: "2013-02-17"
category: "articles"
tags: [diy-pass, cloudfoundry]
theme:
  name: smart-business-template
---
{% include JB/setup %}

In the [DIY PaaS](/tags.html#diy-paas-ref) articles, we will re-build Cloud Foundry from the ground up piece-by-piece. This is article number 3, and we're going to look at Cloud Foundry v2 for the first time: the next-generation DEA.

This article was going to be a continuation of articles 1 (the DEA) and 2 (the stager). But there is a new DEA in town and it now does its own staging of raw application source code. More importantly it can include Heroku Buildpacks. This means that for the first time, a Cloud Foundry user can override the default runtimes and frameworks when they deploy an application.

The new DEA also includes support for containerization of each running application instance. That's another exciting topic; but will be for another article.

## Preparation

I already have Ruby 1.9.3 & Go 1.0.3 installed and available in my `$PATH`. Yes, the new DEA is built using Ruby and Go.

```
$ ruby -v
ruby 1.9.3p385 (2013-02-06 revision 39114) [x86_64-darwin12.2.0]
$ go version
go version go1.0.3
```

## A DEA in three parts

Each DEA server - where Cloud Foundry application instances are run - has three running parts for it to work:

* The DEA
* Warden
* Director Server

That's three times more pieces than the original DEA; though now each DEA can perform the function of the staging server. The Director Server is written in Go; so getting DEA v2 up and running is more complex than before too.



## Configuration

### DEAs now perform staging

The `dea.yml` now includes configuration for staging:

```yml
staging:
  enabled: true
  max_staging_duration: 120
  max_active_tasks: 10
  staging_base_dir: /var/vcap/data/dea_next/staging
  platform_config:
    cache: /var/vcap/data/stager/package_cache/ruby
  environment:
    C_INCLUDE_PATH: "/var/vcap/packages/mysqlclient/include/mysql:/var/vcap/packages/sqlite/include:/var/vcap/packages/libpq/include:/var/vcap/packages/imagemagick/include/ImageMagick"
    LIBRARY_PATH: "/var/vcap/packages/mysqlclient/lib/mysql:/var/vcap/packages/sqlite/lib:/var/vcap/packages/libpq/lib:/var/vcap/packages/imagemagick/lib"
    LD_LIBRARY_PATH: "/var/vcap/packages/mysqlclient/lib/mysql:/var/vcap/packages/sqlite/lib:/var/vcap/packages/libpq/lib:/var/vcap/packages/imagemagick/lib"
    PATH: "/var/vcap/packages/dea_node08/bin:/var/vcap/packages/git/bin:/var/vcap/packages/imagemagick/bin"
```
