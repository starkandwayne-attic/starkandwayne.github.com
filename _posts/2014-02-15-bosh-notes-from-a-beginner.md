---
layout: post
title: "BOSH: Notes from a beginner"
description: "Notes for starting your first bosh release."
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Bill Chapman"
author_code: byllc
# main_picture: /assets/articles/images/car.jpg
sliders:
- title: "BOSH: Notes from a beginner"
  text:  Notes from bootstrapping bosh lite and creating your first release.
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

 You'll probably also want to create alias for the release build workflow.

 ```bash
  bosh create release --force && bosh upload release && bosh -n deploy
```

### Creating A Release

#### BOSH Release Recipe

I've started a list of questions you should answer before you begin a Bosh release. If you can't answer these questions, you can't finish the release.

https://gist.github.com/byllc/8870959


#### Generators
USE bosh-gen and templates/make_manifest.  You should not create manifest or package/job skeletons by hand. You will miss stuff. If the generator differs from an example you've found online, the generator is probably a newer example and you probably want to follow it's example.

#### Packaging

The packaging aspect is not unlike creating a package for apt, yum, or homebrew. When troubleshooting it helped quite a bit to pore over configuration options looking for anything that specified directory paths and make sure you provide them with updated /var/vcap.. paths. Often these paths are set to defaults and will not show up in a config file. If you are having problems with permissions on files or processes accesing files or directories that do not exist look for compile, runtime, or configuration options that specify directories for your service/process.

Be aware what you should and should not run in packaging scripts. The packaging scripts are going to run on a compile node and you won't have access to persistent data there. For example,  the initialization scripts for mysql,mariadb, or postgresql cannot be run at compile time. Be aware which of your scripts are going to run where, packaging will happen on compile nodes and jobs will run on the bosh vm.

Remember that making changes to a packaging script will force a recompile even if the change is trivial. For packages with a long compile time you want to avoid making lots of trivial changes or formatting adjustments while you are in development. You'll spend a lot of time waiting for compilation to finish. On the other hand if you focus on getting your packaging scripts right first your compiled package will be cached and further bosh deployments will be quick.

If you need a package to be available in /var/vcap/packages, ensure you have added it as a job dependency. It will not get copied over otherwise.

#### Jobs

Bosh-gen will create a monit file and a package_name_ctl file. You should probably leave the monit file alone and focus on the ctl script.

There isn't yet a built in way to handle 'run once' requirements. For example a database initialization script that needs populate your persistence store. If you need to keep track of run once requirements remember that your service vm's are mostly transient and any persistent information will need to be in /var/vcap/store or in another persistent service.


#### Errors and troublshooting

Often I would get an error "'job_name_0' is not runnning" and this was confusing because the VM had not actually been created. This does not always mean that the job is not starting. It is also possible that the bosh virtual machines are not even available.

Once you get through the compile process if the jobs are not starting you'll need to watch the logs. Assuming your config files and compile time options have pointed your logs to the correct location. You can tail the logs on a running bosh vm to see what is happening during bosh deployment process. If no logs are created here than either your service doesn't have logging enabled or the log path is not set correctly.

```bash
  bosh ssh
  tail -f /var/vcap/sys/logs/**/*
```

If in doubt start over. I noticed that while I was poking around on the running bosh vms I would change things for testing purposes or to figure out how to get the services running cleanly. If you've been poking around and things aren't working, remember that the BOSH VM's are supposed to be transient. Tearing them down and starting over is a great test of the clean bootstrap behaviour of your release and it may just get rid of an odd issue or two.


```bash
  bosh delete deployment <deployment-name> --force
```



