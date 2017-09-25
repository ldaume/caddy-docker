caddy
=====

A [Docker](https://docker.com) image for [Caddy](https://caddyserver.com). This image includes the [git](https://caddyserver.com/docs/http.git) plugin.

### License

This image is built from [source code](https://github.com/mholt/caddy). As such, it is subject to the project's [Apache 2.0 license](https://github.com/mholt/caddy/blob/baf6db5b570e36ea2fee30d50f879255a5895370/LICENSE.txt), but it neither contains nor is subject to [the EULA for Caddy's official binary distributions](https://github.com/mholt/caddy/blob/545fa844bbd188c1e5bff6926e5c410e695571a0/dist/EULA.txt).


## Getting Started

```sh
$ docker run -d -p 2015:2015 ldaume/caddy
```

Point your browser to `http://127.0.0.1:2015`.
