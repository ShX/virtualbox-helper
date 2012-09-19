#!/bin/bash

usages() {
	FILE=`basename $0`
	echo "usage: $FILE list       - show VMs names"
	echo "       $FILE start NAME - start VM and add to /etc/hosts"
	echo "       $FILE state NAME - show VM state"
	echo "       $FILE stop NAME  - stop VM  and remove from /etc/hosts"
}

list() {
	echo `VBoxManage list vms | awk -F\" '{print $2}'`
}

exist() {
	list | grep -c "^$1$"
}

state() {
	echo `VBoxManage showvminfo $1 | grep -i state | grep -c running`
}


case $1 in
list)
	list
	;;
state)
	if [ -z "$2" ] ; then 
		echo >&2 Missing parameter NAME
		usages
		exit
	elif [ $(exist $2) -ne 1 ] ; then
		echo >&2 VM $2 not exists
		exit
	elif [ $(state $2) -eq 0 ] ; then
		echo VM $2 running
	else
		echo VM $2 power off
	fi
	;;
start)
	if [ -z "$2" ] ; then
		echo >&2 Missing parameter NAME
		usages
		exit
	elif [ $(exist $2) -ne 1 ] ; then
		echo >&2 VM $2 not exists
		exit
	elif [ $(state $2) -ne 0 ] ; then
		echo VM $2 allready running
		exit
	else
		VBoxManage startvm $2 --type headless
		echo Wait for IP...
		IP=`VBoxManage guestproperty wait $2 "/VirtualBox/GuestInfo/Net/0/V4/IP"`
		IP=`echo $IP | awk -F, '{print $2}' | awk '{print $2}'`
		HOST="$IP  $2 vm-$2 # VirtualBox $2"
		echo Add $2 to /etc/hosts:
		echo $HOST
		echo $HOST | sudo sh -c "cat >> /etc/hosts"
	fi
	;;
stop)
	if [ -z "$2" ] ; then
		echo >&2 Missing parameter NAME
		usages
		exit
	elif [ $(exist $2) -ne 1 ] ; then
		echo >&2 VM $2 not exists
		exit
	elif [ $(state $2) -ne 1 ] ; then
		echo VM $2 is not running
		exit
    else
		VBoxManage controlvm $2 acpipowerbutton
		echo Remove $2 from /etc/hosts:
		grep "$2" /etc/hosts
		grep -v "$2" /etc/hosts | sudo sh -c "cat > /etc/hosts"
	fi
	;;
*)
	usages
	;;
esac
