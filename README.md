[![Platforms](https://img.shields.io/badge/platforms-Mac%20|%20Linux-lightgray.svg)]()
[![Swift 5.5](https://img.shields.io/badge/swift-5.5-red.svg?style=flat)](https://developer.apple.com/swift)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)
[![Twitter](https://img.shields.io/badge/twitter-@simonwhitty-blue.svg)](http://twitter.com/simonwhitty)

# FlyingFoxCLI

Example command line app that runs [FlyingFox](https://github.com/swhitty/FlyingFox) http server on port 80

### Run

```
% swift run flyingfox
```

Supply a port number:
```
% swift run flyingfox --port 8008
```

### Run Locally with Docker

FlyingFox also supports Linux. [Docker](https://en.wikipedia.org/wiki/Docker_(software)) containers are one of the easiest methods to test linux builds from macOS.

1. Install [Docker Desktop for mac](https://hub.docker.com/editions/community/docker-ce-desktop-mac)

2. Checkout FlyingFoxCLI
```
% git checkout https://github.com/swhitty/FlyingFoxCLI
% cd FlyingFox
```

3. Pull latest docker swift image
```
% docker pull swift
```

4. Build and run FlyingFoxCLI in a swift container, listening on port 80 within the container, but published on port 8080 outside of the container.
```
% docker run -it \
  --publish 8080:80 \
  --rm \
  --mount src="$(pwd)",target=/flyingfoxcli,type=bind \
  swift \
  /bin/sh -c "cd flyingfoxcli; swift run flyingfox --port 80"
```

## Google Cloud Run
FlyingFox can be deployed and run on Google Cloud Run.  Note: this requires a Google Cloud project `{project}` setup with billing enabled.

Use homebrew to install the google cloud SDK

```shell
% brew install --cask google-cloud-sdk
```

## Cloud Build & Deploy

Build on Google Cloud:

```shell
% gcloud builds submit --tag gcr.io/{project}/flyingfox --project={project}
```

Deploy docker image that was built and now exists within container registry:

```shell
% gcloud run deploy flyingfox --image gcr.io/{project}/flyingfox --platform managed --allow-unauthenticated --project={project}
```

## Local Build & Deploy

Build locally using docker (faster) Requires [Docker desktop](https://www.docker.com/products/docker-desktop)

```shell
% docker build . -t gcr.io/{project}/flyingfox
```

Configure docker to use google auth (one-time-only)

```shell
% gcloud auth configure-docker
```

Push locally built image to google cloud container registry.

```shell
% docker image push gcr.io/{project}/flyingfox
```

Deploy docker image that was build and now exists within container registry

```console
% gcloud run deploy flyingfox --image gcr.io/{project}/flyingfox --platform managed --allow-unauthenticated --project={project}
```
