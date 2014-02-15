---
layout: post
title: "BOSH: Notes from a beginner"
description: "TWO. SENTENCES." # Used in /articles.html listing
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Bill Chapman"
author_code: byllc
# main_picture: /assets/articles/images/car.jpg
sliders:
- title: "BOSH: Notes from a beginner"
  text:  Notes from bootstrapping bosh lite and creating a first release. 3
  image: /assets/images/cloudfoundry-235w.png
slider_background: ny # or parchment,abyss,sky-horizon-sky from /assets/sliders
publish_date: "2014-02-15"
category: "articles"
tags: []
theme:
  name: smart-business-template
---
{% include JB/setup %}

### Installing Bosh-lite for local development

  * Start [Here](http://starkandwayne.com/articles/2013/12/02/rapid-dev-with-bosh-lite/) S&W Talk on Bosh Lite
  * Then go [Here](https://github.com/cloudfoundry/bosh-lite) Bosh Lite Github

  Getting set up on Mac OS with those two resources above was very quick. There is a lot of set up and tear down so you'll want a good rebuild script to stand up your bosh-lite environment.

```bash
vagrant destroy -f
vagrant up
bosh target 192.168.50.4
bosh login
bosh upload stemcell latest-bosh-stemcell-warden.tgz

#make sure routing rules are set up, otherwise you won't be able to access the VMs
#beyond the bosh director
./scripts/add-route
```

### Creating A Release

#### BOSH Release Recipe

I've started a list of questions you should answer before you begin a Bosh release. If you can't answer these questions, you can't finish the release.  https://gist.github.com/byllc/8870959  Notice there is an example file in for MariaDB.

#### Generators
USE bosh-gen and templates/make_manifest.  You should not create manifest or package/job skeletons by hand. You will miss stuff.



* Often I would get an error "'job_name_0' is not runnning" and this was often confusing because the VM had not actually been created. So this did not mean the job was deployed. Pay attention to the order of operations when you run create, upload or deploy. For example, realizing that I was failing on the compile phase meant that the service vms had not yet been created.

* Be aware what you should and should not run in packaging scripts. You should not run initialization type commands inside of packaging scripts. The packaging scripts are going to run on a compile node and you won't have access to persistent data there. For example,  the initialization scripts for mysql,mariadb, or postgresql.

* There isn't yet a built in way to handle 'run once' requirements. For example a database initialization script that needs populate your persistence store. If you need to keep track of run once requirements remember that your service vm's are mostly transient and any persistent information will need to be in /var/vcap/store or in another persistent service.

* A bosh release is fundamentally just a generic packaging construct that can span multiple virtual machines. Where it extends that construct is in process monitoring and managment but nonetheless it feels very much like packaging something for yum or apt. Realizing this was helpful because package managment frameworks all have to decide where to put stuff and we put stuff in different places. It helped quite a bit to pore over configuration options looking for anything that specified directory paths and make sure you provide them with updated /var/vcap.. paths. Often these paths are set to defaults and will not show up in a config file.

* If in doubt start over. I noticed that while I was poking around on the running bosh vms I would change things for testing purposes or to figure out how to get the services running cleanly. If you've been poking around and things aren't working, remember that the BOSH VM's are supposed to be transient. Tearing them down and starting over is a great test of the clean bootstrap behaviour of your release and it may just get rid of an odd issue or two.

```bash
  bosh delete deployment <deployment-name>
```

* If you need a package to be available in /var/vcap/packages, ensure you have added it as a job dependency. It will not get copied over otherwise.

