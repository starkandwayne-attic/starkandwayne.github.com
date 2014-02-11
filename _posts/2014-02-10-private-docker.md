---
layout: post
title: "Playing with Private Docker"
description: "Exploring Docker with a private registry" # Used in /articles.html listing
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
# main_picture: /assets/articles/images/car.jpg
sliders:
- title: "Playing with private Docker"
  text: Exploring Docker with a private registry
  image: /assets/images/docker-235w.png
slider_background: parchment # or parchment,abyss,sky-horizon-sky from /assets/sliders
publish_date: "2014-02-10"
category: "articles"
tags: [docker]
theme:
  name: smart-business-template
---
{% include JB/setup %}

We've recently become interested in the future of Docker. Why? not so much for its Linux container (LXC) technology or its nifty social integration (docker push & pull), but for its approach to packaging. Each docker repository contains a base Linux distro, all the dependencies pre-installed, and the target project(s) installed.

This is exciting for several reasons. One is that you build Docker repositories (by hand if you really want) once, and reuse that artifact again and again. The other is that your system no longer has any remote dependencies. Never again will your CI build fail because RubyGems or GitHub is down.

Third, you can create your Docker repositories on your personal computer, with access to the public Internet, and then take them into your private data center which is deprived of Internet access.

The core of this solution is to run your own standalone private Docker registry. How do you run a private registry? How do you push repositories (and the images that make them up) to one? How do you pull the images back down to a fresh Docker server and run them?

I'm glad you asked. The tutorial that follows assumes you're on a Linux machine with the docker CLI available in your path. It doesn't assume that you have a docker server running already. We'll run new ones.

Running local fresh docker in a terminal:

{% highlight text %}
mkdir -p /home/core/docker1
sudo docker -d -g /home/core/docker1 -p /var/run/docker1.pid -H tcp://127.0.0.1:5011
{% endhighlight %}

Pulling ubuntu image from public registry into that docker (in another terminal):

{% highlight text %}
$ docker -H tcp://localhost:5011 pull ubuntu:13.04
Pulling repository ubuntu
eb601b8965b8: Download complete 
511136ea3c5a: Download complete 
f323cf34fd77: Download complete 
$ docker -H tcp://localhost:5011 images           
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
ubuntu              13.04               eb601b8965b8        6 days ago          166.5 MB
{% endhighlight %}

Run a private registry (within a docker container, hey, why not?)

{% highlight text %}
git clone https://github.com/drnic/docker-registry-dockerfile.git
cd docker-registry-dockerfile
git submodule update --init
docker -H tcp://localhost:5011 build -t registry .
docker -H tcp://localhost:5011 run -p 5000:5000 -v $(pwd)/cache:/registry registry
{% endhighlight %}

Note, the stored files of this private registry is on the host machine and so will survive restarts of the docker-registry docker container.

Tag and push the downloaded image to the private registry:

{% highlight text %}
$ docker -H tcp://localhost:5011 tag ubuntu:13.04 localhost:5000/ubuntu-13.04

$ docker -H tcp://localhost:5011 push localhost:5000/ubuntu-13.04
The push refers to a repository [localhost:5000/ubuntu-13.04] (len: 1)
Sending image list
Pushing repository localhost:5000/ubuntu-13.04 (1 tags)
511136ea3c5a: Image successfully pushed 
f323cf34fd77: Image successfully pushed 
eb601b8965b8: Image successfully pushed 
Pushing tags for rev [eb601b8965b8] on {http://localhost:5000/v1/repositories/ubuntu-13.04/tags/latest}
{% endhighlight %}

Running local fresh docker in another terminal:

{% highlight text %}
mkdir -p /home/core/docker2
sudo docker -d -g /home/core/docker2 -p /var/run/docker2.pid -H tcp://127.0.0.1:5012
{% endhighlight %}

Now, you can run a new container in the new docker daemon based on the private registry image:

{% highlight text %}
$ docker -H tcp://localhost:5012 run localhost:5000/ubuntu-13.04 echo hello world
Unable to find image 'localhost:5000/ubuntu-13.04' (tag: latest) locally
Pulling repository localhost:5000/ubuntu-13.04
f323cf34fd77: Download complete 
511136ea3c5a: Download complete 
eb601b8965b8: Download complete 
hello world
{% endhighlight %}

Now the fresh docker daemon has the private `localhost:5000/ubuntu-13.04` repository downloaded and can be reused again quickly:

{% highlight text %}
$ docker -H tcp://localhost:5012 run localhost:5000/ubuntu-13.04 echo hello world
hello world
{% endhighlight %}
