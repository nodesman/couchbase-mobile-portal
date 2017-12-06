### Debian

Install sync_gateway with the dpkg package manager e.g:

```bash
dpkg -i {{ site.sg_package_name }}.deb
```

When the installation is complete sync_gateway will be running as a service.

```bash
systemctl start sync_gateway
systemctl stop sync_gateway
```

The config file and logs are located in `/home/sync_gateway`.