# Zirconium X9

An AMD64 bootc image for the Lenovo ThinkPad X9 15p Aura, built from
[Zirconium](https://github.com/zirconium-dev/zirconium) with a small mkosi
overlay.

The stable profile adds Fedora's Nix packages and persists `/nix` through a
bind mount backed by `/var/lib/nix`. Audio customization is intentionally out
of scope. The camera profile is an unsupported scaffold and contains no camera
drivers, firmware, or userspace stack.

## Local commands

```bash
git submodule update --init --recursive
just cat-config
just build
just load
just rechunk
just lint
```

`just build-camera` composes the isolated camera scaffold. It is not published.

The stable image is published as `ghcr.io/samd2021/zirconium-x9:latest` after
the complete build, rechunk, assertion, lint, and signing pipeline succeeds.
