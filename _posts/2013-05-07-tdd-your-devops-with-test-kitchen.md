---
layout: post
title: "TDD your DevOps with test-kitchen 1.0"
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

<blockquote>
This is probably the best demonstration I've seen so far showing the TDD process for cookbook development. - Fletcher Nichol
</blockquote>


There is something wonderful coming to devops-land called test-kitchen [1.0](https://github.com/opscode/test-kitchen/tree/1.0#test-kitchen). Its a complete rewrite of old test-kitchen by Fletcher Nichol. Its supposedly agnostic to chef[^agnostic]; yet for chef cookbook development it is going to be huge when you combine it with berkshelf (bundler for cookbooks) and vagrant (friendly local VMs for developers).

How huge? I jammed as much as I know into a 20 minute TDD demo to create a chef cookbook for the [hub](https://github.com/defunkt/hub) project. The resulting repo was called [chef-hub](https://github.com/drnic/chef-hub) and a shared cookbook [hub](http://community.opscode.com/cookbooks/hub).

Watch the video and please let me know in the comments if you'll be switching to test-kitchen?

<object width="560" height="315"><param name="movie" value="http://www.youtube.com/v/0sPuAb6nB2o?hl=en_US&amp;version=3"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><param name="hd" value="1"></param><embed src="http://www.youtube.com/v/0sPuAb6nB2o?hl=en_US&amp;version=3" type="application/x-shockwave-flash" width="560" height="315" allowscriptaccess="always" allowfullscreen="true" hd="1"></embed></object>

## TDD and DevOps

The power of DevOps is bringing developers, agile processes, TDD and continuous delivery all the way down the stack. A devops developer needs to confidently write tests against their ops automation, to iterate on it, and to feel confident that when all the tests pass that the code can ship off to production.

When it comes to testing code that modifies production systems you really want to run integration tests. If you're developing chef cookbooks or bosh releases, then you actually want to bring up running systems and then test that they are as you wish them to be.

And as developers, we want the ability to run these integration tests to fit into our existing workflow. That means it must all work locally from the terminal and work fast. We want to run the tests over and over. Slow tests are tests that developers won't run.

Test-kitchen 1.0 & Vagrant are a great start to 2013 for rapid devops.

## Sharing the cookbook

I didn't show how to share a cookbook in the video. Sadly, the current chef/knife tool doesn't like the `chef-hub` folder name. Grrr. I think cookbooks and their repo/folder names should not be forced to be the same. I want a cookbook `hub` and the repo `chef-hub`.

To upload the cookbook:

{% highlight bash %}
git clone git@github.com:drnic/chef-hub.git hub # not, chef-hub
cd hub
knife cookbook site share hub Utilities -o ..
{% endhighlight %}

That probably needs to go in a rake task `rake share`. Might go do that now[^rakeshare].

[^agnostic]: I haven't seen that feature in action yet
[^rakeshare]: Here is [rake share](https://github.com/drnic/chef-hub/blob/master/Rakefile#L13-L29)