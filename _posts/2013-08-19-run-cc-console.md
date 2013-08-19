---
layout: post
title: "Run the cloud controller console in a bosh deployment"
description: "Simple CLI to create & delete Redis services using bosh" # Used in /articles.html listing
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
sliders:
- title: "Run the cloud controller console"
  text: Simple CLI to create & delete Redis services using bosh
  image: /assets/images/cloudfoundry-235w.png
slider_background: abyss
publish_date: "2013-08-19"
published: false
category: "articles"
tags: [cloudfoundry, bosh]
theme:
  name: smart-business-template
---
{% include JB/setup %}


# Run the cloud controller console in a bosh deployment

The Cloud Controller (the API of Cloud Foundry) includes an internal `console` application for you to poke and prod at the database using the internal Cloud Controller ruby models. This can be handy for diagnosis of problems or some cowboy hacking of the production database. Out of the box you can't actually easily run it in production; but it is possible!

{% highlight bash %}
$ sudo su -
$ cd /var/vcap/packages/cloud_controller_ng/cloud_controller_ng
$ mv .bundle{,.production}
$ cat ../packaging
{% endhighlight %}

This will show you how to re-bundle everything. For example, at the time of writing you'd now run:

{% highlight bash %}
bundle_cmd=/var/vcap/packages/ruby/bin/bundle
mysqlclient_dir=/var/vcap/packages/mysqlclient
libpq_dir=/var/vcap/packages/libpq

$bundle_cmd config build.mysql2 --with-mysql-dir=$mysqlclient_dir --with-mysql-include=$mysqlclient_dir/include/mysql
$bundle_cmd config build.pg --with-pg-lib=$libpq_dir/lib --with-pg-include=$libpq_dir/include
$bundle_cmd config build.sqlite3 --with-sqlite3-dir=/var/vcap/packages/sqlite

# finally... bundle for all dependency
$bundle_cmd install
{% endhighlight %}

You now need to run the `bin/console` command once to find out where it is expecting the configuration file to be:

{% highlight ruby %}
$bundle_cmd exec bin/console
... No such file or directory - /var/vcap/data/packages/cloud_controller_ng/17.1/cloud_controller_ng/config/cloud_controller.yml
{% endhighlight %}

The expect folder is hard-baked into the installed cloud_controller_ng package.

Now create the folder and copy in the configuration from the cloud_controller_ng job:

{% highlight bash %}
$ mkdir -p /var/vcap/data/packages/cloud_controller_ng/17.1/cloud_controller_ng/config
$ cp /var/vcap/jobs/cloud_controller_ng/config/cloud_controller_ng.yml \
  /var/vcap/data/packages/cloud_controller_ng/17.1/cloud_controller_ng/config/cloud_controller.yml
{% endhighlight %}

Finally, you can open the cloud_controller console:

{% highlight bash %}
$bundle_cmd exec bin/console
[1] pry(VCAP::CloudController)> 
{% endhighlight %}

