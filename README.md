# bumblebee-amd-hacks

This is a set of tools and hacks to run Linux and
[Bumblebee](https://github.com/Bumblebee-Project/) with Intel/AMD hybrid graphics
laptops.

They were designed for an [Arch Linux](https://www.archlinux.org) system, however
the scripts may be applicable to other distributions with some tweaking.

They were also designed for a combination of fglrx (catalyst) and i915. I have
not had any success with the radeon driver, due to KMS conflicts. Try at your
own risk.

## Step-by-step usage

First, you will need to install the catalyst driver with PowerXpress support.
You can get it from the AUR:
[catalyst-total-pxp](https://aur.archlinux.org/packages/catalyst-total-pxp/)

Next, you need to install Bumblebee's `common-amd` branch. I wrote an
[AUR package](https://aur.archlinux.org/packages/bumblebee-amd-git/) to do the
job.

### /etc/profile.d

The PowerXpress switching scripts work by creating a custom library path for
OpenGL libraries, which are then swapped out when switching between GPU's.
For our purposes, we want to use the Intel/Mesa libraries unless specifically
running a program on the AMD card. Therefore, we need to undo the
`LD_LIBRARY_PATH` changes that the scripts make.

Drop `zzz_undo-catalyst.sh` into `/etc/profile.d/`. This one-line file will
clear `LD_LIBRARY_PATH`, bypassing the catalyst switching system. Note that
this might cause problems if you actually want something in your
`LD_LIBRARY_PATH`; you should adjust the file accordingly.

### bumblebee.conf

Next we need to edit the Bumblebee configuration file. Merge the settings
listed in `bumblebee.conf.add` into your existing
`/etc/bumblebee/bumblebee.conf`.

### ati.sh

Finally, place `ati.sh` somewhere in your `$PATH`, like `/usr/local/bin/ati`.

This shell script is your one-stop shop for utilizing your dedicated GPU.
Just run it to list the options.

If you want power management (which is rather buggy, see the warnings section),
install [acpi_call](https://aur.archlinux.org/packages/dkms-acpi_call-git/)
from the AUR. Run the `turn_off_gpu.sh` script to determine which ACPI call
turns off your GPU, and then **put the call into your control script!**

## Warnings

* Sometimes OpenGL will break horribly on both cards - segmentation faults
  on the Intel GPU and X render errors with `optirun`. If this happens, just
  restart the X server. This problem seems to occur on first login.
* The power management feature of the control script uses ACPI calls to turn
  your GPU on and off. Usually turning it off works fine, but on my system
  my GPU can't be turned back on, even though the ACPI call is accepted.
* Rebooting the computer will always turn the dedicated GPU back on.
* Be sure to put your own ACPI calls into the control script, of course!

## License


![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png "CC0")

[License](http://creativecommons.org/publicdomain/zero/1.0/)

To the extent possible under law, Ryan Young has waived all copyright and
related or neighboring rights to bumblebee-amd-hacks.

This work is published from: United States.
