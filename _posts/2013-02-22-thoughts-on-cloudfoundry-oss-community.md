---
layout: post
title: "Thoughts on Cloud Foundry's OSS Community"
description: "Interesting changes in Cloud Foundry mailing list activity in January 2013 and what's behind them" # Used in /articles.html listing
icon: group # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
sliders:
- title: "Peak in mailing list traffic"
  text: January 2013 had the highest Cloud Foundry mailing list traffic
  image: /assets/images/cloudfoundry-235w.png
- title: "Healthy communities"
  text: "Healthy open source communites are like all communities: new people helping newer people"
  image: /assets/images/cloudfoundry-235w.png
slider_background: ny # or parchment,abyss,sky-horizon-sky from /assets/sliders
publish_date: "2013-02-22"
category: "articles"
tags: [cloudfoundry]
theme:
  name: smart-business-template
---
{% include JB/setup %}

I was having a chat with a few other Cloud Foundry developers and users over lunch and we all felt that there seems to be a lot of activity on the mailing lists recently. Fortunately, Google Groups actually has a graph for that; and it was impressive!

<img src="/assets/articles/images/vcap-dev-list-traffic-2013-02-22.png">

Throughout 2012, there was a downward trend in mailing list activity from when it was created in April. Last month it jump up to its highest traffic levels!

I'm getting emails from companies looking to get started with Cloud Foundry, which is great. But the mailing list is a special place and its growth in traffic is a very meaningful metric to me. It means more developers and sysadmins are trying it, succeeding with it, and then helping others do the same. I call this a "Healthy Community": new people have success, they turn around and help other new people. Advanced people help the intermediate people. Intermediate people help the beginners.

## What triggered this strong uptick?

Here's a list of events and projects from the last 45 days that might have contributed:

* We moved from the Gerrit-based system for contributions and moved all projects to Github Pull Requests.
* We moved from a Jenkins server to Travis CI for most projects.
* We moved from Jira to Github Issues for all the repositories.
* We started a pair of on-boarding projects to let people deploy Cloud Foundry on top of BOSH without documentation.
* We have a new set of Chef recipes in development to replace the deprecated original vcap scripts.
* We have a new beautiful [documentation site](http://cloudfoundry.github.com/) for core Cloud Foundry; and
* We have an all new [community wiki](https://github.com/mrdavidlaing/cf-docs-contrib/wiki) for the growing collection of extensions, distributions, alternate components, etc.
* The core BOSH release of Cloud Foundry can now successfully runs on AWS (staging branch of cf-release bosh release).
* Early adopters are getting the upcoming v2 components running.

That's a bunch of stuff. A pretty good month or two of the new year. These are things that make it easier for new people to find and join the Cloud Foundry project and community.

Yet at the heart of what's happening is that there are new developers/sysadmins/devops who have asked questions on mailing lists, gotten answers and figured out how to run Cloud Foundry for themselves; and a good portion of those have turned around and helped someone else. Then answered an email or github issue for someone else. I call that a healthy open source community.

## What's next?

Actually, if you're in the Bay Area/Silicon Valley/San Francisco area on March 5th, please come to the great LinkedIn campus in Mountain View where I'm giving a talk on [How to Build your own Heroku with open source Cloud Foundry](http://www.meetup.com/silicon-valley-ruby/events/104290372/). It's a great venue and hopefully I'll bust out a great talk. I know it says "No spots left," but between you and me, come anyway. There's always room for one more.


