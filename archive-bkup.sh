#!/bin/bash

# Archive Backup Script

BACKUP_DIR="/mnt/backup/$(hostname)/arcvdbkp"
TODAY=$(date +"%a")
DAY=$(date +"%A")
LOGFILE="$BACKUP_DIR/arcvdbkp.log"
BACKUP_FILES="/home /etc /var/www /srv"

echo ""
echo "##############################################################"
echo "Start Archive Backup! $(date)"
echo "##############################################################"
echo ""
# Check if backup dir exists and if not create it        
if [ -d $BACKUP_DIR ]; then
  echo "Backup directory exists... Backing up dirs/files now."
  echo ""
 elif [ ! -d $BACKUP_DIR ]; then
  echo "Creating backup directory."
  echo ""
   mkdir $BACKUP_DIR
 else
  echo "Error!  Cannot create backup dir. Check dir permissions or backup drive availability."
 exit 1
fi

# Check if backup log exists and if not create it
if [ ! -f $LOGFILE ]; then
	touch $LOGFILE
       	echo "New log file created - $LOGFILE"
		echo ""
fi

echo ""
echo "**************** Delete Aging Backups ****************"
echo ""
echo ""

if [ -f $BACKUP_DIR/$TODAY.tgz ]; then
   echo "Deleting old daily backups..."
   echo ""
    rm $BACKUP_DIR/$TODAY.tgz
   echo "Deleted $BACKUP_DIR/$TODAY.tgz"
   echo ""
   sleep 3
  else
   echo "No old daily backups to delete..."
fi

YROLD_MNTH=$(date +%B-%Y --date="last year")
if [ -f $BACKUP_DIR/$YROLD_MNTH.tgz ]; then
   echo "Deleting old monthly backups..."
   echo ""
    rm $BACKUP_DIR/$YROLD_MNTH.tgz
   echo "Deleted $BACKUP_DIR/$YROLD_MNTH.tgz"
   echo ""
   sleep 3
  else
   echo "No old monthly backups to delete..."
fi  

echo ""
echo "********** Finished Deleting Aged Backups ************"  
echo "******************************************************"
echo ""

echo ""
echo "*************** Begin Backup Operation ***************" 
echo ""
echo "Backing up $BACKUP_FILES to $BACKUP_DIR/$TODAY.tgz"
echo ""

# Daily backups
if [ ! -e $BACKUP_DIR/$TODAY.tgz ]; then
  echo "Making daily backup of $DAY . . . "
  echo ""
  tar czp --exclude="*[Cc]ache*" --exclude="[Tt]rash"  --exclude="$BACKUP_DIR" --exclude="/home/*/Downloads" -f $BACKUP_DIR/$TODAY.tgz $BACKUP_FILES 2>/dev/null
else
  echo "Daily backup already exists."  
fi

# Monthly backups
DAY_NUM=$(date +%u)
MONTH=$(date +%B-%Y)
  if [ ! -e $BACKUP_DIR/$MONTH.tgz ]; then
     echo "Making monthly backup of $MONTH . . . "
     echo ""
     cp $BACKUP_DIR/$TODAY.tgz $BACKUP_DIR/$MONTH.tgz
  else 
     echo "Monthly backup already exists."  
 fi

echo ""
echo "####################  Directory Listing  #####################"
echo ""

ls -lh $BACKUP_DIR/

if [ $? -ne 0 ]; then
	echo "$(date) - FAILED!" >> "$LOGFILE"
  echo ""
  echo "##############################################################"
  echo "Archived Backup FAILED! $(date)"
  echo "##############################################################" 
else
	echo "$(date) - SUCCESS!" >> "$LOGFILE"
  echo ""
  echo "##############################################################"
  echo "Archived Backup Completed! $(date)"
  echo "##############################################################" 
  
fi

exit 0
