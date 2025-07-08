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
 elif [ ! -d $BACKUP_DIR ]; then
  echo "Creating backup directory."
   mkdir $BACKUP_DIR
 else
  echo "Error!  Cannot create backup dir. Check dir permissions or backup drive availability."
 exit 1
fi

echo ""
echo "**************** Delete Aging Backups ****************"
echo ""
echo ""

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
  tar czp --exclude="*[Cc]ache*" --exclude="[Tt]rash"  --exclude="$BACKUP_DIR" --exclude="/home/*/Downloads" -f $BACKUP_DIR/$TODAY.tgz $BACKUP_FILES 2>/dev/null
else
  echo "Daily backup already exists."  
fi


# Monthly backups
DAY_NUM=$(date +%u)
MONTH=$(date +%B-%Y)
  if [ ! -e $BACKUP_DIR/$MONTH.tgz ]; then
     echo "Making monthly backup of $MONTH . . . "
     cp $BACKUP_DIR/$TODAY.tgz $BACKUP_DIR/$MONTH.tgz

  else 
     echo "Monthly backup already exists."  
 fi

echo ""
echo "####################  Directory Listing  #####################"
echo ""

ls -lh $BACKUP_DIR/

if [ -f $LOGFILE -a $? -eq 0 ]; then
	echo "$(date) - SUCCESS!" >> "$LOGFILE"
  echo ""
  echo "##############################################################"
  echo "Archived Backup Completed! $(date)"
  echo "##############################################################" 
else
	echo "$(date) - FAILED!" >> "$LOGFILE"
  echo ""
  echo "##############################################################"
  echo "Archived Backup FAILED! $(date)"
  echo "##############################################################" 
fi

exit 0
