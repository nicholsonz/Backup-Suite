#!/bin/bash
#
# Sript to backup personal files to an external USB drive.
#
#
MNTPNT='/mnt/backup'
BACKUP_PATH=${MNTPNT}/$(hostname)


echo "############################################"
echo "Start Incremental Backup $(date)" 
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
rsync --perms --archive --verbose --human-readable --itemize-changes --delete-excluded --exclude='.cache' --exclude='Downloads/' /home ${BACKUP_PATH}/ 

echo
echo "---------------------------------------------------"
echo
echo "--------- Starting backup of /etc . . . -----------"
echo

mkdir --parents ${BACKUP_PATH}/etc
rsync --perms --archive --verbose --human-readable --itemize-changes --delete-excluded /etc ${BACKUP_PATH}/ 


echo
echo "---------------------------------------------------"
echo
echo "-------- Starting backup of /var . . . ------------"
echo

mkdir --parents ${BACKUP_PATH}/var
rsync --perms --archive --verbose --human-readable --itemize-changes --progress --delete-excluded --exclude='.Trash-1000' --exclude='*.mp4' /var/www ${BACKUP_PATH}/var/

echo
echo "--------- Starting backup of /srv . . . ----------"
echo

mkdir --parents ${BACKUP_PATH}/srv
rsync --perms --archive --verbose --human-readable --itemize-changes --delete-excluded /srv ${BACKUP_PATH}/

echo
echo "---------------------------------------------------"
echo


echo
echo "##################################################"
echo "Incremental Backup Completed! $(date)  "
echo "##################################################" 

if test -e "${MNTPNT}/$(hostname)/rsync-output.log"; then
	echo "$(date) Success!" >> "${MNTPNT}/$(hostname)/rsync-output.log"
else
	touch ${MNTPNT}/$(hostname)/rsync-output.log 
	echo "$(date) Success!" >> "${MNTPNT}/$(hostname)/rsync-output.log"
        echo "New log file created!"
fi

exit 0 
