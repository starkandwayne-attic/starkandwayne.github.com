---
layout: post
title: "Logging BOSH jobs"
description: "TWO. SENTENCES." # Used in /articles.html listing
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
# main_picture: /assets/articles/images/car.jpg
sliders:
- title: "Watching BOSH jobs logs"
  text: PUT A COOL SUMMARY HERE
  image: /assets/images/cloudfoundry-235w.png
slider_background: ny # or parchment,abyss,sky-horizon-sky from /assets/sliders
publish_date: "2013-01-03"
category: "articles"
tags: []
theme:
  name: smart-business-template
---
{% include JB/setup %}

Either:

bosh ssh jobname 0
or
ssh vcap@IP
(password c1oudc0w by default)

To watch the agent logs:

sudo tail -f -n 200 /var/vcap/bosh/log/current


Things you'll see:

* discovery of infrastructure settings from director
* mounts & formats the root volume (takes about 4 mins)
* mounts & formats the persistent disk (optional)
* mounting of persistent volumes
* downloading of blobs (packages and jobs)
* NATS messaging traffic between the job VM agent and BOSH
* Regular dumps of the agent's state
