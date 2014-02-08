#!/bin/bash

# usage.
usage() {
  echo "$0 [ -nat | -h, --help ]"
  echo "This script fires up a single instance of the training VM"
  exit 1
}
[ "$1" = -h -o "$1" = --help ] && usage

fail() {
  echo "$1"
  exit 1
}

# check setup directories.
VM_DIR=$HOME/VMs/
[ ! -d $VM_DIR ] && fail "$VM_DIR: directory doesn't exit. Please create and copy zip files to this directory"

# versions.
CENTOS_VER=6.3-pe-3.0.1
CENTOS_CKSUM=3837395027

## MAC addresses.
#CLIENT_MAC=de:ad:be:ef:00:04
#
## IP addresses.
#CLIENT_IP=10.0.1.4

# other variables.
DATE=`date +%e%b |sed -e 's/ //'`
VMRUN="/Applications//VMware Fusion.app/Contents/Library/vmrun"
CENTOS_ZIP=puppet-vmware.zip
CLIENT_DIR=puppet-client-$DATE.$$
CENTOS_VMX=centos-$CENTOS_VER.vmx

# help message.
[ ! -z $1 ] && usage

# working directory.
cd $VM_DIR/

# sanity checking.
[ ! -x "$VMRUN" ] && fail "$VMRUN: file not found (is VMware Fusion installed?)"
[ ! -e $CENTOS_ZIP ] && fail "$CENTOS_ZIP: file not found"
[ $(cksum $CENTOS_ZIP |awk '{print $1}') -ne $CENTOS_CKSUM ] && \
  fail "$CENTOS_ZIP: unexpected cksum (new version of the zip file?)"

# unzip images.
mkdir $CLIENT_DIR/
unzip -d $CLIENT_DIR/ $CENTOS_ZIP

# h/w configuration for clients.
perl -pi -e 's/ethernet0.connectionType = "nat"/ethernet0.connectionType = "bridged"/' \
  $CLIENT_DIR/$CENTOS_VMX
echo 'tools.syncTime = "TRUE"' >>$CLIENT_DIR/$CENTOS_VMX

# upgrade and boot them.
"$VMRUN" -T fusion upgradevm $CLIENT_DIR/$CENTOS_VMX 
"$VMRUN" -T fusion start $CLIENT_DIR/$CENTOS_VMX 

# end of script.
