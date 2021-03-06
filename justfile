
# colors
reset  := '\033[0m'
red    := '\033[1;31m'
green  := '\033[1;32m'
yellow := '\033[1;33m'
blue   := '\033[1;34m'

user_symlink  := "./external/qmk_firmware/users/edeneast"
dact_symlink  := "./external/qmk_firmware/keyboards/handwired/dactyl_manuform/5x6/keymaps/edeneast"
crkbd_symlink := "./external/qmk_firmware/keyboards/crkbd/keymaps/edeneast"

default:
    @just dact
    @just crkbd

dact:
    @just _build handwired/dactyl_manuform/5x6:edeneast handwired_dactyl_manuform_5x6_edeneast.hex dact

crkbd:
    @just _build crkbd:edeneast crkbd_rev1_legacy_edeneast.hex crkbd

_build make_cmd source target: init
    #!/usr/bin/env bash
    printf "{{yellow}}--------------------------------------------------------------------------------------{{reset}}\n"
    printf "Buildling: {{blue}}{{source}}{{reset}}\n\n"
    mkdir -p result
    (
        cd external/qmk_firmware
        make {{make_cmd}}
    )
    mv ./external/qmk_firmware/{{source}} ./result/{{target}}.hex
    printf "Result: {{green}}{{target}}.hex{{reset}}\n"
    if [ ! -z "$POST_BUILD" ]; then
        echo "executing postbuild: $POST_BUILD"
        $POST_BUILD
    fi

flash keyboard:
    #!/usr/bin/env bash
    if [ "{{keyboard}}" = "crkbd" ]; then
        cmd="crkbd:edeneast:dfu"
    elif [ "{{keyboard}}" = "dact" ]; then
        cmd="handwired/dactyl_manuform/5x6:edeneast:avrdude"
    else
        printf "{{red}}Failed: Unknown keyboard: {{keyboard}}{{reset}}\n"
    fi
    (
        cd external/qmk_firmware
        make $cmd
    )

left keyboard:
    #!/usr/bin/env bash
    if [ "{{keyboard}}" = "crkbd" ]; then
        cmd="crkbd:edeneast:dfu-split-left"
    elif [ "{{keyboard}}" = "dact" ]; then
        cmd="handwired/dactyl_manuform/5x6:edeneast:avrdude-split-left"
    else
        printf "{{red}}Failed: Unknown keyboard: {{keyboard}}{{reset}}\n"
        exit
    fi
    (
        cd external/qmk_firmware
        make $cmd
    )

right keyboard:
    #!/usr/bin/env bash
    if [ "{{keyboard}}" = "crkbd" ]; then
        cmd="crkbd:edeneast:dfu-split-right"
    elif [ "{{keyboard}}" = "dact" ]; then
        cmd="handwired/dactyl_manuform/5x6:edeneast:avrdude-split-right"
    else
        printf "{{red}}Failed: Unknown keyboard: {{keyboard}}{{reset}}\n"
        exit
    fi
    (
        cd external/qmk_firmware
        make $cmd
    )

init:
    #!/usr/bin/env bash
    git config submodule.external/qmk_firmware.ignore all
    git submodule update --init --recursive
    if [ ! -L "{{user_symlink}}" ] ; then
        ln -sf $(pwd)/user {{user_symlink}}
    fi
    if [ ! -L "{{dact_symlink}}" ] ; then
        ln -sf $(pwd)/dact {{dact_symlink}}
    fi
    if [ ! -L "{{crkbd_symlink}}" ] ; then
        ln -sf $(pwd)/crkbd {{crkbd_symlink}}
    fi

