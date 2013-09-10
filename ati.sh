#!/bin/bash
# A shell script for controlling the discrete GPU.
# Copyright (C) 2013 Ryan Young, public domain (CC0)

TMP_LIB_DIR='/var/tmp/fglrx-bumblebee';

case $1 in
    start)
        # recreate the directory every time we start Bumblebee, just to be safe
        if [[ -d $TMP_LIB_DIR ]]
        then
            rm -rf $TMP_LIB_DIR;
        fi
        
        # create a working dir for replacement libs and xorg modules
        mkdir -p $TMP_LIB_DIR;
        
        # symlink libGL
        mkdir -p $TMP_LIB_DIR/lib;
        ln -sf /usr/lib/catalystpxp/fglrx/fglrx-libGL.so.1.2 \
            $TMP_LIB_DIR/lib/libGL.so;
        ln -sf $TMP_LIB_DIR/lib/libGL.so $TMP_LIB_DIR/lib/libGL.so.1;
        ln -sf $TMP_LIB_DIR/lib/libGL.so $TMP_LIB_DIR/lib/libGL.so.1.2;

        # test for lib32 libraries
        if [[ -d /usr/lib32/catalystpxp ]]
        then
            # symlink lib32 libGL
            mkdir -p $TMP_LIB_DIR/lib32;
            ln -sf /usr/lib32/catalystpxp/fglrx/fglrx-libGL.so.1.2 \
                $TMP_LIB_DIR/lib32/libGL.so;
            ln -sf $TMP_LIB_DIR/lib32/libGL.so $TMP_LIB_DIR/lib32/libGL.so.1;
            ln -sf $TMP_LIB_DIR/lib32/libGL.so $TMP_LIB_DIR/lib32/libGL.so.1.2;
        fi
        
        # symlink libglx xorg module
        mkdir -p $TMP_LIB_DIR/xorg-modules/extensions;
        ln -sf /usr/lib/xorg/modules/updates/extensions/fglrx/fglrx-libglx.so \
            $TMP_LIB_DIR/xorg-modules/extensions/libglx.so;
        
        chmod -R 777 $TMP_LIB_DIR;
        
        systemctl start bumblebeed;
    ;;
    stop)
        # prevent KMS failures
        # this takes advantage of the fact that login managers spawn
        # X, not Xorg
        killall -9 Xorg;
        systemctl stop bumblebeed;
    ;;
    query)
        systemctl status bumblebeed > /dev/null;
        if [[ $? == 0 ]]
        then
            echo running;
            exit 0;
        else
            echo stopped;
            exit 1;
        fi
    ;;
    run)
        if [[ -e $TMP_LIB_DIR/lib32 ]]
        then
            export LD_LIBRARY_PATH=$TMP_LIB_DIR/lib:$TMP_LIB_DIR/lib32:$LD_LIBRARY_PATH;
        else
            export LD_LIBRARY_PATH=$TMP_LIB_DIR/lib:$LD_LIBRARY_PATH;
        fi
        shift;
        exec optirun $@;
    ;;
    on)
        # this is different for every system!
        echo '\_SB.PCI0.PEG0.PEGP._ON' > /proc/acpi/call;
    ;;
    off)
        # this is different for every system!
        echo '\_SB.PCI0.PEG0.PEGP._OFF' > /proc/acpi/call;
    ;;
    *)
        echo "Usage: $0 [option]...

    Bumblebee control:
        $0 [start|stop|query]

    Running OpenGL applications:
        $0 run <command>

    Power management (dangerous!):
        $0 [on|off]

Author: Ryan Young
https://github.com/YoRyan/bumblebee-amd-hacks
Please make sure to tweak this script to suit your own system.
";
    ;;
esac

exit 0;
