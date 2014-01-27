---
layout: post
title: "BOSH packages with Debian"
description: "If you're in a hurry you can now create BOSH packages using existing Debian packages"
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
# main_picture: /assets/articles/images/car.jpg
sliders:
- title: "BOSH packages with Debian"
  text: "If you're in a hurry you can now create BOSH packages using existing Debian packages"
  image: /assets/images/cloudfoundry-235w.png
slider_background: abyss # or parchment,abyss,sky-horizon-sky from /assets/sliders
publish_date: "2014-01-27"
category: "articles"
tags: [bosh]
theme:
  name: smart-business-template
---
{% include JB/setup %}

TL;DR You can now quickly create a BOSH package using existing .deb files instead of source files.

{% highlight text %}
gem install bosh-gen
bosh-gen packages apache2 --apt
vagrant up
vagrant ssh -c '/vagrant/src/apt/fetch_debs.sh apache2'
vagrant destroy
{% endhighlight %}

Edit the generated `src/apt/apache2/aptfile` to edit the list of .deb packages to be downloaded and later installed.

When your BOSH release uses this package, within a job, all the installed binaries and libraries will be within `/var/vcap/packages/apache2/apt`, and not within the root folder system.

This article coincides with the v0.15.0 release of `bosh-gen`.

## Background

**Did you know** that the `debian_nfs_server` job in cf-release [installs a .deb](https://github.com/cloudfoundry/cf-release/blob/master/jobs/debian_nfs_server/templates/rpc_nfsd_ctl#L8) file rather than using a native compiled-from-source BOSH package? The deb file is stored in the blobs folder and installed each time upon job start.

Some one, once upon a time, had the same issue that many BOSH release authors have: I really don't feel like figuring out how to install this package from source. Why don't I just use the existing Debian package?

There are many answers to "Why not?" But when you're in a hurry, they are all ignorable. You can always come back and write the package from source later, right? If you say so. But let's say you've negotiated with Future You and decided that its ok to use existing Debian packages (perhaps the ones that don't self-configure themselves and automatically start processes). How do you do it?

How do you determine which .deb files to use? I borrowed heavily from David Dollar's [heroku-apt-buildpack](https://github.com/ddollar/heroku-buildpack-apt/blob/master/bin/compile) to determine & download .deb files.

## How it works

**Can they be installed via normal BOSH packages instead of each time a job starts (like debian_nfs_server above)?** The generated packaging script installs the .deb files within the $BOSH_INSTALL_PATH rather than within the root folder, like David Dollar's buildpack. This means that when a package is installed, the effective root folder is /var/vcap/packages/NAME/apt.

**Where are the .deb files stored?** They are blobs and are stored in the blobstore via the blobs/apt/ folder. Here is an example tree view of a bosh release that is using .debs:

{% highlight text %}
$ tree blobs    
blobs
└── apt
    └── apache2
        ├── apache2-mpm-worker_2.2.14-5ubuntu8.12_amd64.deb
        ├── apache2-utils_2.2.14-5ubuntu8.12_amd64.deb
        ├── apache2.2-bin_2.2.14-5ubuntu8.12_amd64.deb
        ├── apache2.2-common_2.2.14-5ubuntu8.12_amd64.deb
        ├── apache2_2.2.14-5ubuntu8.12_amd64.deb
        ├── libapr1_1.3.8-1ubuntu0.3_amd64.deb
        ├── libaprutil1-dbd-sqlite3_1.3.9+dfsg-3ubuntu0.10.04.1_amd64.deb
        ├── libaprutil1-ldap_1.3.9+dfsg-3ubuntu0.10.04.1_amd64.deb
        ├── libaprutil1_1.3.9+dfsg-3ubuntu0.10.04.1_amd64.deb
        └── ssl-cert_1.0.23ubuntu2_all.deb
{% endhighlight %}

**I'm on a Mac, how do I get the .deb files?** Vagrant. Even if you were on an Ubuntu distro when creating your BOSH release, it is important that we download the .debs from the same universe that is compatible with the bosh stemcell being used. Currently the ubuntu bosh-stemcell is 10.04 LTS. Yep, that's (20)10.

When you run "bosh-gen package NAME --apt", a Vagrantfile is created that references the `lucid64` Vagrant box. When you run the `vagrant up` command, this box will be downloaded if you don't have it already. Or if you deleted it years ago.

**How do I access the installed Debian packages from my jobs?** Instead of installing the packages into the root file system, as it would be impossible to then package and re-install the BOSH package when it is needed, the installed files are in the BOSH package folder. This is the same solution that David Dollar used for his Heroku buildpack.

You can see an example of the installed folder structure of the `apache2` BOSH package that is using the `apache2` Debian packages above:

{% highlight text %}
$ tree /var/vcap/packages/apache2/apt | head -n 10
/var/vcap/packages/apache2/apt
├── etc
│   ├── apache2
│   │   ├── apache2.conf
│   │   ├── conf.d
│   │   │   ├── charset
│   │   │   ├── localized-error-pages
│   │   │   └── security
│   │   ├── envvars
│   │   ├── magic
...
{% endhighlight %}

## Tips

**How do I setup environment variables like a normal distro?** Each generated package includes a profile.sh script that your jobs can source to setup environment variables.

{% highlight bash %}
source /var/vcap/packages/apache2/profile.sh
{% endhighlight %}

This profile.sh is initially generated to look like:

{% highlight bash %}
export PATH="/var/vcap/packages/apache2/apt/usr/bin:$PATH"
export LD_LIBRARY_PATH="/var/vcap/packages/apache2/apt/usr/lib:$LD_LIBRARY_PATH"
export INCLUDE_PATH="/var/vcap/packages/apache2/apt/usr/include:$INCLUDE_PATH"
export CPATH="$INCLUDE_PATH"
export CPPPATH="$INCLUDE_PATH"
{% endhighlight %}

**How do I stop .deb packages from automatically starting processes?** Some Googling will help on a case-by-case basis. For example, [this article](http://askubuntu.com/questions/40072/how-to-stop-apache2-mysql-from-starting-automatically-as-computer-starts) discusses what is required to stop MySQL and Apache2 from starting themselves.

**What Vagrant box should I use?** If you are using a newer BOSH stemcell than Ubuntu 10.04, then please update the generated Vagrantfile to reference a similarly matching Vagrant box.

Also, remember to destroy the Vagrant VM after running the `fetch_debs.sh` script.

