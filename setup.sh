#!/bin/bash -x
cd $HOME/VMs/
DATE=`date +%e%b |sed -e 's/ //'`
mkdir puppet-master-$DATE
mkdir puppet-client-$DATE
mkdir puppet-ubuntu-$DATE
unzip -d puppet-master-$DATE/ puppet-vmware.zip
unzip -d puppet-client-$DATE/ puppet-vmware.zip
unzip -d puppet-ubuntu-$DATE/ ubuntu-12.04.1-pe-3.0.0-vmware.zip
