### Ubuntu

Install sync_gateway with the dpkg package manager e.g:

```bash
dpkg -i {{ site.sg_package_name }}.deb
```

When the installation is complete sync_gateway will be running as a service.

```bash
service sync_gateway start
service sync_gateway stop
```

The config file and logs are located in `/home/sync_gateway`.

> **Note:** You can also run the **sync_gateway** binary directly from the command line. The binary is installed at `/opt/couchbase-sync-gateway/bin/sync_gateway`.