#!/bin/bash

if [[ $EUID != 0 ]]; then
    echo -e "The script must be run with root privileges. Please run:\n sudo ./lvm.sh"
    exit 1
fi

function check {
    echo -e "\e[7mDevice:\e[0m"
    fdisk -l | grep -A 4 "Device" | awk '{print $1,$5}'
}

function create {
    list=$()
}

while :; do
    cat <<EOF
===========================
DISK Management
===========================
Please enter your choice:
    (1)  Check hard disks
    (2)  Create Partition
    (q)  Quit
---------------------------

EOF
    read -r -n1 -s
    case $REPLY in
    "1") check ;;
    "2") create ;;
    "q") exit ;;
    *) echo -e " \e[41mInvalid choice\e[0m" ;;
    esac
done
