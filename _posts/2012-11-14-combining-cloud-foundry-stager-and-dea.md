---
layout: post
title: "Combining Cloud Foundry Stager and DEA"
description: The Stager converts apps into droplets. The DEA for deploys the droplets. In this article we put them together.
icon: cloud # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
# main_picture: /assets/articles/images/car.jpg
sliders:
- title: "Stage then deploy"
  text: The Stager converts apps into droplets. The DEA for deploys the droplets. Let's put them together.
  image: /assets/images/cloudfoundry-235w.png
slider_background: sky-horizon-and-grass # or parchment,abyss,sky-horizon-sky from /assets/sliders
publish_date: "2012-11-14"
category: "articles"
tags: [cloudfoundry]
theme:
  name: smart-business-template
---
{% include JB/setup %}

We are going to run the small set of services and a script that composes them together.

## Quick demo

If you just want to see the Stager and DEA working together (albeit independently via a controller script) to deploy an application then follow the quick commands below.

{% highlight bash %}
$ git clone git://github.com/StarkAndWayne/deploying-thru-cloudfoundry-stager-dea.git
$ cd deploying-thru-cloudfoundry-stager-dea
$ git submodule update --init
$ rake bundle_install
$ foreman start
10:13:18 nats.1          | started with pid 52551
10:13:18 dea.1           | started with pid 52552
10:13:18 stager.1        | started with pid 52553
10:13:18 stager_client.1 | started with pid 52554
...
{% endhighlight %}

In another terminal run the demo script that deploys an app through the stager to the DEA:

{% highlight bash %}
$ ./bin/deploy_app
Requesting stager to fetch app, stage it and upload back to fake server
[2012-11-14 12:55:03] Setting up temporary directories
[2012-11-14 12:55:03] Downloading application
[2012-11-14 12:55:03] Unpacking application
[2012-11-14 12:55:03] Staging application
[2012-11-14 12:55:05] # Logfile created on 2012-11-14 12:55:05 -0800 by logger.rb/31641
[2012-11-14 12:55:05] Auto-reconfiguration disabled because app does not use Bundler.
[2012-11-14 12:55:05] Please provide a Gemfile.lock to use auto-reconfiguration.
[2012-11-14 12:55:05] Creating droplet
[2012-11-14 12:55:05] Uploading droplet
[2012-11-14 12:55:07] Done!
Now finding a DEA to deploy to
Asking DEA f595bf2042b1bc60a10ee9edbfdac29d to deploy droplet
New app registered at: http://172.20.10.2:57939
{% endhighlight %}


## DEA requesting a droplet

In the first tutorial on the DEA, I sort of cheated. I did not ask the DEA to fetch the packaged application; rather I put the packaged application on the file system just where it would look for a cached copy.

In this article we want the DEA to do the normal task of downloading the packaged application - called a droplet.

In Cloud Foundry, the Cloud Controller provides an HTTP endpoint for the DEA to download droplets.

{% highlight ruby %}
# config/routes.rb
get    'staged_droplets/:id/:hash' => 'apps#download_staged', :as => :app_download_staged
{% endhighlight %}

We will add a similar route to our fake staging client for the DEA to use.

{% highlight ruby %}
get '/staged_droplets/:id/:hash' do
  stored_droplet = File.join(droplet_dir, params[:id])
  if File.exists?(stored_droplet)
    send_file(stored_droplet)
  else
    404
  end
end
{% endhighlight %}

In the same app from the staging article, we need to update its upload endpoint to save the uploaded droplet.

{% highlight ruby %}
post '/upload_droplet/:id/:upload_id' do
  src_path = params[:upload][:droplet][:tempfile]
  stored_droplet = File.join(droplet_dir, params[:id])
  File.open(stored_droplet, "w") do |file|
    file << params[:upload][:droplet][:tempfile].read
  end
end
{% endhighlight %}

Finally, we need a script to ask the stager to create a droplet and then find and ask the DEA to deploy it ([bin/deploy_app](https://github.com/StarkAndWayne/deploying-thru-cloudfoundry-stager-dea/blob/master/bin/deploy_app)).

{% highlight ruby %}
NATS.start do
  # 1. queue request to stage an application
  # 2. find a DEA and tell it where to download droplet
  
  staging_request = {
    ...
  }
  
  NATS.request(QUEUE, staging_request.to_json) do |result|
    output = JSON.parse(result)
    puts output["task_log"]
    
    dea_discover = {
      ...
    }
    NATS.request('dea.discover', dea_discover.to_json) do |response|
      dea = JSON.parse(response)
      dea_uuid = dea['id']
      dea_app_start = {
        ...
        sha1: sha1,
        executableUri: "#{stager_client}/staged_droplets/#{app_id}/#{sha1}",
        executableFile: "ignore-unless-shared-filesystem",
        name: app_name,
        ...
      }

      NATS.publish("dea.#{dea_uuid}.start", dea_app_start.to_json)

      NATS.subscribe("router.register") do |msg|
        new_app = JSON.parse(msg)
        host, port = new_app["host"], new_app["port"]
        puts "New app registered at: http://#{host}:#{port}"
        NATS.stop
      end
    end
  end
end
{% endhighlight %}

It is the `executableUri` value that tells the DEA where to fetch a droplet, so we point it to our local staging client (probably running at http://localhost:9292).

We can deploy the Sintra app at `apps/sinatra-app.zip` by running a script that combines the staging step and DEA deployment step together:

{% highlight bash %}
$ ./bin/deploy_app
Requesting stager to fetch app, stage it and upload back to fake server
[2012-11-14 12:55:03] Setting up temporary directories
[2012-11-14 12:55:03] Downloading application
[2012-11-14 12:55:03] Unpacking application
[2012-11-14 12:55:03] Staging application
[2012-11-14 12:55:05] # Logfile created on 2012-11-14 12:55:05 -0800 by logger.rb/31641
[2012-11-14 12:55:05] Auto-reconfiguration disabled because app does not use Bundler.
[2012-11-14 12:55:05] Please provide a Gemfile.lock to use auto-reconfiguration.
[2012-11-14 12:55:05] Creating droplet
[2012-11-14 12:55:05] Uploading droplet
[2012-11-14 12:55:07] Done!
Now finding a DEA to deploy to
Asking DEA f595bf2042b1bc60a10ee9edbfdac29d to deploy droplet
New app registered at: http://172.20.10.2:57939
{% endhighlight %}

