# FlyingFoxCLI

Example command line app that runs FlyingFox http server on port 80

### Run

`% swift run flyingfox --port 8080`

### Docker

FlyingFox also supports Linux. [Docker](https://en.wikipedia.org/wiki/Docker_(software)) containers are one of the easiest methods to test this from macOS.

Install [Docker Desktop for mac](https://hub.docker.com/editions/community/docker-ce-desktop-mac)

Checkout FlyingFoxCLI
`% git checkout https://github.com/swhitty/FlyingFoxCLI`

Pull latest docker swift image
`% docker pull swift`

Build and run FlyingFoxCLI in a swift container, listening on port 80 within the container, but published on port 8080 outside of the container.

```
% docker run -it \
  --publish 8080:80 \
  --rm \
  --mount src="$(pwd)",target=/swift_source,type=bind \
  swift /bin/sh -c "cd swift_source; swift run flyingfox --port 80"
```
