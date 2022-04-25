#!/bin/bash
lun=$1
mountPoint=$2
echo "lun=$lun mountPoint=$mountPoint"
scsi=$(lsscsi | awk '$1 == param { print $7 }' param="[1:0:0:$lun]")
echo "logicalDevice=$scsi"

#parted /dev/sdc --script mklabel gpt mkpart xfspart xfs 0% 100%
echo "run sudo parted $scsi --script mklabel gpt mkpart xfspart xfs 0% 100%"
sudo parted $scsi --script mklabel gpt mkpart xfspart xfs 0% 100%

partition="${scsi}1"

echo "partition=$partition"
# UNd dann eine Partition mit dem X-File-System erstellen
echo "run sudo mkfs.xfs $partition"
sudo mkfs.xfs $partition

sudo mkdir -p $mountPoint

## direkter mount
sudo mount $partition $mountPoint

## scheibe den mountpoint in die /etc/fstab
DEF_UUID=$(sudo blkid -s UUID | awk '$1 == pt {print $2}' pt="$partition:" | tr -d '"')
echo $DEF_UUID
# ermitteln des Fils system type.. das sollte eigentlich xfs sein
# (Haben wir ja sogar oben schon so definiert)
DEF_TYPE=$(sudo blkid -s TYPE | awk '$1 == pt {print $2}' pt="$partition:" | tr -d '"' | cut -c 6-)

fstab_config="$DEF_UUID $mountPoint $DEF_TYPE defaults,discard 1 2"
sudo echo $fstab_config
sudo echo $fstab_config >> /etc/fstab