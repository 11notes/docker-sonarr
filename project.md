${{ content_synopsis }} This image will give you a base Alpine image with some additional tweaks like some bin’s (curl, tini, shadow, tzdata) which are present by default and the mimalloc memory allocator which can be used for certain apps to deal with musl’s not so optimized malloc for multi-threading. It will also execute the script ```/usr/local/bin/entrypoint.sh``` via [tini](https://github.com/krallin/tini).

If used as a base image for your own image simply leave out your own **ENTRYPOINT** to use the default one and provide your own ```/usr/local/bin/entrypoint.sh```.

${{ content_uvp }} Good question! All the other images on the market that do exactly the same don’t do or offer these options:

${{ github:> [!IMPORTANT] }}
${{ github:> }}* This image runs as 1000:1000 by default, most other images run everything as root
${{ github:> }}* This image is created via a secure, pinned CI/CD process and immune to upstream attacks, most other images have upstream dependencies that can be exploited
${{ github:> }}* This image contains a proper health check that verifies the app is actually working, most other images have either no health check or only check if a port is open or ping works
${{ github:> }}* This image works as read-only, most other images need to write files to the image filesystem
${{ github:> }}* This image is a lot smaller than most other images

If you value security, simplicity and the ability to interact with the maintainer and developer of an image. Using my images is a great start in that direction.

${{ content_comparison }}

${{ title_volumes }}
* **${{ json_root }}/etc** - Directory of all your settings and database

${{ content_compose }}

${{ content_defaults }}

${{ content_environment }}

${{ content_source }}

${{ content_parent }}

${{ content_built }}

${{ content_tips }}