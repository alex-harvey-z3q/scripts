#!/bin/bash

# check setup directories.
VM_DIR=$HOME/VMs/
SHOWOFF_DIR=$HOME/git/courseware-fundamentals/
[ ! -d $VM_DIR ] && fail "$VM_DIR: directory doesn't exit. Please create and copy zip files to this directory"
[ ! -d $SHOWOFF_DIR ] && fail "$SHOWOFF_DIR: directory doesn't exist. Please clone the courseware in $SHOWOFF_DIR"

# versions.
CENTOS_VER=6.3-pe-3.0.1
UBUNTU_VER=12.04.1-pe-3.0.0
CENTOS_CKSUM=3837395027
UBUNTU_CKSUM=846045164

# master configuration.
MASTER_VCPUS=2
MASTER_MEM=4096

# MAC addresses.
MASTER_MAC=de:ad:be:ef:00:03
CLIENT_MAC=de:ad:be:ef:00:04
UBUNTU_MAC=de:ad:be:ef:00:05
SPARE1_MAC=de:ad:be:ef:00:06
SPARE2_MAC=de:ad:be:ef:00:07

# IP addresses.
MASTER_IP=10.0.1.3
CLIENT_IP=10.0.1.4
UBUNTU_IP=10.0.1.5
SPARE1_IP=10.0.1.6
SPARE2_IP=10.0.1.7

# other constants.
DATE=`date +%e%b |sed -e 's/ //'`
VMRUN="/Applications//VMware Fusion.app/Contents/Library/vmrun"
CENTOS_ZIP=puppet-vmware.zip
UBUNTU_ZIP=ubuntu-$UBUNTU_VER-vmware.zip
MASTER_DIR=puppet-master-$DATE.$$
CLIENT_DIR=puppet-client-$DATE.$$
UBUNTU_DIR=puppet-ubuntu-$DATE.$$
SPARE1_DIR=puppet-spare1-$DATE.$$
SPARE2_DIR=puppet-spare2-$DATE.$$
CENTOS_VMX=centos-$CENTOS_VER.vmx
UBUNTU_VMX=ubuntu-$UBUNTU_VER.vmx
SPARE1_VMX=centos-$CENTOS_VER.vmx
SPARE2_VMX=centos-$CENTOS_VER.vmx

# functions.
usage() {
  cat <<EOF
Usage: $0 [-h]
This utility automates many of the Puppet Fundamentals laptop set up steps.

If you haven't done so already, create a directory $VM_DIR and copy $CENTOS_ZIP and $UBUNTU_ZIP to this directory:

$ mkdir $HOME/VMs/
$ cd $HOME/VMs/
$ curl -O http://downloads.puppetlabs.com/training/$CENTOS_ZIP
$ curl -O http://downloads.puppetlabs.com/training/$UBUNTU_ZIP

Also make sure you have cloned the courseware to $SHOWOFF_DIR:

$ git clone https://github.com/puppet-training/courseware-fundamentals

If the VM image zip files change, this script will error out with the message, "unexpected cksum (new version of the zip file?)".  In that case, the following steps need to be performed to update this script:

1)  Run cksum against them and update the values of \$CENTOS_CKSUM and/or \$UBUNTU_CKSUM.
2)  If necessary, also update \$CENTOS_VMX and/or \$UBUNTU_VMX with correct paths to the new vmx files.

Finally, ensure that you have configured your Airport Express to map MAC addresses to the corresponding IP addresses:

MASTER: $MASTER_MAC -> $MASTER_IP
CLIENT: $CLIENT_MAC -> $CLIENT_IP
UBUNTU: $UBUNTU_MAC -> $UBUNTU_IP
SPARE1: $SPARE1_MAC -> $SPARE1_IP
SPARE2: $SPARE2_MAC -> $SPARE2_IP

EOF
  exit 0
}

fail() {
  echo "$1"
  exit 1
}

# help message.
[ ! -z $1 ] && usage

# working directory.
cd $VM_DIR/

# sanity checking.
[ ! -x "$VMRUN" ] && fail "$VMRUN: file not found (is VMware Fusion installed?)"
[ ! -e $CENTOS_ZIP ] && fail "$CENTOS_ZIP: file not found"
[ ! -e $UBUNTU_ZIP ] && fail "$UBUNTU_ZIP: file not found"
[ $(cksum $CENTOS_ZIP |awk '{print $1}') -ne $CENTOS_CKSUM ] && \
  fail "$CENTOS_ZIP: unexpected cksum (new version of the zip file?)"
[ $(cksum $UBUNTU_ZIP |awk '{print $1}') -ne $UBUNTU_CKSUM ] && \
  fail "$UBUNTU_ZIP: unexpected cksum (new version of the zip file?)"

# kill and restart showoff if necessary.
if ps -ef |grep -q [s]howoff
then
  pid=`ps -ef |awk '/[s]howoff/ {print $2}'`
  kill $pid
fi

# unzip images.
mkdir $MASTER_DIR/
mkdir $CLIENT_DIR/
mkdir $UBUNTU_DIR/
mkdir $SPARE1_DIR/
mkdir $SPARE2_DIR/
unzip -d $MASTER_DIR/ $CENTOS_ZIP
unzip -d $CLIENT_DIR/ $CENTOS_ZIP
unzip -d $UBUNTU_DIR/ $UBUNTU_ZIP
unzip -d $SPARE1_DIR/ $CENTOS_ZIP
unzip -d $SPARE2_DIR/ $CENTOS_ZIP

# h/w configuration for master.
perl -pi -e '
  s/numvcpus = ".*"/numvcpus = "'$MASTER_VCPUS'"/; 
  s/memsize = ".*"/memsize = "'$MASTER_MEM'"/;
  s/ethernet0.connectionType = "nat"/ethernet0.connectionType = "bridged"/;
    # insert an ethernet0.address line here as well as set addressType
    # to "static":
  s/ethernet0.addressType = "generated"/ethernet0.addressType = "static"
ethernet0.address = "'$MASTER_MAC'"/;
' \
  $MASTER_DIR/$CENTOS_VMX
echo 'tools.syncTime = "TRUE"' >>$MASTER_DIR/$CENTOS_VMX

# h/w configuration for clients.
edit_client_vmx() {
  mac=$1; vmx_file=$2
  echo "configuring client VM ..."
  perl -pi -e '
    s/ethernet0.connectionType = "nat"/ethernet0.connectionType = "bridged"/;
    s/ethernet0.addressType = "generated"/ethernet0.addressType = "static"
ethernet0.address = "'$mac'"/;
  ' \
    $vmx_file
  echo 'tools.syncTime = "TRUE"' >>$vmx_file
}
edit_client_vmx $CLIENT_MAC $CLIENT_DIR/$CENTOS_VMX
edit_client_vmx $UBUNTU_MAC $UBUNTU_DIR/$UBUNTU_VMX
edit_client_vmx $SPARE1_MAC $SPARE1_DIR/$CENTOS_VMX
edit_client_vmx $SPARE2_MAC $SPARE2_DIR/$CENTOS_VMX

# upgrade and boot them.
"$VMRUN" -T fusion upgradevm $MASTER_DIR/$CENTOS_VMX 
"$VMRUN" -T fusion upgradevm $CLIENT_DIR/$CENTOS_VMX 
"$VMRUN" -T fusion upgradevm $UBUNTU_DIR/$UBUNTU_VMX 
"$VMRUN" -T fusion upgradevm $SPARE1_DIR/$SPARE1_VMX 
"$VMRUN" -T fusion upgradevm $SPARE2_DIR/$SPARE2_VMX 
"$VMRUN" -T fusion start $MASTER_DIR/$CENTOS_VMX 
"$VMRUN" -T fusion start $CLIENT_DIR/$CENTOS_VMX 
"$VMRUN" -T fusion start $UBUNTU_DIR/$UBUNTU_VMX 
"$VMRUN" -T fusion start $SPARE1_DIR/$SPARE1_VMX 
"$VMRUN" -T fusion start $SPARE2_DIR/$SPARE2_VMX 

# start showoff.
cd $SHOWOFF_DIR/
showoff serve
