# SPDX-License-Identifier: GPL-2.0
#
# Makefile for IIO GTS helper and APDS9306.
#
# Copyright (C) 2024 Subhajit Ghosh <subhajit.ghosh@tweaklogic.com>

ifeq ($(BUILD),iio_gts)
	obj-m += ./drivers/iio/industrialio-gts-helper.o ./drivers/iio/light/apds9306.o
else
	obj-m += ./drivers/iio/light/apds9306.o
endif

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules
clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

