# alpine-node-wkhtmltopdf

This Docker image contains a working wkhtmltopdf, wkhtmltoimage and NodeJS installation. The purpose is to keep it as small as possible while delivering all functions.

[![Docker Stars](https://img.shields.io/docker/stars/surnet/alpine-node-wkhtmltopdf.svg)](https://hub.docker.com/r/surnet/alpine-node-wkhtmltopdf/)
[![Docker Pulls](https://img.shields.io/docker/pulls/surnet/alpine-node-wkhtmltopdf.svg)](https://hub.docker.com/r/surnet/alpine-node-wkhtmltopdf/)

[![Docker Automated Build](https://img.shields.io/docker/automated/surnet/alpine-node-wkhtmltopdf.svg)](https://hub.docker.com/r/surnet/alpine-node-wkhtmltopdf/)
[![Docker Build Status](https://img.shields.io/docker/build/surnet/alpine-node-wkhtmltopdf.svg)](https://hub.docker.com/r/surnet/alpine-node-wkhtmltopdf/)

## Use as baseimage

This image can be used as a base for your project. For best results use a fixed version and not latest.

```yaml
FROM alpine-node-wkhtmltopdf:latest
```

## Contribute

Please feel free to open a issue or pull request with suggestions.

Keep in mind that the build process of this container takes some time.

## Credits

Based upon the following repos/inputs:
- https://github.com/nodejs/docker-node
- https://github.com/alloylab/Docker-Alpine-wkhtmltopdf
- https://github.com/wkhtmltopdf/wkhtmltopdf/issues/1794
