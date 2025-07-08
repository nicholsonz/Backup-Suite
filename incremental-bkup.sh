#!/bin/bash
#
# Sript to backup personal files to an internal/external drive.
# can be used with cron to create daily incremental backups
#

MNTPNT='/mnt/backup'
BACKUP_PATH=${MNTPNT}/$(hostname)

echo ""
echo ""
echo "##########################################################"
echo "Start Incremental Backup $(date)" 
echo "##########################################################"
echo ""

# Check if backup drive is mounted at the mount point
if [ ! -d "$MNTPNT" ] || [ -z "$MNTPNT" ]; then
	echo "Drive not mounted! Cannot run backup without backup volume!"
	echo "Check that backup drive is mounted at $MNTPNT. If not then mount drive (e.g. sudo mount /dev/sdb /mnt/backup) and run script again."
	exit 1
fi
# Check if backup log exists and if not create it
if [ ! -f ${MNTPNT}/$(hostname)/rsync-output.log ]; then
	touch ${MNTPNT}/$(hostname)/rsync-output.log
       	echo "New log file created - ${MNTPNT}/$(hostname)/rsync-output.log"
		echo ""
fi

echo "**** Backup directory path is ${BACKUP_PATH} ****"
echo ""
echo "--------- Starting backup of /home . . . ----------"
echo ""

mkdir --parents ${BACKUP_PATH}/home
rsync --perms --archive --verbose --human-readable --itemize-changes --delete-excluded --exclude='.cache' --exclude='Downloads/' /home ${BACKUP_PATH}/ 

echo ""
echo "---------------------------------------------------"
echo ""
echo "--------- Starting backup of /etc . . . -----------"
echo ""

mkdir --parents ${BACKUP_PATH}/etc
rsync --perms --archive --verbose --human-readable --itemize-changes --delete-excluded /etc ${BACKUP_PATH}/ 

echo ""
echo "---------------------------------------------------"
echo ""
echo "-------- Starting backup of /var . . . ------------"
echo ""

mkdir --parents ${BACKUP_PATH}/var
rsync --perms --archive --verbose --human-readable --itemize-changes --delete-excluded --exclude='.Trash-1000' /var/www ${BACKUP_PATH}/var/

echo ""
echo "---------------------------------------------------"
echo ""
echo "--------- Starting backup of /srv . . . ----------"
echo ""

mkdir --parents ${BACKUP_PATH}/srv
rsync --perms --archive --verbose --human-readable --itemize-changes --delete-excluded /srv ${BACKUP_PATH}/

echo ""
echo "---------------------------------------------------"
echo ""

echo "##########  Directory Listing  ###########"
echo ""

ls -lh $BACKUP_PATH/

if [ -f ${MNTPNT}/$(hostname)/rsync-output.log -a $? -eq 0 ]; then
	echo "$(date) - SUCCESS!" >> "${MNTPNT}/$(hostname)/rsync-output.log"
	echo ""
	echo ""
	echo "################################################################"
	echo "Incremental Backup Completed! $(date)"
	echo "################################################################" 
else
	echo "$(date) - FAILED!" >> "${MNTPNT}/$(hostname)/rsync-output.log"
	echo ""
	echo ""
	echo "################################################################"
	echo "Incremental Backup FAILED! $(date)"
	echo "################################################################" 
fi


exit 0 


