#!/bin/bash


BKUP_DIR="/mnt/backup/$(hostname)/sql"
FULLDBBKP_DIR="$BKUP_DIR/mariadbbkp"
TODAY=$(date +"%a")
LOGFILE="$BKUP_DIR/db-backup.log"
dbuser=
dbpasswd=
dbases=($(/usr/bin/mysql -u"$dbuser" -p"$dbpasswd"  -Bse "show databases" | grep -i -v "_schema" | grep -i -v "sys" | grep -i -v "mysql"))

# Check if backup drive is mounted
if [ ! -d $MNTPNT ]; then
	echo "$BKUP_DIR does not exist! Cannot run backup without the destination drive/dir mounted!"
	exit 1
fi

# Check if log file exists and create it if not.
if test -e "$BKUP_DIR/$LOGFILE"; then
    touch "$BKUP_DIR/$LOGFILE"
    echo "New log file created - $LOGFILE"
    echo ""
fi

echo ""
echo "####################################################"
echo "Start DB Backup! $(date)"
echo "####################################################"
echo ""

function do_backups() {

# Do "$db" for Individual databases ONLY or "all" for everything in one or "$1" for all and each individual $dbs
backup_db=$1

  # run dump
  if [ "$backup_db" == "all" ]; then
    BKUP_PATH=$BKUP_DIR/all
    [[ ! -d "$BKUP_PATH" ]] && mkdir -p "$BKUP_PATH"
  	echo "   Creating $BKUP_PATH/$TODAY.sql.gz"
    /usr/bin/mysqldump --all-databases -u"$dbuser" -p"$dbpasswd" | gzip -9 > $BKUP_PATH/$TODAY.sql.gz
  else
    BKUP_PATH=$BKUP_DIR/$db
    [[ ! -d "$BKUP_PATH" ]] && mkdir -p "$BKUP_PATH"
  	echo "   Creating $BKUP_PATH/$TODAY.sql.gz"
    /usr/bin/mysqldump -u"$dbuser" -p"$dbpasswd" $db | gzip -9 > $BKUP_PATH/$TODAY.sql.gz
  fi

# make monthly backups
MONTH=$(date +%b-%Y)

if [ ! -e $BKUP_PATH/$MONTH.sql.gz ]; then
     echo "Making monthly backup of $MONTH"
    cp $BKUP_PATH/$TODAY.sql.gz $BKUP_PATH/$MONTH.sql.gz
 else
  echo "$MONTH backup already exists."

fi

OLD_MNTH=$(date +%b-%Y --date="last year")
if [ -f $BKUP_DIR/$db/$OLD_MNTH.sql.gz ]; then
   echo "Deleting old monthly backups... $BKUP_DIR/$db/$OLD_MNTH.sql.gz"
    rm $BKUP_DIR/$db/$OLD_MNTH.sql.gz
  else
   echo "No old monthly backups to delete..."
fi  
}

for db in "${dbases[@]}"; do
  echo "Starting $db MySQL backup..."
  do_backups $db
done


echo ""
echo "############ Full MariaDB backup ###################"
echo ""

if [ -d "$FULLDBBKP_DIR" ]; then
	echo "Performing full backup . . . "
	rm -rf $FULLDBBKP_DIR/fullbkp
	mariabackup --backup --target-dir=$FULLDBBKP_DIR/fullbkp --user=$dbuser --password=$dbpasswd > /dev/null 2>&1 
  echo ""
  echo "Full Backup Successfully Completed!"
	sleep 3
elif [ ! -d "$FULLDBBKP_DIR" ]; then
  mkdir -p $FULLDBBKP_DIR/fullbkp
  echo "Performing full backup . . ."
  mariabackup --backup --target-dir=$FULLDBBKP_DIR/fullbkp --user=$dbuser --password=$dbpasswd > /dev/null 2>&1
  echo ""
  echo "Full Backup Successfully Completed!"
  sleep 3
else
	echo "--- MariaDB backup encountered errors! ---"
	sleep 5
fi

echo ""
echo ""
echo "##############  Directory Listing  ###############"
echo ""
echo "********** Backup Directories **********"
echo ""

ls -lh $BKUP_DIR/

echo ""
echo ""
echo "*********** Backup Files ***************"
echo ""

ls -lh $BKUP_PATH/

if [ -f $LOGFILE -a $? -eq 0 ]; then
	echo "$(date) - SUCCESS!" >> "$LOGFILE"
  echo ""
  echo "##################################################"
  echo "DB Backup Completed! $(date)"
  echo "##################################################" 
else
	echo "$(date) - FAILED!" >> "$LOGFILE"
  echo ""
  echo "##################################################"
  echo "DB Backup FAILED! $(date)"
  echo "##################################################" 
fi

exit 0 

