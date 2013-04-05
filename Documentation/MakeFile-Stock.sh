#!/bin/sh

echo "Getting Files Ready ..."
echo "-------------------------------"
echo "-- Copying zImage File ..."
# Get zIamge
cp ../kernel/arch/arm/boot/zImage zImage
echo "-- Copying WiFi Modules ..."
# Get Wi-Fi Modules
cp ../kernel/net/compat-wireless/drivers/staging/cw1200/cw1200_core.ko ../ramdisk/lib/modules/
cp ../kernel/net/compat-wireless/drivers/staging/cw1200/cw1200_wlan.ko ../ramdisk/lib/modules/
echo "-- Packing Ramdisk ..."
# Pack Ramdisk.
cd ../ramdisk
find . | cpio --quiet -H newc -o | gzip > ../Documentation/ramdisk.img
cd ../Documentation
echo "-- Removing Old Kernel.img File ..."
#Remove any existing kernel.img file.
rm kernel.img
echo "-- Creating Kernel.img File ..."
# Create Kernel.img
./mkbootimg --cmdline 'cachepolicy=writealloc noinitrd	init=init board_id=1 logo.nologo root=/dev/ram0	rw rootwait console=ttyAMA2,115200n8 androidboot.console=ttyAMA2 androidboot.hardware=st-ericsson mem=96M@0 mem_mtrace=15M@96M mem_mshared=1M@111M mem_modem=16M@112M mem=32M@128M mem_issw=1M@160M hwmem=167M@161M mem=696M@328M vmalloc=384M mpcore_wdt.mpcore_margin=359' --kernel zImage --ramdisk ramdisk.img --base 0x0 --output kernel.img
echo "-- Creating Kernel.elf File ..."
# Create Kernel.elf
python mkelf.py -o kernel.elf zImage@0x00008000 ramdisk.img@0x1000000,ramdisk cmdline.txt@cmdline
echo "-- Cleaning Up Temp Files ..."
#Removing Old CWM Zip File.
rm CWM.zip
#Create CWM zip file.
echo "-- Creating CWM Flashable File For This Kernel ..."
zip -r CWM.zip kernel.elf META-INF
#Clean Up.
rm ramdisk.img
rm zImage
rm kernel.elf
echo "-------------------------------"
echo "All Done !!"
