#!/usr/bin/env bash
set -e
docker build --platform linux/amd64 -t heroku-imagemagick container
mkdir -p build
docker run --platform linux/amd64 --rm -t -v $PWD/build:/data heroku-imagemagick sh -c 'cp -f /usr/src/imagemagick/build/*.tar.bz2 /data/'
