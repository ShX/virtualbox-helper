virtualbox-helper
=================
Small utility for easy manage virtual servers. All servers run in background without GUI.

# Requirements
- VirtualBoxes must be named as a hosted domain
- VirtualBox Guest Additions mus be installed

# Usage
## list
	$ vbox.sh list 
show registered vms

## start
	$ vbox.sh start NAME
- start vm
- add vm to /etc/hosts ( "$NAME" and "vm-$NAME" )

## state
	$ vbox.sh state NAME
show vm state

## stop
	$ vbox.sh stop NAME
- stop vm 
- remove IP from /etc/hosts