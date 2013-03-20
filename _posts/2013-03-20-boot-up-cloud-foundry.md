---
layout: post
title: "Boot up Cloud Foundry"
description: "Introducing a new toolchain to boot up your own Cloud Foundry on AWS or OpenStack and a one hour walk-thru video"
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
# main_picture: /assets/articles/images/car.jpg
sliders:
- title: "Build your own Cloud Foundry"
  text: Introducing a new toolchain to boot up your own Cloud Foundry on AWS or OpenStack and a one hour walk-thru video
  image: /assets/images/cloudfoundry-235w.png
slider_background: ny # or parchment,abyss,sky-horizon-sky from /assets/sliders
publish_date: "2013-03-20"
category: "articles"
tags: [cloudfoundry video slides]
theme:
  name: smart-business-template
---
{% include JB/setup %}


I am very happy to announce a toolchain for Booting up your own Cloud Foundry installations on AWS and OpenStack. This toolchain involves two projects and requires only a hand-full of commands and you'll have your very own Cloud Foundry! If you've ever wanted to have your own Heroku, you can't unless you become an employee, which sounds like it could get in the way of your social time. But you can have your own Cloud Foundry! It's open source, it works and its fun!

For this release, there is also a 1+ hour talk to watch that was very recently given to a group of 90 people [who had a great time](http://www.meetup.com/silicon-valley-ruby/events/104290372/ "Dr Nic Williams presents &#034;Build your own Heroku with open source Cloud Foundry&#034; -  Silicon Valley Ruby Meetup (San Jose, CA) - Meetup")!

The two projects are:

* [bosh-bootstrap](https://github.com/StarkAndWayne/bosh-bootstrap) - to deploy the deployment service called Bosh (perhaps similar to deploying your own Chef Server)
* [bosh-cloudfoundry](https://github.com/StarkAndWayne/bosh-cloudfoundry/) - to use your Bosh to deploy your very own Cloud Foundry!

The instructions are (though please read the online instructions for the very latest):

{% highlight text %}
gem install bosh-bootstrap
bosh-bootstrap deploy
bosh-bootstrap ssh
bosh cf prepare system demo
bosh cf deploy
{% endhighlight %}

At the bottom of this post is a 1+ hour walk-thru of these steps. Bonus Australian accent included.

How long does this take? Currently it takes about 2-3 hours. Though there is a bunch of core Bosh work coming down the pipeline that will drastically speed this up! Ooh I hope it drops soon!

Want to flick through the slides? [They're on speakerdeck](https://speakerdeck.com/drnic/build-your-own-heroku-with-cloud-foundry).

Thank you very much to everyone who has been using and helping fix and extending this new toolchain. We have very active Cloud Foundry mailing lists and there are a growing number of lovely people who are watching the Issues lists for these two tools.

Thank you also to the Pivotal Initiative who has funded this work for the last 3+ months! Very wonderful new stewards of all things Cloud Foundry indeed!

Thank you to LinkedIn for hosting the meetup and for recording and post-producing a great video.

But now, please enjoy the 1h talk (which actually took 1h 40mins) presented at LinkedIn for the Silicon Valley Ruby Club. We all had a great time and it was great to share it publicly for the first time!

<iframe width="560" height="315" src="http://www.youtube.com/embed/e0EprkBamvQ" frameborder="0" allowfullscreen="1"></iframe>



