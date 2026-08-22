# Zirconium X9

An AMD64 bootc image for the Lenovo ThinkPad X9 15p Aura, built from
[Zirconium](https://github.com/zirconium-dev/zirconium) with a small mkosi
overlay.

The stable profile adds Fedora's Nix packages and persists `/nix` through a
bind mount backed by `/var/lib/nix`. A boot-time preparation service recreates
the store directories hidden by that mount and restores the Nix daemon
socket's baked-in SELinux context before socket activation. This avoids the
host-local `semanage` policy difference that previously prevented otherwise
compatible image updates from using bootc soft reboot. It also corrects the X9's combined
CS35L56/CS42L43 UCM speaker sequence so the CS42L43-driven tweeter pair is
enabled with the main speakers and disabled during headphone switching. The
ThinkPad Thunderbolt 4 Dock analog jack remains manually selectable but has a
lower automatic WirePlumber priority than the built-in speakers, so connecting
the dock does not steal audio output. The validated X9 camera payload is also
included in the stable image; its Mesa
llvmpipe workaround remains temporary until the Intel GPU synchronization bug
is fixed. The official ChatGPT launcher selects Chromium's native Wayland
Ozone backend, including Wayland input-method support, for both desktop and
terminal launches.

## Local commands

```bash
git submodule update --init --recursive
just cat-config
just build
just load
just rechunk
just lint
```

Stable builds add pinned Intel IPU7 firmware, Fedora's in-tree IPU7/IMX471 and
libcamera stack, experimental IMX471 SoftISP color tuning, and a verified
roughly 33 fps low-light timing profile.
It does not add an out-of-tree kernel module, proprietary camera HAL, or MOK
material. `just build-camera` and the manually dispatched `camera` variant
retain a distinct experimental image identity for focused camera validation,
but contain the same camera payload as `latest`.

After booting an X9 image, verify the host stack with:

```bash
cam -l
gst-launch-1.0 libcamerasrc gamma=2.4 contrast=1.25 saturation=1.45 \
  ! 'video/x-raw,width=1280,height=720,framerate=30/1' \
  ! videoconvert ! autovideosink
```

Flatpak camera applications that bundle their own libcamera also bundle their
own tuning search path. The profile installs a narrow system override for
Cosmic Camera that exposes only a read-only copy of the IMX471 tuning file.
It also runs libcamera's GPU shader through Mesa llvmpipe as a temporary
workaround for the Intel GPU synchronization bug tracked in Red Hat bug
[2502786](https://bugzilla.redhat.com/show_bug.cgi?id=2502786). This removes
the colored horizontal bands without granting broad host filesystem access.

The manual `camera` workflow builds, rechunks, asserts, lints, signs, and
publishes `ghcr.io/samd2021/zirconium-x9:camera` without moving stable tags.
Normal `main` builds include the camera payload and publish `latest`, `44`, the
commit tag, and the UTC date tag.

The stable image is published as `ghcr.io/samd2021/zirconium-x9:latest` after
the complete build, rechunk, assertion, lint, and signing pipeline succeeds.
