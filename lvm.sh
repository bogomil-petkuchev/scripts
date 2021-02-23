#!/bin/bash

if [[ $EUID != 0 ]]; then
    echo -e "The script must be run with root privileges. Please run:\n sudo ./lvm.sh"
    exit 1
fi

function check() {
    echo -e "\e[7mDevice:\e[0m"
    fdisk -l | grep "Disk"
}

function create() {
    fdisk -l | grep "Disk"
    echo "Enter the disk path, eg /dev/sdb:"
    read disk

    echo -e "\e[34mYou selected $disk.\e[0m"
    echo -e "\e[34mGuide for fdisk with step by step options for new partition
     n - new partition
     p - primary partition
     Leave by default the options for partition number and first/last sector. Click Enter 4 times
     p - confirm the changes
     t - change type of the partition
     L - list all codes
     8e - Limux VM\e[0m"
    fdisk $disk
    if [ $? = 0 ]; then
        lsblk | grep "/sd*"
        echo -e "What is the disk number, eg. /dev/sdb1:"
        read number
        pvcreate $number
        pvdislay
    else
        exec 1
    fi

}

function vg() {
    echo -e "Enter a name for the volume group: "
    read -r name
    pvdisplay | grep "$disk"
    echo "Assign the volume group to physical volume: "
    read -r pvname
    vgcreate $name $pvname
    vgdisplay
}

function logical_volume() {
    echo -e "Pick size for the logical volume, eg 1000M * System need some space to hold LVM Information: "
    read -r size
    echo -e "Available volume groups to pick from: "
    sudo vgdisplay | grep "VG Name"
    echo -e "Name of the logical volume: "
    read -r lvname
    echo -e "Name of VG: "
    read -r VG
    sudo lvcreate -n $lvname --size $size $VG
    lvdisplay
}

function format() {
    lvdisplay | grep "LV Name"
    echo -e "Logical volume: "
    read -r lvname
    sudo vgdisplay | grep "VG Name"
    echo -e "Name of VG: "
    read -r VG
    echo -e "Name of the directory to mount: "
    read -r mount
    mkfs.xfs /dev/$VG/$lvname
    if [$? != 0]; then
        sudo apt-get install xfsprogs
        mkfs.xfs /dev/$VG/$lvname
    fi
    mkdir $mount
    mount /dev/$VG/$lvname $mount
}

while :; do
    cat <<EOF
===============================
DISK Management
===============================
Please enter your choice:
    (1)  Check hard disks
    (2)  Create Physical Volume
    (3)  Create Volume Group
    (4)  Create Logical Volume
    (5)  Format & Mount
    (q)  Quit
-------------------------------

EOF
    read -r -n1 -s
    case $REPLY in
    "1") check ;;
    "2") create ;;
    "3") vg ;;
    "4") logical_volume ;;
    "5") format ;;
    "q") exit ;;
    *) echo -e " \e[41mInvalid choice\e[0m" ;;
    esac
done
