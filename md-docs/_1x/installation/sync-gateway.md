---
id: sg
title: Sync Gateway
permalink: installation/sync-gateway/index.html
---

You can download Sync Gateway from the [Couchbase downloads page](http://www.couchbase.com/nosql-databases/downloads#couchbase-mobile) or download it directly to a Linux system by using the `wget`.

```bash
wget {{ site.sg_download_link }}{{ site.sg_package_name }}.deb
```

All download links follow the naming convention:

```bash
couchbase-sync-gateway-community_<VERSION>-<BUILDNUM>_<ARCHITECTURE>.<EXT>
```

where

- `VERSION` is the release version.
- `BUILDNUM` is the specific build number.
- `ARCHITECTURE` is the target architecture of the installer.
- `EXT` is the file extension.

## Requirements

|Ubuntu|CentOS/RedHat|Debian|Windows|macOS|
|:-----|:------------|:-----|:------|:----|
|12, 14|5, 6, 7|8|Windows 8, Windows 10, Windows Server 2012|Yosemite, El Capitan|

### Network configuration

Sync Gateway uses specific ports for communication with the outside world, mostly Couchbase Lite databases replicating to and from Sync Gateway. The following table lists the ports used for different types of Sync Gateway network communication:

|Port|Description|
|:---|:----------|
|4984|Public port. External HTTP port used for replication with Couchbase Lite databases and other applications accessing the REST API on the Internet.|
|4985|Admin port. Internal HTTP port for unrestricted access to the database and to run administrative tasks.|

Once you have downloaded Sync Gateway on the distribution of your choice you are ready to install and start it as a service.

## Installation

{% capture macos        %}{% include_relative sync-gateway/macos.md          %}{% endcapture %}
{% capture windows      %}{% include_relative sync-gateway/windows.md        %}{% endcapture %}
{% capture centos       %}{% include_relative sync-gateway/centos.md         %}{% endcapture %}
{% capture debian       %}{% include_relative sync-gateway/debian.md         %}{% endcapture %}
{% capture ubuntu       %}{% include_relative sync-gateway/ubuntu.md         %}{% endcapture %}

<div class="tabs">
  <div class="nav nav-tabs bg-faded text-center">
    <ul class="nav navbar-nav nav-inline">
      <a id="mac-tab" class="nav-item nav-link" data-toggle="tab" href="#mac">macOS</a>
      <a id="windows-tab" class="nav-item nav-link" data-toggle="tab" href="#windows">Windows</a>
      <a id="centos-tab" class="nav-item nav-link" data-toggle="tab" href="#centos">Red Hat/CentOS</a>
      <a id="debian-tab" class="nav-item nav-link" data-toggle="tab" href="#debian">Debian</a>
      <a id="ubuntu-tab" class="nav-item nav-link" data-toggle="tab" href="#ubuntu">Ubuntu</a>
    </ul>
  </div>

  <div class="tab-content">
    <div id="select-platform" class="tab-pane bg-faded active">
      <p class="text-center my-4 text-muted">
        Select platform:
      </p>
    </div>
    <div class="tab-pane" id="mac">
    	{{macos | markdownify}}
    </div>
    <div class="tab-pane" id="windows">
    	{{windows | markdownify}}
    </div>
    <div class="tab-pane" id="centos">
    	{{centos | markdownify}}
    </div>
    <div class="tab-pane" id="debian">
    	{{debian | markdownify}}
    </div>
    <div class="tab-pane" id="ubuntu">
    	{{ubuntu | markdownify}}
    </div>
  </div>
</div>

### Walrus mode

By default, Sync Gateway uses a built-in, in-memory server called "Walrus" that can withstand most prototyping use cases, extending support to at most one or two users. In a staging or production environment, you must connect each Sync Gateway instance to a Couchbase Server cluster.

### Connecting to Couchbase Server

To connect Sync Gateway to Couchbase Server:

- [Download](https://www.couchbase.com/nosql-databases/downloads) and install Couchbase Server.
- Open the Couchbase Server Admin Console on [http://localhost:8091](http://localhost:8091) and log on using your 
administrator credentials.
- In the toolbar, select the **Data Buckets** tab and click the **Create New Data Bucket** button.
		![](../img/cb-create-bucket.png)
- Provide a bucket name, for example **mobile_bucket**, and leave the other options to their defaults.
- Specify the bucket name and Couchbase Server host name in the Sync Gateway configuration.

	```javascript
	{
		"log": ["*"],
		"databases": {
			"db": {
				"server": "http://localhost:8091",
				"bucket": "mobile_bucket",
				"users": { "GUEST": { "disabled": false, "admin_channels": ["*"] } }
			}
		}
	}
	```

[//]: # (TODO: converting site.version to a number. In future, should consider making site.version a number.)
{% assign version = site.version | plus: 0 %}
{% if version < 1.5 %}

> **Note:** Do not add, modify or remove data in the bucket using Couchbase Server SDKs or the Admin Console, or you will confuse Sync Gateway. To modify documents, we recommend you use the Sync Gateway's REST API.

{% endif %}

### Couchbase Server network configuration

In a typical mobile deployment on premise or in the cloud (AWS, RedHat etc), the following ports must be opened on the host for Couchbase Server to operate correctly: 8091, 8092, 8093, 8094, 11207, 11210, 11211, 18091, 18092, 18093. You must verify that any firewall configuration allows communication on the specified ports. If this is not done, the Couchbase Server node can experience difficulty joining a cluster. You can refer to the [Couchbase Server Network Configuration](/documentation/server/current/install/install-ports.html) guide to see the full list of available ports and their associated services.

## Getting Started

Before installing Sync Gateway, you should have completed the Getting Started instructions for Couchbase Lite on the platform of [your choice](../index.html) (iOS, Android, .NET, Xamarin, Java or PhoneGap). To begin synchronizing between Couchbase Lite and Sync Gateway follow the steps below:

1. Create a new file called **sync-gateway-config.json** with the following configuration.

	```json
	{
		"databases": {
			"hello": {
				"server": "walrus:",
				"users": {"GUEST": {"disabled": false, "admin_channels": ["*"]}},
				"sync": `function (doc, oldDoc) {
					if (doc.sdk) {
						channel(doc.sdk);
					}
				}`
			}
		}
	}
	```

	This configuration file creates a database called `hello` and routes documents to different channels based on the document's `sdk` property, if it exists.

2. Start Sync Gateway from the command line.

	```bash
	~/Downloads/couchbase-sync-gateway/bin/sync_gateway ~/path/to/sync-gateway-config.json
	```

3. Run the application where Couchbase Lite is installed. You should then see the documents that were replicated on the admin UI at http://localhost:4985/_admin/.

{% include experimental-label.html %}

<img src="../img/admin-ui-getting-started.png" class=center-image />