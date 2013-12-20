# bumblebee-amd-hacks

This is a set of tools and hacks to run Linux and
[Bumblebee](https://github.com/Bumblebee-Project/) with Intel/AMD hybrid graphics
laptops.

They were designed for an [Arch Linux](https://www.archlinux.org) system, however
the scripts may be applicable to other distributions with some tweaking.

They were also designed for a combination of fglrx (catalyst) and i915. I have
not had any success with the radeon driver, due to KMS conflicts. Try at your
own risk.

## Step-by-step installation

First, you will need to install the catalyst driver with PowerXpress support.
You can get it from the AUR:
[catalyst-total-pxp](https://aur.archlinux.org/packages/catalyst-total-pxp/)

Next, you need to install Bumblebee's `common-amd` branch. I wrote an
[AUR package](https://aur.archlinux.org/packages/bumblebee-amd-git/) to do the
job.

### catalyst-utils-pxp

Vi0l0's GPU switching scripts that come with the `catalyst-utils-pxp` package
are clever solutions for switching GPUs between X sessions, but they are
unsuitable for use with Bumblebee.

Keep `catalyst-utils-pxp` installed, but "switch" back to the Intel card.

`pxp_switch_catalyst intel`

### Bumblebee configuration

Next we need to edit the Bumblebee configuration files.

1. Merge the settings listed in `bumblebee.conf.add` into your existing
   `/etc/bumblebee/bumblebee.conf`.
2. Replace your existing `/etc/bumblebee/xorg.conf.fglrx` with the version
   contained in this package.

### ati.sh

Finally, place `ati.sh` somewhere in your `$PATH`, like `/usr/local/bin/ati`.

This shell script is your one-stop shop for utilizing your dedicated GPU.
Just run it to list the options.

#### Power management

Even when you're not using it, the dedicated GPU will consume quite a bit of power
and waste heat. To power it on and off on demand, you have two options:

* Simply load and unload the fglrx module (recommended). Simple and reliable,
  assuming this trick works on your system. (Verify using powertop.)
* Install [acpi_call](https://aur.archlinux.org/packages/dkms-acpi_call-git/)
  from the AUR. Run the `turn_off_gpu.sh` script to determine which ACPI call
  turns off your GPU, and then put that call into `ati.sh`.

## Notes for users upgrading from the initial (summer 2013) version

Essentially, you need to do the following:

1. `ati stop` if Bumblebee is currently running.
2. "Switch back" to the Intel card with `pxp_switch_catalyst intel`.
3. Delete the obsolete **/etc/profile.d/zzz-undo_catalyst.sh** file.
4. Update your Bumblebee configuration as described in **Bumblebee configuration**.
5. Replace your existing `ati.sh`.
6. Restart X.

## License


![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png "CC0")

[License](http://creativecommons.org/publicdomain/zero/1.0/)

To the extent possible under law, Ryan Young has waived all copyright and
related or neighboring rights to bumblebee-amd-hacks.

This work is published from: United States.
