#!/bin/bash

# Delete wrong coreboot.roms
rm -f /home/chuck/Projects/x230/coreboot/build/coreboot*

# Build new coreboot
cd /home/chuck/Projects/x230/coreboot || exit

make

# Add Custom Files
cd /home/chuck/Projects/x230/coreboot/util/cbfstool || exit

./cbfstool ../../build/coreboot.rom add -t raw -n etc/grub.cfg -f /home/chuck/Projects/x230/zerocat/zerocat.cfg

# Move Secondary Payloads
./cbfstool ../../build/coreboot.rom extract -m x86 -n img/coreinfo -f coreinfo.extracted
./cbfstool ../../build/coreboot.rom extract -m x86 -n img/nvramcui -f nvramcui.extracted
./cbfstool ../../build/coreboot.rom remove -n img/coreinfo
./cbfstool ../../build/coreboot.rom remove -n img/nvramcui
./cbfstool ../../build/coreboot.rom add-payload -c lzma -n coreinfo -f coreinfo.extracted
./cbfstool ../../build/coreboot.rom add-payload -c lzma -n nvramcui -f nvramcui.extracted
rm -f coreinfo.extracted nvramcui.extracted

# Add SeaBIOS Payload
./cbfstool ../../build/coreboot.rom add -t raw -n config-seabios -f /home/chuck/Projects/x230/seabios/.config
./cbfstool ../../build/coreboot.rom add -t raw -n vgaroms/vgabios.bin -f /home/chuck/Projects/x230/seabios/out/vgabios.bin
./cbfstool ../../build/coreboot.rom add-payload -n bios.bin.elf -f /home/chuck/Projects/x230/seabios/out/bios.bin.elf

# Add Background Images
./cbfstool ../../build/coreboot.rom add -t raw -n background.png -f /home/chuck/Downloads/background.png

# Tweak Parameters
cd /home/chuck/Projects/x230/coreboot/util/nvramtool || exit

./nvramtool -C ../../build/coreboot.rom -w gfx_uma_size=224M
./nvramtool -C ../../build/coreboot.rom -w wwan=Disable
./nvramtool -C ../../build/coreboot.rom -w bluetooth=Disable

# Split into Top and Bottom ROM
cd /home/chuck/Projects/x230/coreboot/build/ || exit

dd if=coreboot.rom of=coreboot-bottom.rom bs=1M count=8
dd if=coreboot.rom of=coreboot-top.rom bs=1M skip=8
