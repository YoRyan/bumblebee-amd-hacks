#!/bin/bash
# a shell script for controlling the discrete GPU

case $1 in
    start)
        glxinfo > /dev/null; # improves reliability?
        pxp_switch_catalyst amd;
        systemctl start bumblebeed;
    ;;
    stop)
        killall -9 Xorg; # prevent KMS failures
        systemctl stop bumblebeed;
        pxp_switch_catalyst intel;
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
        source /etc/profile.d/catalyst.sh;
        source /etc/profile.d/catalystpxp.sh;
        source /etc/profile.d/lib32-catalyst.sh;
        source /etc/profile.d/lib32-catalystpxp.sh;
        shift;
        exec optirun $@;
        exit $?;
    ;;
    on)
        echo '\_SB.PCI0.PEG0.PEGP._ON' > /proc/acpi/call;
    ;;
    off)
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
