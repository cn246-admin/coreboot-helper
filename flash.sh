#!/bin/bash

# Set working directory
x230dir="$HOME/Projects/x230"

# Delete wrong coreboot.roms
printf "\n%s\n" "Deleting old coreboot roms..."
rm -vf ~/Projects/x230/coreboot/build/coreboot*
printf "\n%s\n" "Done!"

# Build new coreboot
printf "\n%s\n" "Building new coreboot rom..."
cd "${x230dir}"/coreboot || exit

make

printf "\n%s\n" "Done!"

# Add Custom Files
printf "\n%s\n" "Adding GRUB Config"
cd "${x230dir}"/coreboot/util/cbfstool || exit

./cbfstool "${x230dir}"/coreboot/build/coreboot.rom add -vt raw -n etc/grub.cfg -f "${x230dir}"/zerocat/zerocat.cfg
printf "\n%s\n" "Done!"

# Move Secondary Payloads
printf "\n%s\n" "Moving Secondary Payloads"
./cbfstool "${x230dir}"/coreboot/build/coreboot.rom extract -vm x86 -n img/coreinfo -f coreinfo.extracted
./cbfstool "${x230dir}"/coreboot/build/coreboot.rom extract -vm x86 -n img/nvramcui -f nvramcui.extracted
./cbfstool "${x230dir}"/coreboot/build/coreboot.rom remove -vn img/coreinfo
./cbfstool "${x230dir}"/coreboot/build/coreboot.rom remove -vn img/nvramcui
./cbfstool "${x230dir}"/coreboot/build/coreboot.rom add-payload -vc lzma -n coreinfo -f coreinfo.extracted
./cbfstool "${x230dir}"/coreboot/build/coreboot.rom add-payload -vc lzma -n nvramcui -f nvramcui.extracted

rm -vf coreinfo.extracted nvramcui.extracted
printf "\n%s\n" "Done!"

# Add SeaBIOS Payload
printf "\n%s\n" "Adding the SeaBIOS Payload"
./cbfstool "${x230dir}"/coreboot/build/coreboot.rom add -vt raw -n config-seabios -f "${x230dir}"/seabios/.config
./cbfstool "${x230dir}"/coreboot/build/coreboot.rom add -vt raw -n vgaroms/vgabios.bin -f "${x230dir}"/seabios/out/vgabios.bin
./cbfstool "${x230dir}"/coreboot/build/coreboot.rom add-payload -vn bios.bin.elf -f "${x230dir}"/seabios/out/bios.bin.elf
printf "\n%s\n" "Done!"

# Add Memtest86+
printf "\n%s\n" "Adding Memtest86+"
./cbfstool "${x230dir}"/coreboot/build/coreboot.rom add -vt raw -n memtest.bin -f "${x230dir}"/memtest86plus/memtest.bin
printf "\n%s\n" "Done!"

# Add Background Images
printf "\n%s\n" "Adding GRUB Background Images"
if [ -f "${x230dir}"/background/background.png ]; then
    ./cbfstool "${x230dir}"/coreboot/build/coreboot.rom add -vt raw -n background.png -f "${x230dir}"/background/background.png
fi

if [ -f "$x230dir}"/background/background_1.png ]; then
    ./cbfstool "${x230dir}"/coreboot/build/coreboot.rom add -vt raw -n background_1.png -f "${x230dir}"/background/background_1.png;
fi

if [ -f "$x230dir}"/background/background_2.png ]; then
    ./cbfstool "${x230dir}"/coreboot/build/coreboot.rom add -vt raw -n background_2.png -f "${x230dir}"/background/background_2.png;
fi

if [ -f "$x230dir}"/background/background_3.png ]; then
    ./cbfstool "${x230dir}"/coreboot/build/coreboot.rom add -vt raw -n background_3.png -f "${x230dir}"/background/background_3.png
fi
printf "\n%s\n" "Done!"

# Tweak Parameters
printf "\n%s\n" "Tweaking Parameters..."
cd "${x230dir}"/coreboot/util/nvramtool || exit

./nvramtool -C "${x230dir}"/coreboot/build/coreboot.rom -w gfx_uma_size=224M
./nvramtool -C "${x230dir}"/coreboot/build/coreboot.rom -w wwan=Disable
./nvramtool -C "${x230dir}"/coreboot/build/coreboot.rom -w bluetooth=Disable
printf "\n%s\n" "Done!"

# Split into Top and Bottom ROM
cd "${x230dir}"/coreboot/build/ || exit

printf "\n%s\n" "Splitting the rom for top and bottom chips"
dd if=coreboot.rom of=coreboot-bottom.rom bs=1M count=8
dd if=coreboot.rom of=coreboot-top.rom bs=1M skip=8
printf "\n%s\n" "Done! Time to flash the chips!!"
