---
layout: post
title: "What changed between each Cloud Foundry release?"
description: "The core Cloud Foundry bosh release comes out each week; so what has actually changed?"
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
# main_picture: /assets/articles/images/car.jpg
sliders:
- title: "What changed btw CF releases?"
  text: The core Cloud Foundry bosh release comes out each week; so what has actually changed?
  image: /assets/images/cloudfoundry-235w.png
slider_background: parchment
publish_date: "2013-08-21"
category: "articles"
tags: [cloudfoundry versioning]
theme:
  name: smart-business-template
---
{% include JB/setup %}

If you're running Cloud Foundry v2 then you are no doubt aware via the mailing list that there are new releases coming down the pipeline very regularly. When we're supporting Stark & Wayne customers, the questions we ask are:

* What changed? Is there anything exciting to advertise to our customers or our customers' customers
* What do we need to change in our deployment files?
* Do we need to upgrade anything else as well? (perhaps a newer `cf` CLI; or also required to upgrade bosh itself)
* What's next?

## What changed?

If you're on the vcap-dev mailing list you'll have started to see the announcements from the Core Cloud Foundry team. They are sending out an email announcing each new release, and including a detailed listing of all the code commits that have gone into it from the Core Cloud Foundry projects.

![v138 release](https://www.evernote.com/shard/s3/sh/d951ed28-bc44-4a4c-afbb-0ed626b3691d/1598767086631774c36f83cf86106ae8/deep/0/https://mail-attachment.googleusercontent.com/attachment/u/0/?ui=2&ik=b987093280&view=att&th=140a035c69134e53&attid=0.1&disp=inline&realattid=f_hkmc8zfj0&safe=1&zw&saduie=AG9B_P-iRw-YqX0b56PCw2qAo_rD&sadet=1377107823423&sads=os7sDhR6n--VQ6cusL27dInTNDo.png)

## What do we need to change in our deployment file?

Currently the release email doesn't tell us this. As a temporary fix, we have summarized the changes required in a gist. We're using `git diff` of all the job's spec files.

For example, the changes to all the properties required in the jobs for v137..v138 is:

<script src="https://gist.github.com/drnic/6297584.js?file=cf_jobs_spec_137_to_138.diff"></script>

To read this, if new defaults are added, then there may be properties in your deployment file that can be removed.

More importantly, if there are new properties added that don't include defaults, then you may be required to add a properties to your deployment file (such as `nats.user` on the `dea_logging_agent` job in the v136..v137 example below).

<script src="https://gist.github.com/drnic/6297584.js?file=cf_jobs_spec_136_to_137.diff"></script>

## Do we need to upgrade anything else as well?

This may not be obvious from either of the sections above. Hopefully t