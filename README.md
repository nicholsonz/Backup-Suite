This is a simple system-wide incremental backup script that will back up important directories and files to a backup drive mounted at /mnt/backup.

The archive backup script can perform full system backups daily (7 total for each day of the week, Mon-Sun) & monthly (12 total for each month of the year).

Both scripts utilize rsync.
