---
layout: post
title: "Jenkins builds from CLI"
description: "Command your secure Jenkins CI to run builds with parameters from the CLI" # Used in /articles.html listing
icon: old-man # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
# main_picture: /assets/articles/images/car.jpg
sliders:
- title: "Jenkins builds from CLI"
  text: Command your secure Jenkins CI to run builds with parameters from the CLI
  image: /assets/images/jenkins-256w.png
slider_background: ny # or parchment,abyss,sky-horizon-sky from /assets/sliders
publish_date: "2013-04-12"
category: "articles"
tags: [jenkins, ci]
theme:
  name: smart-business-template
---
{% include JB/setup %}

I discovered that each Jenkins server has a page where you can download a Jenkins CLI. What I wanted to do was script the triggering of Jenkins jobs with custom parameters. Why? That's for another blog post!

But I thought it was non-trivial enough to trigger the build of secure Jenkins job with custom parameters that I wanted to share it.

There are a couple steps:

* download the Java jar
* running commands against a secure Jenkins (basic auth or ssh keys)
* triggering a job build against a secure Jenkins (avoiding a 1.5 year old open bug!)
* passing parameters when triggering a job build

## Download the Java jar

The best place to download the Jenkins CLI jar is from your own Jenkins server. This means you'll have the matching CLI version.

Visit the `/cli` endpoint, such as http://myjenkins/cli, and it will give you a link to download the jar (the `/jnlpJars/jenkins-cli.jar` endpoint).

Download that jar.

It will also tell you how to view all the commands available:

{% highlight bash %}
$ java -jar jenkins-cli.jar -s http://myjenkins help
{% endhighlight %}

## Running commands against a secure Jenkins (basic auth or ssh keys)

If your Jenkins is secured, and it probably is so that you control who can create jobs, run jobs, view results, then the command above may fail and ask for credentials.

You have two options: provide `--username` & `--password` options to every command or provide `-i` option and provide the path to the ssh private key that matches the public key you provided to your user account.

For example:

{% highlight bash %}
$ java -jar jenkins-cli.jar -s http://myjenkins help --username me --password mypassword
$ java -jar jenkins-cli.jar -s http://myjenkins help -i ~/.ssh/id_rsa
{% endhighlight %}

Sadly, the Jenkins CLI doesn't remember these flags and you have to pass them ever single time.

I'm not a security expert, but the former option is the weaker security option. The `mypassword` value will be stored in your shell history and possibly also exposed over network traffic (since the example `http://myjenkins` uses the non-encrypted http protocol).

## Triggering a job build against a secure Jenkins (avoiding a 1.5 year old open bug!)

To trigger building a job you only need to know its name.

{% highlight bash %}
$ java -jar jenkins-cli.jar -s http://myjenkins build 'My Awesome Jenkins Job' -i ~/.ssh/id_rsa
{% endhighlight %}

With a couple of bonus flags, you can have the CLI block and stream all the console output into your terminal:

{% highlight bash %}
$ java -jar jenkins-cli.jar -s http://myjenkins build 'My Awesome Jenkins Job' -i ~/.ssh/id_rsa -s -v
{% endhighlight %}

BUT, the above may not immediately work for you. Why? You could read this 1.5 year-old Jenkins ticket ([JENKINS-11024](https://issues.jenkins-ci.org/browse/JENKINS-11024?focusedCommentId=177140)); or you can skip to the workaround with me!

Go to the `/configure` endpoint (`http://myjenkins/configure`) to edit your global Jenkins settings.

Under "Authorization", you want to turn on "Matrix-based security" and then for the "anonymous" user enable "Read" mode for the "Job" section.

<img src="{{ BASE_PATH }}/assets/articles/images/enable-job-read-access-to-anonymous-user.png">

You can now successfully trigger jobs with the commands above!

## Passing parameters when triggering a job build

Job parameters are a very handy concept. Perhaps you've only ever used Jenkins or another CI system to automatically run builds when a remote SCM/git repo changes. You can also trigger builds manually from within Jenkins. And whilst you're doing that, your job can prompt for parameters to the build.

For example, we have a job named similar to "Deploy XYZ App". It has the git repo hardcoded in the job like a normal build, but when you press "Build", it shows a list of options: string fields, drop-down lists, etc.

When the job runs, you can uses these values anywhere within your job's configuration. Its very cool.

But how to pass those same parameters via the CLI? You use the `-p key=value` flag for each parameter you want to pass.

So our finished product might look like:

{% highlight bash %}
$ java -jar jenkins-cli.jar -s http://myjenkins build 'Deploy XYZ App' -i ~/.ssh/id_rsa -s -v -p target_env=api.cloudfoundry.com -p branch=master
{% endhighlight %}

Hopefully you can imagine wonderful new ways to script Jenkins from now on!


