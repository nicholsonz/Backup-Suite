#!/bin/bash
#
# Backup personl files/dirs to local drive
#
########################################################
MNTPNT='/mnt/backup'
BACKUP_PATH=${MNTPNT}/$(hostname)
#######################################################


echo "############################################"
echo "  Start Backup $(date)" 
echo "############################################"
echo

if [ ! -d $MNTPNT ]; then
	echo "Drive not mounted! Cannot run backup without backup volume!"
	exit 1
fi

echo "**** Backup storage directory path is ${BACKUP_PATH} ****"
echo
echo "--------- Starting backup of /home . . . ----------"
echo


mkdir --parents ${BACKUP_PATH}/home


sudo rsync --perms --archive --verbose --human-readable --itemize-changes --delete --delete-excluded --exclude='.dbus' --exclude='Examples' --exclude='.local' --exclude='.thumbnails' --exclude='transient-items' --exclude='.cache' --exclude='Steam' --exclude='.steam' --exclude='.zenmap' --exclude='.bash*' --exclude='mail/' /home ${BACKUP_PATH}/ 

echo
echo "---------------------------------------------------"
echo
echo "--------- Starting backup of /etc . . . -----------"
echo


mkdir --parents ${BACKUP_PATH}/etc


sudo rsync --perms --archive --verbose --human-readable --itemize-changes --delete --delete-excluded /etc ${BACKUP_PATH}/ 


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

exit 0
