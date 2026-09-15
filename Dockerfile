# Caddy with the DNS provider modules a paisans deployment can use.
#
# Why this image exists: certificates are issued over DNS-01, because a
# deployment's hostnames may not be reachable from the internet at the moment a
# challenge runs, and because a gateway must be able to hold valid certificates
# before DNS points at it. A DNS provider in Caddy is a separate Go module
# compiled in with xcaddy, and upstream's image carries none, so upstream's
# image cannot serve a config that names one.
#
# One image carries every provider we support. Switching provider is then a
# configuration edit with no image change, which is the whole point.

ARG CADDY_VERSION

FROM caddy:${CADDY_VERSION}-builder AS builder
ARG CADDY_VERSION
# The explicit version matters: `xcaddy build` with no argument builds the
# latest stable Caddy release, not necessarily the version this image is
# tagged as, since the tag comes from the version resolved at build time.
# xcaddy README, `xcaddy build [<caddy_version>]`: "defaults to CADDY_VERSION
# env variable or latest".
RUN xcaddy build "v${CADDY_VERSION}" \
      --with github.com/caddy-dns/cloudflare \
      --with github.com/caddy-dns/desec

FROM caddy:${CADDY_VERSION}-alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
