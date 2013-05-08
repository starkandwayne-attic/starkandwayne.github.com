---
layout: post
title: "test-kitchen 1.0 is coming"
description: "Screencast showing the powerful rapid devops toolchain using test-kitchen 1.0, berkshelf and vagrant" # Used in /articles.html listing
icon: cutlery # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
sliders:
- title: "test-kitchen 1.0"
  text: Screencast showing the powerful rapid devops toolchain using test-kitchen 1.0, berkshelf and vagrant
  image: /assets/images/doritos_3rd_degree_burn-235w.png
slider_background: parchment # or parchment,abyss,sky-horizon-sky from /assets/sliders
publish_date: "2013-05-07"
category: "articles"
tags: [chef, devops, tdd]
theme:
  name: smart-business-template
---
{% include JB/setup %}

There is something wonderful coming to devops-land called test-kitchen [1.0](https://github.com/opscode/test-kitchen/tree/1.0#test-kitchen). Its a complete rewrite of old test-kitchen by Fletcher Nichol. Its supposedly agnostic to chef[^agnostic]; yet for chef cookbook development it is going to be huge when you combine it with berkshelf (bundler for cookbooks) and vagrant (friendly local VMs for developers).

How huge? I jammed as much as I know into a 20 minute TDD demo to create a chef cookbook for the [hub](https://github.com/defunkt/hub) project. The resulting repo was called [chef-hub](https://github.com/drnic/chef-hub).

Watch the video and please let me know in the comments if you'll be switching to test-kitchen?



The power of DevOps is bringing developers, agile processes, TDD and continuous delivery all the way down the stack. A devops developer needs to confidently write tests against their ops automation, to iterate on it, and to feel confident that when all the tests pass that the code can ship off to production.

When it comes to testing code that modifies production systems you really want to run integration tests. If you're developing chef cookbooks or bosh releases, then you actually want to bring up running systems and then test that they are as you wish them to be.

And as developers, we want the ability to run these integration tests to fit into our existing workflow. That means it must all work locally from the terminal and work fast. We want to run the tests over and over. Slow tests are tests that developers won't run.

Test-kitchen 1.0 & Vagrant are a great start to 2013 for rapid devops.

[^agnostic]: I haven't seen that feature in action yet