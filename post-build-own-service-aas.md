A Proposal for a Standard API for Services as a Service

When you run MySql daemon, to create a database and a user to access it requires MySQL specific instructions and a MySql client library. 

{% highlight sql %}
CREATE DATABASE myappdb_production;
CREATE USER dasdfohsdjhsadf;
etc...
{% endhighlight %}

This pattern extends to many services. Each has their own API and even client libraries for creating independent instances of their service and user access. And then deleting users and service instances. All bespoke.

Instead, let's provide an HTTP API for each service. Simple actions: create service, create user binding, delete user binding, delete service, and catalog of options.

A consistent, common API that any service - from databases to your own web applications - will implement. A de facto standard. Either the service itself implements the HTTP API or it would be implemented by a collocated broker.

This article proposes an API. It is the same API being used internally by the Cloud Foundry Services program. Therefore, as a bonus, any service implementing this API (or providing a broker that implements it) will automatically support integration into Cloud Foundry.


