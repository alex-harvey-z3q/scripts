#!/bin/bash -v -x
cd $HOME/VMs/
DATE=`date +%e%b |sed -e 's/ //'`
VMRUN="/Applications//VMware Fusion.app/Contents/Library/vmrun"
CENTOS_ZIP=puppet-vmware.zip
UBUNTU_ZIP=ubuntu-12.04.1-pe-3.0.0-vmware.zip
MASTER_DIR=puppet-master-$DATE
CLIENT_DIR=puppet-client-$DATE
UBUNTU_DIR=puppet-ubuntu-$DATE
CENTOS_VMX=centos-6.3-pe-3.0.1.vmx
UBUNTU_VMX=ubuntu-12.04.1-pe-3.0.0.vmx
SHOWOFF_DIR=$HOME/git/courseware-fundamentals

# unzip images.
mkdir $MASTER_DIR
mkdir $CLIENT_DIR
mkdir $UBUNTU_DIR
unzip -d $MASTER_DIR/ $CENTOS_ZIP
unzip -d $CLIENT_DIR/ $CENTOS_ZIP
unzip -d $UBUNTU_DIR/ $UBUNTU_ZIP

# h/w configuration for master.
perl -pi -e '
  s/numvcpus = "\d+"/numvcpus = "2"/; 
  s/memsize = "\d+"/memsize = "4096"/;
  s/ethernet0.connectionType = "nat"/ethernet0.connectionType = "bridged"/;
' \
  $MASTER_DIR/$CENTOS_VMX

# h/w configuration for clients.
perl -pi -e '
  s/ethernet0.connectionType = "nat"/ethernet0.connectionType = "bridged"/
' \
  $CLIENT_DIR/$CENTOS_VMX \
  $UBUNTU_DIR/$UBUNTU_VMX

# upgrade and boot them.
"$VMRUN" -T fusion upgradevm $MASTER_DIR/$CENTOS_VMX 
"$VMRUN" -T fusion upgradevm $CLIENT_DIR/$CENTOS_VMX 
"$VMRUN" -T fusion upgradevm $UBUNTU_DIR/$UBUNTU_VMX 
"$VMRUN" -T fusion start $MASTER_DIR/$CENTOS_VMX 
"$VMRUN" -T fusion start $CLIENT_DIR/$CENTOS_VMX 
"$VMRUN" -T fusion start $UBUNTU_DIR/$UBUNTU_VMX 

# start showoff.
cd $SHOWOFF_DIR
showoff serve -f showoff.json
