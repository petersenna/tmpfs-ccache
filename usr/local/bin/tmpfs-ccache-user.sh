#!/bin/bash

# Load config variables
. /etc/tmpfs-ccache

echo export CCACHE_DIR=$TMPFS
export CCACHE_DIR=$TMPFS

echo ccache -F 0 -M "$SIZE"G
ccache -F 0 -M "$SIZE"G

