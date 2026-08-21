# Zirconium X9 experimental camera payload

This profile targets the internal `TBE20A0` Sony IMX471 camera in the Lenovo
ThinkPad X9 15p Aura (Intel Panther Lake IPU7). It remains unsupported and is
not published as a stable image.

## Intel IPU7 firmware

- Source: <https://github.com/intel/ipu7-camera-bins>
- Commit: `adf55525ab9d370828723b1ff8bee76ed7a492e8`
- File: `lib/firmware/intel/ipu/ipu7ptl_fw.bin`
- SHA-256: `8ce12bc3c4355d589a8ad97bebbb036909e5985990ce1cf37789ce60fb52720f`
- License: Intel binary redistribution license, installed beside the payload
  under `/usr/share/licenses/ipu7-camera-bins/`.

The firmware is redistributed byte-for-byte. It is not reverse engineered,
decompiled, disassembled, or modified.

## IMX471 libcamera SoftISP tuning

- Source: <https://github.com/ocewers/x1c14-camera-imx471>
- Commit: `1821ecc020e3436ba1581a71424f3e7f0a7b01a5`
- File: `tuning/imx471.yaml`
- SHA-256: `93752fc6abbc286446636bd45d335f75f25d34c704ea636d92cf94c544ae0cc3`
- License: `CC0-1.0`, declared in the file and installed under
  `/usr/share/licenses/zirconium-x9-imx471-tuning/`.

The tuning starts with a diagonal color-correction matrix measured on another
Panther Lake IMX471 module. Module-to-module variation is possible, so stable
promotion requires calibration on the target laptop.

## Live verification

The exact firmware authenticated on Fedora 44 with kernel 7.1.8, bound the
in-tree `intel_ipu7`, `intel_ipu7_isys`, and `imx471` drivers, and produced a
stable 1920x1080/1280x720 software-ISP stream. The timing helper was verified
at exposure 2273, analogue gain code 800, and native digital gain code 256.
Higher digital gain was rejected because it amplified noise and made the
current Intel GPU synchronization artifact much more visible.

## Colored-line workaround

The colored horizontal bands and screen-door pattern are not caused by the
IMX471 timing controls or tuning file. They reproduce with Fedora libcamera
0.7.1 and official libcamera 0.7.2 when GPU SoftISP runs on the Intel Arc B390,
but disappear with the same GPU shader on Mesa llvmpipe and with CPU SoftISP.
This matches Red Hat bug 2502786, where software GL also removes the bars and
the suspected root cause is Intel GPU synchronization in the zero-copy path.

Until that driver issue is fixed, the profile installs a narrow system Flatpak
override for Cosmic Camera. It exposes only the image's copied tuning file,
keeps libcamera's GPU shader selected, and sets `LIBGL_ALWAYS_SOFTWARE=1`.
Direct host libcamera applications can opt into the same workaround or use
`LIBCAMERA_SOFTISP_MODE=cpu` when lower CPU usage is more important than the
GPU shader's current color output.
