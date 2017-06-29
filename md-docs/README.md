### Install Jekyll and the local dependencies.

```bash
$ cd md-docs
$ gem install bundler
$ bundle install
```

> Note: if you encounter an error saying that nokogiri isn't installed follow the steps in [this guide](http://www.nokogiri.org/tutorials/installing_nokogiri.html#mac_os_x) to install it on your system.

### Generate a local preview.

```bash
$ cd md-docs
$ jekyll serve --port 4000 --config _config.yml,_config.server.yml --livereload
```

Browse the docs at [http://localhost:4000/index.html](http://localhost:4000/index.html).

![](https://cl.ly/400E140R461r/nav_docs.png)

The command is using the `--livereload` flag which will automatically reload the browser window when a change is saved. This only works in Chrome and the [LiveReload Chrome Extension](https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei?hl=en) must be installed. Once it's installed you should see the small circle filled in gray which indicates that the extension is connected to the Jekyll web server.

![](https://cl.ly/04350x2q1v3w/livereload.png)