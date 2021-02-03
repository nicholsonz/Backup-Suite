#!/bin/bash
# Sript to backup personal files to an external USB drive.
#
########################################################
MNTPNT='/mnt/backup'
current_year=`date +%Y`
backup_path=${MNTPNT}/$(hostname)/${current_year}
#######################################################


echo "############################################"
echo "  Start Backup $(date)" 
echo "############################################"
echo

# Check whether target volume is mounted, and mount it if not.

#if ! mountpoint -q ${MNTPNT}/; then
#	echo "Mounting the external USB drive."        
#	echo "Mountpoint is ${MNTPNT}"
#	if ! mount /dev/sdb1 ${MNTPNT}; then
#		echo "An error code was returned by mount command!"
#		exit 5
#	else echo "Mounted successfully.";
#	fi
#else echo "${MNTPNT} is already mounted.";
#fi


if ! mountpoint -q ${MNTPNT}/; then
	echo "Drive not mounted! Cannot run backup without backup volume!"
	exit 1
fi

echo "**** Backup storage directory path is ${backup_path} ****"
echo
echo "--------- Starting backup of /home . . . ----------"
echo

# Create the target directory path if it does not already exist.
mkdir --parents ${backup_path}/home

# backup using rsync
sudo rsync --perms --archive --verbose --human-readable --itemize-changes --progress --delete --delete-excluded --exclude='.dbus' --exclude='Examples' --exclude='.local' --exclude='.thumbnails' --exclude='transient-items' --exclude='.cache' --exclude='Steam' --exclude='.steam' --exclude='.zenmap' --exclude='.bash*' --exclude='mail/' /home ${backup_path}/ 

echo
echo "---------------------------------------------------"
echo
echo "--------- Starting backup of /etc . . . -----------"
echo
# Create the target directory path if it does not already exist.
mkdir --parents ${backup_path}/etc


sudo rsync --perms --archive --verbose --human-readable --itemize-changes --progress --delete --delete-excluded /etc ${backup_path}/ 

# print staus of backup to screen and log file
if test -e "${MNTPNT}/$(hostname)/rsync-output.log"; then
	echo "$(date) Success!" >> "${MNTPNT}/$(hostname)/rsync-output.log"
echo
echo "##################################################"
echo "  Backup Completed! $(date)  "
echo "##################################################" 

else
	touch ${MNTPNT}/$(hostname)/rsync-output.log 
	echo "New log file created!"
fi



