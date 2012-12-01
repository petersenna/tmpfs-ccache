#!/bin/bash

# From config file. See: /etc/systemd/system/tmpfs-ccache.service
TMPFS=$2
PERSISTENT=$3
SIZE=$4

# -a for archive
RSYNC_OPTS="-a"

if [ "$1" == "start" ];then
	echo Start T=$TMPFS P=$PERSISTENT S=$SIZE

	if [ ! -d $PERSISTENT ];then
		echo $PERSISTENT do not exist. Creating...
		mkdir -p $PERSISTENT
		chmod 777 $PERSISTENT
	fi

	umount $TMPFS &> /dev/null
	rm -rf $TMPFS &> /dev/null

	mkdir -p $TMPFS
	if [ $? != 0 ];then
		echo Error creating $TMPFS
		exit 1
	fi

	mount -t tmpfs -o size="$SIZE"G tmpfs $TMPFS
	if [ $? != 0 ];then
		echo Error mounting $TMPFS
		exit 1
	fi

	rsync $RSYNC_OPTS $PERSISTENT/ $TMPFS/ &> /dev/null
	if [ $? != 0 ];then
		echo Error on rsync $RSYNC_OPTS $PERSISTENT/ $TMPFS/
		exit 1
	fi
	exit 0
fi

if [ "$1" == "stop" ];then
	echo Stop

	rsync $RSYNC_OPTS --delete $TMPFS/ $PERSISTENT/ &> /dev/null
	if [ $? != 0 ];then
		echo Error on rsync $RSYNC_OPTS --delete $TMPFS/ $PERSISTENT/
		exit 1
	fi

	umount $TMPFS
	if [ $? != 0 ];then
		echo Error umounting $TMPFS
		exit 1
	fi

	rm -rf $TMPFS
	if [ $? != 0 ];then
		echo Error  $TMPFS
		exit 1
	fi

	exit 0
fi

echo You should not call me directly
exit 1
