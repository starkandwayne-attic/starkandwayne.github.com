---
layout: post
title: "Seed a CloudFoundry DB"
description: "How do you upload seed data to your CloudFoundry production database?" # Used in /articles.html listing
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
sliders:
- title: "How to upload data to your db"
  text: How do you upload seed data to your CloudFoundry production database?
  image: /assets/images/cloudfoundry-235w.png
slider_background: ny # or parchment,abyss,sky-horizon-sky from /assets/sliders
publish_date: "2013-01-11"
category: "articles"
tags: [cloudfoundry, rails]
theme:
  name: smart-business-template
---
{% include JB/setup %}

It is not obvious how to upload sample or seed data into a postgres or mysql database for your Rails application.

```
vmc tunnel postgresql_techno
```

And look for the following in the output:

```
  username : USERNAMESTRING
  password : PASSWORDSTRING
  name     : DATABASENAMESTRING

Starting tunnel to postgresql_techno on port PORTNUMBER.
```

Take these 4 ALLCAPS values and you put them into your `config/database.yml`. Down at the bottom of the file:

``` yaml
production:
  <<: *defaults
  port: PORTNUMBER
  username: USERNAMESTRING
  password: PASSWORDSTRING
  database: DATABASENAMESTRING
```

In the terminal session running `vmc tunnel` above, press "1" to open the tunnel to the remote postgresql to the local port specified (e.g. 10001).

In another terminal session, run the following rake task on the production database:

```
RAILS_ENV=production rake db:migrate db:seed
```
