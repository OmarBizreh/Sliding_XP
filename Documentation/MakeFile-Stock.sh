#!/bin/bash
#---------------------------------------------------------------------------
#|									   |
#|									   |
#|Bash script for creating: Kernel.img, Kernel.elf, and CWM flashable file.|
#|									   |
#|									   |
#---------------------------------------------------------------------------

if [[ ( -e kernel-Stock.img && -e CWM-Stock.zip ) ]]; then
	echo "-- Cleaning up enviroment"
	echo "--------------------------------------------"
	rm kernel-Stock.img
	rm CWM-Stock.zip
	echo "-- Enviroment now clean, moving on"
fi
echo "-- Getting Files Ready"
echo "--------------------------------------------"
echo "-- Copying zImage File ..."
# Get zIamge
if [[ -f ../kernel/arch/arm/boot/zImage ]]; then
	echo "-- zImage found, copying file"
else
	echo "-- zImage not found, please check your build enviroment (Aborting Process)"
	exit 2
fi
cp ../kernel/arch/arm/boot/zImage zImage
echo "-- Copying WiFi Modules ..."
# Get Wi-Fi Modules
if [[ ( -f ../kernel/net/compat-wireless/drivers/staging/cw1200/cw1200_core.ko && -f ../kernel/net/compat-wireless/drivers/staging/cw1200/cw1200_wlan.ko ) ]]; then
	echo "-- Wifi modules found, copying Wifi moduels to ramdisk folder"
	cp ../kernel/net/compat-wireless/drivers/staging/cw1200/cw1200_core.ko ../ramdisk/lib/modules/3.0.8+/kernel/net/compat-wireless/drivers/staging/cw1200
	cp ../kernel/net/compat-wireless/drivers/staging/cw1200/cw1200_wlan.ko ../ramdisk/lib/modules/3.0.8+/kernel/net/compat-wireless/drivers/staging/cw1200
else
	echo "-- Can't find Wifi module, please check your build enviroment (Aborting Process)"
	exit 2
fi
echo "-- Packing Ramdisk"
# Pack Ramdisk.
cd ../ramdisk
find . | cpio --quiet -H newc -o | gzip > ../Documentation/ramdisk.img
cd ../Documentation
# Create Kernel.img
echo "-- Creating Kernel.img File ..."
./mkbootimg --cmdline 'cachepolicy=writealloc noinitrd	init=init board_id=1 logo.nologo root=/dev/ram0	rw rootwait console=ttyAMA2,115200n8 androidboot.console=ttyAMA2 androidboot.hardware=st-ericsson mem=96M@0 mem_mtrace=15M@96M mem_mshared=1M@111M mem_modem=16M@112M mem=32M@128M mem_issw=1M@160M hwmem=167M@161M mem=696M@328M vmalloc=384M mpcore_wdt.mpcore_margin=359' --kernel zImage --ramdisk ramdisk.img --base 0x0 --output kernel-Stock.img
# Create Kernel.elf
echo "-- Creating Kernel.elf File ..."
python mkelf.py -o kernel.elf zImage@0x00008000 ramdisk.img@0x1000000,ramdisk cmdline.txt@cmdline
#Create CWM zip file.
echo "-- Creating CWM Flashable File For This Kernel ..."
zip -r CWM-Stock.zip kernel.elf META-INF
#Clean Up.
echo "-- Cleaning up temp files"
rm ramdisk.img
rm zImage
rm kernel.elf
echo "-------------------------------"
echo -e "-- All Done, Do you want to clean your build enviroment? Note: If you plane to run MakeFile-CM.sh after running this one YOU MUST NOT CLEAN YOUR BUILD ENVIRMOENT (y / n):"
read Result
if [[ "$result" -eq "y" ]]; then
	cd ../kernel/
	make clean
else
exit 2
fi
