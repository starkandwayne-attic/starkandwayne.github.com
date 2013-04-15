---
layout: post
title: "Deploy Cloud Foundry apps with Jenkins"
description: "Automate and audit your app deployments to Cloud Foundry with Jenkins" # Used in /articles.html listing
icon: old-man # see http://wbpreview.com/previews/WB07233L7/icons.html
author: "Dr Nic Williams"
author_code: drnic
sliders:
- title: "Deploy CF app with Jenkins"
  text: Automate and audit your app deployments to Cloud Foundry with Jenkins
  image: /assets/images/cloudfoundry-235w.png
- title: "Let anyone do the Deploy"
  text: Managers can do Cloud Foundry deployments too with Jenkins
  image: /assets/images/jenkins-256w.png
slider_background: parchment # or parchment,abyss,sky-horizon-sky from /assets/sliders
publish_date: "2013-04-14"
category: "articles"
tags: [cloudfoundry, jenkins]
theme:
  name: smart-business-template
---
{% include JB/setup %}

Cloud Foundry comes with two ways for users to deploy their applications - a command-line tool and [an extension for Eclipse](http://docs.cloudfoundry.com/tools/STS/configuring-STS.html "Cloud Foundry | Installing Cloud Foundry Integration for Eclipse"). The former requires Ruby to be correctly installed and the user to be comfortable with using a terminal; the latter requires Eclipse to be installed. Both requires that the user performing the deployment has the application downloaded to their local machine. 

There are potentially three drawbacks for some teams:

1. They are deployment tools designed first-and-foremost for the application developers who are comfortable with using terminal commands (definitely not every developer; let alone every team member).
2. They also lack any audit trail of who deployed what and to where.
3. Cloud Foundry deployments involve downtime. We'd like zero-downtime deployments.

At one Stark & Wayne client we've been solving both of these problems with another tool we use constantly: [Jenkins](https://wiki.jenkins-ci.org/display/JENKINS/Meet+Jenkins).

When someone wants to deploy an app, they click "Build" on the corresponding Jenkins job and they see a parameterized form like this:

<img src="{{ BASE_PATH }}/assets/articles/images/deploy-app-parameterized-jenkins-job.png">

When the Jenkins user fills out this form and presses "Build" the application will be fetched from source control, its asset pipeline built (for a Rails application), the application deployed to Cloud Foundry, and the public URL remapped.

## Scripting deployment to Cloud Foundry

From the example above, you can see we run multiple Cloud Foundry installations and we can deploy the same app to anyone of them. The base URI is the parameter. The Cloud Foundry API URI has a `api.` prefixed to it.

To perform the deployment, we have an `Execute shell` task that looks similar to:

{% highlight bash %}
#!/bin/bash

# Expected variables:
# $cf_env - the base domain for the CF env, such as apaas.integration.dev
# $application_name - the specific app name
# $password - the password for the login/user to CF env
# $login - override the default CF env user

source ~/.rvm/scripts/rvm
type rvm | head -n 1

rvm use ruby-1.9.3-p385@techno --create
bundle --without development test
bundle exec rake assets:precompile

if [[ "${application_name}X" == "X" ]]; then
  echo "Must provide $application_name parameter"
  exit 1
fi

repo_app_name="xyz"
application_name=${application_name:-repo_app_name}
deployment_app_name="${application_name}-${BUILD_NUMBER}"
internal_app_url="$deployment_app_name.$cf_env"
map_url=${map_url:-"${application_name}.$cf_env"}
cf_instances=${cf_instances:-1}

api_url="api.$cf_env"

# find previous techno apps that has the public DNS (should be 1, might be more accidentally)
previous_app_names=$(svmc apps | grep " ${map_url}" | awk '{print $2 }')
echo "Currently deployed public version is ${previous_app_names:-'(none)'}"

# patch application name in manifest.yml
sed -i -e "s/name: $repo_app_name/name: $deployment_app_name/g" "manifest.yml"

# build information for about page
build_info="./build_info.txt"
cat /dev/null > $build_info
echo "GIT_COMMIT=$GIT_COMMIT" >> $build_info
echo "BUILD_ID=$BUILD_ID" >> $build_info
echo "BUILD_NUMBER=$BUILD_NUMBER" >> $build_info
echo "BUILD_URL=$BUILD_URL" >> $build_info

svmc target $api_url
svmc login --email $login  --passwd $password
svmc delete "$deployment_app_name" || true
svmc push --runtime ruby193 --path . --instances $cf_instances

if [[ ! "${previous_app_names}X" == "X" ]]; then
  echo "Unmapping old DNS $map_url..."
  for name in $previous_app_names
  do
    svmc unmap $name $map_url
  done
fi

echo "Mapping DNS $map_url..."
svmc map $deployment_app_name $map_url

echo "Shutting down previous apps..."
if [[ ! "${previous_app_names}X" == "X" ]]; then
  echo "Unmapping old DNS $map_url..."
  for name in $previous_app_names
  do
    svmc stop $name
  done
fi
{% endhighlight %}

## Parameterized jobs

Jenkins job parameters are fantastic. The values you provide (or the pre-populated default values) are stored as environment variables for the job and can be used in all parts of the Jenkins job when its running ("during a build").

To make a job parameterized when editing the Jenkins job, you click "This build is parameterized" under "Meta Data" section. Then add one or more parameters. Each can be of a different type: text, string (used for most parameters above), password (used for the field ... oh its called `password` how clever), choice (drop-down used for `cf_env` parameter above), boolean (used for `map_url` parameter above), file, git, and more.

## Zero downtime deployment

Instead of re-deploying an application when this deployment job is run, we actually deploy a branch new application in parallel with the existing application. When it has finished its deployment, the last step is to map the public URL from the original 
