### Windows

Install sync_gateway on Windows by running the .exe file from the desktop.

```bash
{{ site.sg_package_name }}.exe
```

When the installation is complete sync_gateway will be installed as a service but not running.

Use the **Control Panel --> Admin Tools --> Services** to stop/start the service.

The config file and logs are located in ``.