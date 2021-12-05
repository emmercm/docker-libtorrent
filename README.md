[![](https://badgen.net/badge/emmercm/libtorrent/blue?icon=docker)](https://hub.docker.com/r/emmercm/libtorrent)
[![](https://badgen.net/docker/pulls/emmercm/libtorrent?icon=docker&label=pulls)](https://hub.docker.com/r/emmercm/libtorrent)
[![](https://badgen.net/docker/stars/emmercm/libtorrent?icon=docker&label=stars)](https://hub.docker.com/r/emmercm/libtorrent)

[![](https://badgen.net/badge/emmercm/docker-libtorrent/purple?icon=github)](https://github.com/emmercm/docker-libtorrent)
[![](https://badgen.net/github/license/emmercm/docker-libtorrent?color=grey)](https://github.com/emmercm/docker-libtorrent/blob/master/LICENSE)

Base images with libtorrent compiled.

# Supported tags

| Tags | Python Bindings | Layers | Size |
|-|-|-|-|
| `2.0.5`, `2.0.5-alpine`, `2.0`, `2.0-alpine`, `2`, `2-alpine`, `latest` | v3 | ![](https://badgen.net/docker/layers/emmercm/libtorrent/2.0.5?icon=docker&label=layers) | ![](https://badgen.net/docker/size/emmercm/libtorrent/2.0.5?icon=docker&label=size) |
| `1.2.14`, `1.2.14-alpine`, `1.2`, `1.2-alpine`, `1`, `1-alpine` | v3 | ![](https://badgen.net/docker/layers/emmercm/libtorrent/1.2.14?icon=docker&label=layers) | ![](https://badgen.net/docker/size/emmercm/libtorrent/1.2.14?icon=docker&label=size) |
| `1.2.11`, `1.2.11-alpine` | v2, v3 | ![](https://badgen.net/docker/layers/emmercm/libtorrent/1.2.11?icon=docker&label=layers) | ![](https://badgen.net/docker/size/emmercm/libtorrent/1.2.11?icon=docker&label=size) |
| `1.1.14`, `1.1.14-alpine`, `1.1`, `1.1-alpine` | v2, v3 | ![](https://badgen.net/docker/layers/emmercm/libtorrent/1.1.14?icon=docker&label=layers) | ![](https://badgen.net/docker/size/emmercm/libtorrent/1.1.14?icon=docker&label=size) |
| `1.0.11`, `1.0.11-alpine`, `1.0`, `1.0-alpine` | v2, v3 | ![](https://badgen.net/docker/layers/emmercm/libtorrent/1.0.11?icon=docker&label=layers) | ![](https://badgen.net/docker/size/emmercm/libtorrent/1.0.11?icon=docker&label=size) |
| `0.16.17`, `0.16.17-alpine`, `0.16`, `0.16-alpine`, `0`, `0-alpine` | - | ![](https://badgen.net/docker/layers/emmercm/libtorrent/0.16.17?icon=docker&label=layers) | ![](https://badgen.net/docker/size/emmercm/libtorrent/0.16.17?icon=docker&label=size) |

# What is libtorrent?

From [www.libtorrent.org](https://www.libtorrent.org/):

> _libtorrent is a feature complete C++ bittorrent implementation focusing on efficiency and scalability. It runs on embedded devices as well as desktops. It boasts a well documented library interface that is easy to use._

[Deluge](http://deluge-torrent.org/) and [qBittorrent](http://www.qbittorrent.org/) are popular torrent clients built with libtorrent.

libtorrent is written in C++ but has bindings for [Python](https://www.libtorrent.org/python_binding.html), [Java](https://github.com/frostwire/frostwire-jlibtorrent/), [Go](https://github.com/steeve/libtorrent-go), and [Node.js](https://github.com/fanatid/node-libtorrent).

libtorrent is released uner the [BSD license](https://github.com/arvidn/libtorrent/blob/master/LICENSE) and all credit is given to Arvid Norberg and the libtorrent contributors.

# Image contents

These images contain 4 main things:

- `/usr/lib/libtorrent-rasterbar.a*`: shared library
- `/usr/lib/libtorrent-rasterbar.so*`: static library
- `/usr/lib/python*/site-packages/libtorrent*.so`: C extension for Python
- `/usr/lib/python*/site-packages/python_libtorrent-*.egg-info`: Python binding

# Why full images?

As of writing the `libtorrent`/`libtorrent-dev` in the Alpine main repository is many years out of date. It can be time-consuming or difficult to compile libtorrent so this saves the end user time and headache.

# How to use these images

These images do not alter their base image's `ENTRYPOINT` or `CMD` and therefore do nothing special. There is minimal value runing these images on their own.

The purpose of these images is to provide a compiled version of `libtorrent` to serve as a basis for other images:

```dockerfile
FROM emmercm/libtorrent:1.2

# compile torrent client

# set ENTRYPOINT / CMD
```

See [emmercm/qbittorrent](https://hub.docker.com/r/emmercm/qbittorrent) for an example project that uses these images.

# Image variants

## `emmercm/libtorrent:<version>-alpine`

The default image variant, these images are based on [the `alpine` official image](https://hub.docker.com/_/alpine) which is designed to be "small, simple, and secure." This variant is recommended for when final image size is a concern.

Some of these builds use an outdated version of Alpine on purpose:

- v0.16 and v1.0 are locked to Alpine v3.7 (2017) because support for [`boost-dev`](https://pkgs.alpinelinux.org/packages?name=boost-dev&branch=edge) v1.66+ wasn't added until [`libtorrent` v1.1.6](https://github.com/arvidn/libtorrent/releases/tag/libtorrent-1_1_6).
- v1.1 and v1.2.11 are locked to Alpine v3.11 (2020) because support for [`boost-python2`](https://pkgs.alpinelinux.org/packages?name=boost-python2&branch=v3.11) was [removed in Alpine v3.12](https://git.alpinelinux.org/aports/commit/main/boost/APKBUILD?id=c7eee7c57fbcbe012646766604d9bcd89368d6e4).

# License

This project is under the [GNU Generic Public License v3](https://github.com/emmercm/docker-libtorrent/blob/master/LICENSE) to allow free use while ensuring it stays open.
