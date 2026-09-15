# caddy-dns

Caddy with DNS provider modules compiled in, for paisans deployments.

```
ghcr.io/paisans-software/caddy
```

## Why this exists

A paisans deployment issues certificates over DNS-01. That is not a preference:
a gateway has to be able to hold valid certificates before DNS points at it,
which is what makes moving a gateway an overlap rather than a cutover, and a
hostname served behind a VPN has nothing on the internet that can answer an
HTTP-01 challenge.

A DNS provider in Caddy is a separate Go module, compiled in with xcaddy.
Upstream's image carries none, so upstream's image cannot load a configuration
that names one. This repository builds the one that can.

## What is in it

| Module | Provider |
|--------|----------|
| `github.com/caddy-dns/cloudflare` | Cloudflare |
| `github.com/caddy-dns/desec` | deSEC |

Both are in the same image. Switching provider is a configuration edit in the
deployment, with no image change and no repull.

## Tags

Tags mirror upstream Caddy's own ladder, against whatever version we built from:

```
ghcr.io/paisans-software/caddy:latest
ghcr.io/paisans-software/caddy:2
ghcr.io/paisans-software/caddy:2.11
ghcr.io/paisans-software/caddy:2.11.4
```

**All of these move**, exactly as upstream's do. Upstream rebuilds even a patch
tag when its base image gets a security update, so `2.11.4` is a name for the
newest build of that version rather than for a fixed set of bytes.

**Pin by digest if you need reproducibility.** `paisans-stack` does, and the
build opens a pull request there to move that digest forward.

## How it stays current

A daily job asks what upstream's current release is and builds when either the
version differs from the last build, or the last build is more than thirty days
old. The second case is base image security updates, which arrive without a
Caddy release.

Nothing is published until the built binary answers `caddy list-modules` with
both providers and loads a configuration that uses one. A build can succeed and
still produce a binary that cannot serve the configuration a deployment renders.

`built.json` records what the last successful build produced. It is written by
the workflow, not by hand.

## Adding a provider

Add a `--with` line to the `Dockerfile`, add the module to the smoke test in
`.github/workflows/build.yml`, and run the workflow by hand with `force`. Every
adopter gets the new provider on their next image pull, and nobody who is not
using it is affected.
