#!/bin/bash
# a shell script for controlling the discrete GPU

TMP_LIB_DIR='/var/tmp/fglrx-bumblebee';

case $1 in
    start)
        if [[ ! -d $TMP_LIB_DIR ]]
        then
            # create a working dir for replacement libs and xorg modules
            mkdir -p $TMP_LIB_DIR;

            # symlink libGL
            ln -sf /usr/lib/catalystpxp/fglrx/fglrx-libGL.so.1.2 \
                $TMP_LIB_DIR/libGL.so;
            ln -sf $TMP_LIB_DIR/libGL.so $TMP_LIB_DIR/libGL.so.1;
            ln -sf $TMP_LIB_DIR/libGL.so $TMP_LIB_DIR/libGL.so.1.2;

            # symlink libglx xorg module
            mkdir -p $TMP_LIB_DIR/xorg-modules/extensions;
            ln -sf /usr/lib/xorg/modules/updates/extensions/fglrx/fglrx-libglx.so \
                $TMP_LIB_DIR/xorg-modules/extensions/libglx.so;
            
            chmod -R 777 $TMP_LIB_DIR;
        fi
        
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
        export LD_LIBRARY_PATH=$TMP_LIB_DIR:$LD_LIBRARY_PATH;
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
