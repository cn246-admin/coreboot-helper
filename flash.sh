#!/bin/bash

# Set working directory
x230dir="$HOME/Projects/x230"

# Delete wrong coreboot.roms
rm -f ~/Projects/x230/coreboot/build/coreboot*

# Build new coreboot
cd "${x230dir}"/x230/coreboot || exit

make

# Add Custom Files
cd "${x230dir}"/coreboot/util/cbfstool || exit

./cbfstool ../../build/coreboot.rom add -t raw -n etc/grub.cfg -f "${x230dir}"/zerocat/zerocat.cfg

# Move Secondary Payloads
./cbfstool ../../build/coreboot.rom extract -m x86 -n img/coreinfo -f coreinfo.extracted
./cbfstool ../../build/coreboot.rom extract -m x86 -n img/nvramcui -f nvramcui.extracted
./cbfstool ../../build/coreboot.rom remove -n img/coreinfo
./cbfstool ../../build/coreboot.rom remove -n img/nvramcui
./cbfstool ../../build/coreboot.rom add-payload -c lzma -n coreinfo -f coreinfo.extracted
./cbfstool ../../build/coreboot.rom add-payload -c lzma -n nvramcui -f nvramcui.extracted

rm -f coreinfo.extracted nvramcui.extracted

# Add SeaBIOS Payload
./cbfstool ../../build/coreboot.rom add -t raw -n config-seabios -f "${x230dir}"/seabios/.config
./cbfstool ../../build/coreboot.rom add -t raw -n vgaroms/vgabios.bin -f "${x230dir}"/seabios/out/vgabios.bin
./cbfstool ../../build/coreboot.rom add-payload -n bios.bin.elf -f "${x230dir}"/seabios/out/bios.bin.elf

# Add Background Images

if [ -f "${x230dir}"/background/background.png ]; then
    ./cbfstool ../../build/coreboot.rom add -t raw -n background.png -f "${x230dir}"/background/background.png
fi

if [ -f "$x230dir}"/background/background_1.png ]; then
    ./cbfstool ../../build.coreboot.rom add -t raw -n background_1.png -f "${x230dir}"/background_1.png;
fi

if [ -f "$x230dir}"/background/background_2.png ]; then
    ./cbfstool ../../build.coreboot.rom add -t raw -n background_2.png -f "${x230dir}"/background_2.png;
fi

if [ -f "$x230dir}"/background/background_3.png ]; then
    ./cbfstool ../../build.coreboot.rom add -t raw -n background_3.png -f "${x230dir}"/background_3.png
fi

# Tweak Parameters
cd "${x230dir}"/coreboot/util/nvramtool || exit

./nvramtool -C ../../build/coreboot.rom -w gfx_uma_size=224M
./nvramtool -C ../../build/coreboot.rom -w wwan=Disable
./nvramtool -C ../../build/coreboot.rom -w bluetooth=Disable

# Split into Top and Bottom ROM
cd "${x230dir}"/coreboot/build/ || exit

dd if=coreboot.rom of=coreboot-bottom.rom bs=1M count=8
dd if=coreboot.rom of=coreboot-top.rom bs=1M skip=8

