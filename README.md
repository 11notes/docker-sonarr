![banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# SONARR
![size](https://img.shields.io/docker/image-size/11notes/sonarr/4.0.15?color=0eb305)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![version](https://img.shields.io/docker/v/11notes/sonarr/4.0.15?color=eb7a09)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![pulls](https://img.shields.io/docker/pulls/11notes/sonarr?color=2b75d6)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)[<img src="https://img.shields.io/github/issues/11notes/docker-SONARR?color=7842f5">](https://github.com/11notes/docker-SONARR/issues)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![swiss_made](https://img.shields.io/badge/Swiss_Made-FFFFFF?labelColor=FF0000&logo=data:image/svg%2bxml;base64,PHN2ZyB2ZXJzaW9uPSIxIiB3aWR0aD0iNTEyIiBoZWlnaHQ9IjUxMiIgdmlld0JveD0iMCAwIDMyIDMyIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogIDxyZWN0IHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgZmlsbD0idHJhbnNwYXJlbnQiLz4KICA8cGF0aCBkPSJtMTMgNmg2djdoN3Y2aC03djdoLTZ2LTdoLTd2LTZoN3oiIGZpbGw9IiNmZmYiLz4KPC9zdmc+)

Run Sonarr smaller, lightweight and more secure

# INTRODUCTION 📢

[Sonarr](https://github.com/Sonarr/Sonarr) (created by [Sonarr](https://github.com/Sonarr)) is a PVR for Usenet and BitTorrent users. It can monitor multiple RSS feeds for new episodes of your favorite shows and will grab, sort and rename them. It can also be configured to automatically upgrade the quality of files already downloaded when a better quality format becomes available.

# SYNOPSIS 📖
**What can I do with this?** This image will give you a [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) and lightweight Sonarr installation for your adventures on the high seas *arrrr*!

# ARR STACK IMAGES 🏴‍☠️
This image is part of the so called arr-stack (apps to pirate and manage media content). Here is the list of all it's companion apps for the best pirate experience:

- [11notes/plex](https://github.com/11notes/docker-plex) - as your media server
- [11notes/prowlarr](https://github.com/11notes/docker-prowlarr) - to manage all your indexers
- [11notes/qbittorrent](https://github.com/11notes/docker-qbittorrent) - as your torrent client
- [11notes/radarr](https://github.com/11notes/docker-radarr) - to manage your films
- [11notes/sabnzbd](https://github.com/11notes/docker-sabnzbd) - as your usenet client

# UNIQUE VALUE PROPOSITION 💶
**Why should I run this image and not the other image(s) that already exist?** Good question! Because ...

> [!IMPORTANT]
>* ... this image runs [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) as 1000:1000
>* ... this image is auto updated to the latest version via CI/CD
>* ... this image is built and compiled from source
>* ... this image supports 32bit architecture
>* ... this image has a health check
>* ... this image runs read-only
>* ... this image is automatically scanned for CVEs before and after publishing
>* ... this image is created via a secure and pinned CI/CD process
>* ... this image is very small

If you value security, simplicity and optimizations to the extreme, then this image might be for you.

# COMPARISON 🏁
Below you find a comparison between this image and the most used or original one.

| **image** | **size on disk** | **init default as** | **[distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md)** | supported architectures
| ---: | ---: | :---: | :---: | :---: |
| 11notes/sonarr:4.0.15 | 188MB | 1000:1000 | ❌ | amd64, arm64, armv7 |
| home-operations/sonarr | 195MB | 65534:65533 | ❌ | amd64, arm64 |
| linuxserver/sonarr | 205MB | 0:0 | ❌ | amd64, arm64 |
| hotio/sonarr | 259MB | 0:0 | ❌ | amd64, arm64 |

**Why is this image not distroless?** I would have loved to create a distroless, single binary image, sadly the way that Sonarr is setup makes it really difficult to compile a static binary from source. Enabling AOT breaks almost 30% of used libraries because they are not setup to be statically linked (like Assembly.GetExecutingAssembly().Location). It’s also not fixable with a single PR. This is something the Sonarr team would need to do.

# VOLUMES 📁
* **/sonarr/etc** - Directory of all your settings and database

# COMPOSE ✂️
```yaml
name: "arrs"

x-lockdown: &lockdown
  # prevents write access to the image itself
  read_only: true
  # prevents any process within the container to gain more privileges
  security_opt:
    - "no-new-privileges=true"

services:
  sonarr:
    image: "11notes/sonarr:4.0.15"
    <<: *lockdown
    environment:
      TZ: "Europe/Zurich"
    volumes:
      - "sonarr.etc:/sonarr/etc"
    tmpfs:
      # required for read-only image
      - "/tmp:uid=1000,gid=1000"
    ports:
      - "3000:8989/tcp"
    networks:
      frontend:
    restart: "always"

volumes:
  sonarr.etc:

networks:
  frontend:
```
To find out how you can change the default UID/GID of this container image, consult the [how-to.changeUIDGID](https://github.com/11notes/RTFM/blob/main/linux/container/image/11notes/how-to.changeUIDGID.md#change-uidgid-the-correct-way) section of my [RTFM](https://github.com/11notes/RTFM)

# DEFAULT SETTINGS 🗃️
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user name |
| `uid` | 1000 | [user identifier](https://en.wikipedia.org/wiki/User_identifier) |
| `gid` | 1000 | [group identifier](https://en.wikipedia.org/wiki/Group_identifier) |
| `home` | /sonarr | home directory of user docker |

# ENVIRONMENT 📝
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Will activate debug option for container image and app (if available) | |

# MAIN TAGS 🏷️
These are the main tags for the image. There is also a tag for each commit and its shorthand sha256 value.

* [4.0.15](https://hub.docker.com/r/11notes/sonarr/tags?name=4.0.15)
* [4.0.15-unraid](https://hub.docker.com/r/11notes/sonarr/tags?name=4.0.15-unraid)

### There is no latest tag, what am I supposed to do about updates?
It is of my opinion that the ```:latest``` tag is dangerous. Many times, I’ve introduced **breaking** changes to my images. This would have messed up everything for some people. If you don’t want to change the tag to the latest [semver](https://semver.org/), simply use the short versions of [semver](https://semver.org/). Instead of using ```:4.0.15``` you can use ```:4``` or ```:4.0```. Since on each new version these tags are updated to the latest version of the software, using them is identical to using ```:latest``` but at least fixed to a major or minor version.

If you still insist on having the bleeding edge release of this app, simply use the ```:rolling``` tag, but be warned! You will get the latest version of the app instantly, regardless of breaking changes or security issues or what so ever. You do this at your own risk!

# REGISTRIES ☁️
```
docker pull 11notes/sonarr:4.0.15
docker pull ghcr.io/11notes/sonarr:4.0.15
docker pull quay.io/11notes/sonarr:4.0.15
```

# UNRAID VERSION 🟠
This image supports unraid by default. Simply add **-unraid** to any tag and the image will run as 99:100 instead of 1000:1000 causing no issues on unraid. Enjoy.

# SOURCE 💾
* [11notes/sonarr](https://github.com/11notes/docker-SONARR)

# PARENT IMAGE 🏛️
* [11notes/alpine:stable](https://hub.docker.com/r/11notes/alpine)

# BUILT WITH 🧰
* [sonarr](https://github.com/Sonarr/Sonarr)
* [11notes/util](https://github.com/11notes/docker-util)

# GENERAL TIPS 📌
> [!TIP]
>* Use a reverse proxy like Traefik, Nginx, HAproxy to terminate TLS and to protect your endpoints
>* Use Let’s Encrypt DNS-01 challenge to obtain valid SSL certificates for your services

# ElevenNotes™️
This image is provided to you at your own risk. Always make backups before updating an image to a different version. Check the [releases](https://github.com/11notes/docker-sonarr/releases) for breaking changes. If you have any problems with using this image simply raise an [issue](https://github.com/11notes/docker-sonarr/issues), thanks. If you have a question or inputs please create a new [discussion](https://github.com/11notes/docker-sonarr/discussions) instead of an issue. You can find all my other repositories on [github](https://github.com/11notes?tab=repositories).

*created 13.09.2025, 21:39:32 (CET)*