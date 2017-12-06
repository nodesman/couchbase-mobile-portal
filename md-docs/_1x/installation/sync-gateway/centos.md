### Red Hat/CentOS

Install sync_gateway with the rpm package manager e.g:

```bash
rpm -i {{ site.sg_package_name }}.rpm
```

When the installation is complete sync_gateway will be running as a service.

On CentOS 5:

```bash
service sync_gateway start
service sync_gateway stop
```

On CentOS 6:

```bash
initctl start sync_gateway
initctl stop sync_gateway
```

On CentOS 7:

```bash
systemctl start sync_gateway
systemctl stop sync_gateway
```

The config file and logs are located in `/home/sync_gateway`.