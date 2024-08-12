#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# 
# Light sensor test script
#
# Copyright (C) 2024 Subhajit Ghosh <subhajit.ghosh@tweaklogic.com>

SENSOR_NAME="apds9306"
IIO_SYSFS_PATH=/sys/bus/iio/devices/iio:device
RAW_ATTR="in_illuminance_raw"
SCALE_ATTR="in_illuminance_scale"
SCALE_AVAIL_ATTR="in_illuminance_scale_available"
SCALE_CURR=
COUNT=

IIO_DEV_MAX="10"
SLEEP="0.5"

restore_scale()
{
	if [ "x${SCALE_CURR}" != "x" ] && [ -f ${IIO_SYSFS_PATH}${COUNT}/name ]; then
		echo "Restoring scale..."
		echo ${SCALE_CURR} > ${IIO_SYSFS_PATH}${COUNT}/${SCALE_ATTR}
	fi
	exit
}

trap "restore_scale" INT

show_help()
{
	echo "./apds9306_test.sh"
	echo "./apds9306_test.sh read_raw"
	echo "./apds9306_test.sh read_lux"
}

if [ "x${1}" == "x-h" ] || [ "x${1}" == "x--help" ]; then
	show_help
	exit 1
fi

# Search for device
for COUNT in $(seq 0 $IIO_DEV_MAX); do
	NAME=`cat ${IIO_SYSFS_PATH}${COUNT}/name 2>/dev/null`
	if [ "x${NAME}" == "x${SENSOR_NAME}" ]; then
		echo ""
		echo "Found at: ${IIO_SYSFS_PATH}${COUNT}"
		echo ""
		break
	fi
done

# Save current scale
SCALE_CURR=`cat ${IIO_SYSFS_PATH}${COUNT}/${SCALE_ATTR}`

if [ "x${1}" == "xread_raw" ]; then
	echo "Reading raw values"
	while true; do
		cat ${IIO_SYSFS_PATH}${COUNT}/${RAW_ATTR}
		sleep ${SLEEP}
	done
fi

if [ "x${1}" == "xread_lux" ]; then
	echo "Processing lux values"
	while true; do
		VAL=`cat ${IIO_SYSFS_PATH}${COUNT}/${RAW_ATTR}`
        MUL=`cat ${IIO_SYSFS_PATH}${COUNT}/${SCALE_ATTR}`
        awk "BEGIN{printf (\"%f\n\", ($VAL + 0) * $MUL)}"
		sleep ${SLEEP}
	done
fi

SCALE_AVAIL=`cat ${IIO_SYSFS_PATH}${COUNT}/${SCALE_AVAIL_ATTR}`
echo "Running test by using all available scales"
for SCALE in ${SCALE_AVAIL}; do
	echo ""
	echo "Using scale: ${SCALE}"
	echo ${SCALE} > ${IIO_SYSFS_PATH}${COUNT}/${SCALE_ATTR}
	VAL=`cat ${IIO_SYSFS_PATH}${COUNT}/${RAW_ATTR}`
	MUL=`cat ${IIO_SYSFS_PATH}${COUNT}/${SCALE_ATTR}`
	awk "BEGIN{printf (\"%f\n\", ($VAL + 0) * $MUL)}"
	sleep ${SLEEP}
	echo ""
done
echo "Test complete. Restoring scale..."
echo ${SCALE_CURR} > ${IIO_SYSFS_PATH}${COUNT}/${SCALE_ATTR}

trap SIGINT
