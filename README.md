### APDS9306 Ambient Light Sensor driver backport

Backport of Avago (Broadcom) APDS9306 Ambient Light Sensor Linux kernel driver to work with older Linux kernel versions from 5.15.67 to 6.9.9. The mainlined version should be used from 6.10 onwards. 

__It is strongly advised to use the latest versions of Linux kernel and the APDS9306 driver which is available with latest Linux kernels. The mainline kernel driver is maintained as of writing this.__

This backport is an attempt to make life easier for companies where kernel upgrades are expensive.
Although care has been taken to test this backport but this port is hacky and inefficient compared to the mainline version and may not work as well as the mainline version.

__This driver uses IIO GTS (Gain Time Scale) helper namespace written by Matti Vaittinen.__ 
IIO GTS gets compiles as a separate ko file and is a dependency for APDS9306 driver.
IIO GTS support is available since Linux kernel 6.4 (approx). The build script in this repository detects the kernel version of the target and builds `industrialio-gts-helper.ko` module if the target kernel version is prior to 6.4.

#### <u>About</u>
APDS9306 is an Ambient Light Sensor which comes in two packages - *apds-9306* and *apds-9306-65*.
The datasheet can be found [here](https://docs.broadcom.com/docs/AV02-4755EN).

#### <u>Static build</u>
This driver can be built statically in the Linux kernel image by copying the *drivers* and *include* directories into the target Linux kernel source and updating the Makefile(s), Kconfig(s) and using menuconfig. This process is not covered here.

#### <u>External build</u>
Output of the build script in this repo:
```
PC $> ls output/
apds9306.ko  industrialio-gts-helper.ko
```

#### <u>Reference hardware</u>
Reference board used here is STM32MP157C-DK2 from ST micro electronics.
Link to development board can be found [here](https://www.st.com/en/evaluation-tools/stm32mp157c-dk2.html).


#### <u>Reference embedded Linux ecosystem</u>
Reference embedded Linux ecosystem is OpenSTLinux from ST micro electronics as well.
The process and the steps for building are similar for any other Yocto based distributions.
Link to set up the board with a Starter pack can be found [here](https://wiki.st.com/stm32mpu/wiki/Getting_started/STM32MP1_boards/STM32MP157x-DK2/Let%27s_start/Populate_the_target_and_boot_the_image).

#### <u>Setting up the build environment</u>
1. A cross-compiler toolchain has to be setup.
   Link to OpenSTLinux SDK setup can be found [here](https://wiki.st.com/stm32mpu/wiki/Getting_started/STM32MP1_boards/STM32MP157x-DK2/Develop_on_Arm%C2%AE_Cortex%C2%AE-A7/Install_the_SDK).
2. A Linux kernel build output directory has to be present.
   Steps to cross-compile Linux kernel for OpenSTLinux can be found [here](https://wiki.st.com/stm32mpu/wiki/Getting_started/STM32MP1_boards/STM32MP157x-DK2/Develop_on_Arm%C2%AE_Cortex%C2%AE-A7/Modify,_rebuild_and_reload_the_Linux%C2%AE_kernel).

#### <u>Build script</u>
```
PC $> ./apds9306_backport.sh
./apds9306_backport.sh build <kernel_build_dir_path>
./apds9306_backport.sh clean <kernel_build_dir_path>
```

#### <u>Toolchain setup</u>
```
PC $> source ../../toolchain_mickledore-mpu-v24.06.26/environment-setup-cortexa7t2hf-neon-vfpv4-ostl-linux-gnueabi
```

#### <u>Compile</u>
For Linux kernel 5.15.67:
```
PC $> ./apds9306_backport.sh build ../../kernel_kirkstone_22.11.23/stm32mp1-openstlinux-5.15-yocto-kirkstone-mp1-v22.11.23/sources/arm-ostl-linux-gnueabi/linux-stm32mp-5.15.67-stm32mp-r2-r0/build
```
For Linux kernel 6.1.82:
```
PC $> ./apds9306_backport.sh build ../../kernel_mickledore-mpu-v24.06.26/stm32mp1-openstlinux-6.1-yocto-mickledore-mpu-v24.06.26/sources/arm-ostl-linux-gnueabi/linux-stm32mp-6.1.82-stm32mp-r2-r0/build
```
**apds9306.ko**  and **industrialio-gts-helper.ko** files are places in the *output* directory.

#### <u>Compile device tree blob</u>
A reference device tree source file is provided - **arch/arm/boot/dts/stm32mp157c-dk2.dts**
Node name is **light-sensor@52**
Steps to compile the kernel and device tree can be found [here](https://wiki.st.com/stm32mpu/wiki/Getting_started/STM32MP1_boards/STM32MP157x-DK2/Develop_on_Arm%C2%AE_Cortex%C2%AE-A7/Modify,_rebuild_and_reload_the_Linux%C2%AE_kernel).
A device tree overlay file can also be used.

#### <u>Install</u>
Copy across the device tree blob (reboot required):

```
PC $> scp ../../kernel_kirkstone_22.11.23/stm32mp1-openstlinux-5.15-yocto-kirkstone-mp1-v22.11.23/sources/arm-ostl-linux-gnueabi/linux-stm32mp-5.15.67-stm32mp-r2-r0/build/arch/arm/boot/dts/stm32mp157c-dk2.dtb root@192.168.7.1:/boot/stm32mp157c-dk2.dtb
```
Copy across the driver file:
```
PC $> scp output/apds9306.ko root@192.168.7.1:/lib/modules/6.1.28/kernel/drivers/iio/light/apds9306.ko
```
Copy across the IIO GTS helper (if it exists):
```
PC $> scp output/industrialio-gts-helper.ko root@192.168.7.1:/lib/modules/6.1.82/kernel/drivers/iio/
```
Run depmod:
```
ssh root@192.168.7.1 /sbin/depmod -a
ssh root@192.168.7.1 sync
```

#### <u>Verify</u>
```
root@stm32mp1:~# modinfo apds9306
filename:       /lib/modules/6.1.82/kernel/drivers/iio/light/apds9306.ko
import_ns:      IIO_GTS_HELPER
license:        GPL
description:    APDS9306 Ambient Light Sensor driver
author:         Subhajit Ghosh <subhajit.ghosh@tweaklogic.com>
alias:          of:N*T*Cavago,apds9306C*
alias:          of:N*T*Cavago,apds9306
depends:        industrialio-gts-helper
name:           apds9306
vermagic:       6.1.82 SMP preempt mod_unload modversions ARMv7 p2v8 
```

#### <u>Run</u>
```
BOARD $> modprobe apds9306
```

#### <u>Clean</u>
Removes the ***output*** directory and build artifacts.
```
PC $> ./apds9306_backport.sh clean ../../kernel_kirkstone_22.11.23/stm32mp1-openstlinux-5.15-yocto-kirkstone-mp1-v22.11.23/sources/arm-ostl-linux-gnueabi/linux-stm32mp-5.15.67-stm32mp-r2-r0/build
```

#### <u>Test</u>
Assuming the target board has only one APDS9306 sensor installed, the *apds9306_test.sh* can be run to test the device through sysfs interface.
Copy across *apds9306_test.sh*
```
PC $> scp apds9306_test.sh root@192.168.7.1:~/
```
```
root@stm32mp1:~# ./apds9306_test.sh --help
./apds9306_test.sh
./apds9306_test.sh read_raw
./apds9306_test.sh read_lux
```
Running the command without parameters starts the scale test:
```
root@stm32mp1:~# ./apds9306_test.sh

Found at: /sys/bus/iio/devices/iio:device0

Running test by using all available scales

Using scale: 14.009712000
126.087408


Using scale: 4.669904000
126.087408
```
Read Lux values:
```
root@stm32mp1:~# ./apds9306_test.sh read_lux

Found at: /sys/bus/iio/devices/iio:device0

Processing lux values
127.984556
127.400818
126.233342
124.628063
^CRestoring scale...
```
Read raw values:
```
root@stm32mp1:~# ./apds9306_test.sh read_raw

Found at: /sys/bus/iio/devices/iio:device0

Reading raw values
906
889
897
894
^CRestoring scale...
```

#### <u>Using interrupts</u>
TODO
