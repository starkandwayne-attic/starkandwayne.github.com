---
layout: post
title: "Ruby console for Jenkins"
description: "Explore the inner workings of a running Jenkins server with a Ruby console using Pry" # Used in /articles.html listing
icon: old-man # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
sliders:
- title: "Ruby console for Jenkins"
  text: Explore the inner workings of a running Jenkins server with a Ruby console using Pry
  image: /assets/images/jenkins-256w.png
slider_background: sky-horizon-sky # or parchment,abyss,sky-horizon-sky from /assets/sliders
publish_date: "2013-04-22"
category: "articles"
tags: [jenkins, ruby]
theme:
  name: smart-business-template
---
{% include JB/setup %}

We're using Jenkins, we want to create Jenkins plugins and we're looking at using the [jenkins.rb](https://github.com/jenkinsci/jenkins.rb) project to create those plugins in Ruby. Very exciting technology that was created by Charles Lowell and Jenkins' Kohsuke himself.

Jenkins is written in Java, runs on the JVM, and it wasn't at all obvious how I could "just poke around" a running Jenkins server.

Fortunately, Kohsuke wrote an incredible plugin [Pry](https://wiki.jenkins-ci.org/display/JENKINS/Pry+Plugin). Once it is installed, the Jenkins CLI will include a `pry` command.

Say you're running Jenkins server locally, then download the CLI jar file from http://localhost:8080/jnlpJars/jenkins-cli.jar; then run:

{% highlight bash %}
$ java -jar jenkins-cli.jar -s http://localhost:8080 pry
[1] pry(Launcher)>
{% endhighlight %}

Hurray!

## Mapping Jenkins Java to Ruby

You can now navigate around Jenkins.

By default, there is a `jenkins` object which represents the Jenkins instance, the root of the object tree. This can also be discovered via `Jenkins.getInstance()` within your plugins.

{% highlight ruby %}
> jenkins
=> #<Java::HudsonModel::Hudson:0x1251dee1>
> Java.jenkins.model.Jenkins.getInstance
=> #<Java::HudsonModel::Hudson:0x1251dee1>
{% endhighlight %}

To see how many items (Projects, etc) you have, you can invoke the `getItems` method, with or without a filter class. Remember, when invoking the Java methods to pass Java objects/classes (the `java_class` method is helpful here).

{% highlight ruby %}
> jenkins.getItems.size
=> 3
> jenkins.getItems.first                                               
=> #<Java::HudsonModel::FreeStyleProject:0x7e2b2718>
> jenkins.getItems(Java.hudson.model.FreeStyleProject.java_class).size
=> 3
{% endhighlight %}

`Java.hudson.model.FreeStyleProject` maps to the [hudson.model.FreeStyleProject](https://github.com/jenkinsci/jenkins/blob/master/core/src/main/java/hudson/model/FreeStyleProject.java) class.

The parameterized `Hudson#getItems(javaClass)` actually maps to the [Jenkins class's method](https://github.com/jenkinsci/jenkins/blob/master/core/src/main/java/jenkins/model/Jenkins.java#L1374-L1383).

There is a lot more to discover but at least you now know how to get into a running Jenkins server and explore the object model!