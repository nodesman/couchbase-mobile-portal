### macOS

Download the **tar.gz** file using `wget` or `curl`.

```bash
wget {{ site.sg_download_link }}{{ site.sg_package_name }}.tar.gz
```

Install sync_gateway by unpacking the tar.gz installer.

```bash
sudo tar -zxvf {{ site.sg_package_name }}.tar.gz --directory /opt
```

Create the sync_gateway service.

```bash
$ sudo mkdir /Users/sync_gateway

$ cd /opt/couchbase-sync-gateway/service

$ sudo ./sync_gateway_service_install.sh
```

To restart sync_gateway (it will automatically start again).

```bash
$ sudo launchctl stop sync_gateway
```

To remove the service.

```bash
$ sudo launchctl unload /Library/LaunchDaemons/com.couchbase.mobile.sync_gateway.plist
```

The config file and logs are located in `/Users/sync_gateway`.
