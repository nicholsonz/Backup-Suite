#!/bin/bash

# Archive Backup Script

BACKUP_DIR="/mnt/backup/$(hostname)/arcvdbkp"
TODAY=$(date +"%a")
LOGFILE="$BACKUP_DIR/arcvdbkp.log"
BACKUP_FILES="/home /etc /var/www /srv"

# Check if backup dir exists and if not create it        
if [ -d $BACKUP_DIR ]; then
  echo "Backup directory exists... Backing up dirs/files now."
 elif [ ! -d $BACKUP_DIR ]; then
  echo "Creating backup directory."
   mkdir $BACKUP_DIR
 else
  echo "Error!  Cannot create backup dir. Check dir permissions or backup drive availability."
 exit 1
fi

echo "****************************"
echo "*** Delete Aging Backups ***"
echo
echo

if [ -f $BACKUP_DIR/$TODAY.tgz ]; then
   echo "Deleting old daily backups..."
   echo "$BACKUP_DIR/$TODAY.tgz"
    rm $BACKUP_DIR/$TODAY.tgz
  else
   echo "No old daily backups to delete..."
fi

YROLD_MNTH=$(date +%B-%Y --date="last year")
if [ -f $BACKUP_DIR/$YROLD_MNTH.tgz ]; then
   echo "Deleting old monthly backups..."
   echo "rm $BACKUP_DIR/$YROLD_MNTH.tgz"
    rm $BACKUP_DIR/$YROLD_MNTH.tgz
  else
   echo "No old monthly backups to delete..."
fi  

echo
echo "*** Finished Deleting Aged Backups ***"  
echo "**************************************"
echo

echo
echo "##############################################################"
echo "Start Archive Backup! $(date)"
echo "##############################################################"

echo
echo "Backing up $BACKUP_FILES to $BACKUP_DIR/$TODAY.tgz"
echo


if [ ! -e $BACKUP_DIR/$TODAY.tgz ]; then
tar czp --exclude="*[Cc]ache*" --exclude="[Tt]rash"  --exclude="$BACKUP_DIR" --exclude="/home/*/Downloads" --exclude="*.mp4" -f $BACKUP_DIR/$TODAY.tgz $BACKUP_FILES 2>/dev/null
  echo "$(date) Successful backup!" >> "$BACKUP_DIR/arcvdbkp.log"  
else
  echo "Daily backup already exists."
  echo "$(date) Backup not successful!" >> "$BACKUP_DIR/arcvdbkp.log"
  
fi


# Monthly backups
DAY_NUM=$(date +%u)
MONTH=$(date +%B-%Y)
  if [ ! -e $BACKUP_DIR/$MONTH.tgz ]; then
     echo "Making monthly backup of $MONTH"
    cp $BACKUP_DIR/$TODAY.tgz $BACKUP_DIR/$MONTH.tgz

  else 
     echo "Monthly backup already exists."  
 fi

echo
echo "##########  Directory Listing  ###########"
echo

ls -lh $BACKUP_DIR/

if test -e "$BACKUP_DIR/arcvdbkp.log"; then
 echo
 echo "##############################################################"
 echo "  Archived Backup Completed! $(date)"
 echo "##############################################################" 

else
	touch "$BACKUP_DIR/arcvdbkp.log"
	echo "New log file created!"
fi

exit 0