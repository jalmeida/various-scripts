#!/bin/sh
#
# Based on script:
# @(#) $Id: bigipback.sh,v 1.2 2007/07/05
#
# Simple Shell Script to backup Big-IP Load Balancers
#
# Added: - Email send support
#	 - Changes on code (could be wrong)
#
# Global Parameters:

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin
SCRIPTNAME=`basename $0`
HOSTNAME=`uname -n`
ts=`date +%Y-%m%d-%H%M%S`
today=`date +%Y-%m%d`
yesterday=`TZ=GMT+24 date +%Y-%m%d`

# User Parameters:

BACKUP_DIR=/export/backup/bigipbackup
mailadress="yourname@exmaple.com"
retain_period=45 # in days

# Usage function
usage() {
   echo "usage: ${SCRIPTNAME} -h <Fully qualified hostnmae of the Big-IP which you want to backup>"
        exit 1;
}
	# Main Program
	# Check and read the arguments

	NO_ARGS=0
	if [ $# -eq "$NO_ARGS" ]; then  # Script invoked with no command-line args?
        usage;exit
	fi

	while getopts "h:" option 2>/dev/null
	do
        case $option in
                h) bigiphost=$OPTARG;;
                \?) usage;exit;;
        esac
	done


OLD=${yesterday}-${bigiphost}.bigip.conf
NEW=${today}-${bigiphost}.bigip.conf
DIFF=$today-$bigiphost.bigip.diff

# Check if backup dir exits and jump into it

backupdir=$BACKUP_DIR/$bigiphost
if [ -d $backupdir ]; then
        cd $backupdir
else
        mkdir -p $backupdir
        cd $backupdir
fi


	logfile=$backupdir/$ts.log

	# Log in to Big-IP and start backup command
	# Afterwards copy the backup archive away and remove it from the Big-IP
	# In case of an error mail the Logfile of the process

	ssh $bigiphost "bigpipe config save $ts-$bigiphost" >$logfile 2>&1
        case $? in
                0)
                        ;;
                *)
                        cat $logfile | mailx -s "Big-IP Backup failed for $bigiphost" $mailadress
                        exit 255
                        ;;
        esac

	scp $bigiphost:/var/local/ucs/$ts-$bigiphost.ucs .  >>$logfile 2>&1
        case $? in
                0)
                        ;;
                *)
                        cat $logfile | mailx -s "Big-IP Backup failed for $bigiphost" $mailadress
                        exit 255
                        ;;
        esac

	ssh $bigiphost "rm /var/local/ucs/$ts-$bigiphost.ucs" >>$logfile 2>&1
        case $? in
                0)
                        ;;
                *)
                        cat $logfile | mailx -s "Big-IP Backup failed for $bigiphost" $mailadress
                        exit 255
                        ;;
        esac
	scp $bigiphost:/config/bigip.conf "$today-$bigiphost.bigip.conf" >>$logfile 2>&1
        case $? in
                0)
                        ;;
                *)
                        cat $logfile | mailx -s "Big-IP Backup copy bigip.conf failed for $bigiphost" $mailadress
                        exit 255
                        ;;
        esac


#############################
# Send DIFF Backup to Email


	diff -U0 $OLD $NEW | grep -v @@  >> $logfile 2>&1

	if [ -s $logfile ] ; then
		cat $logfile | mailx -s "Big-IP diff changes from $bigiphost" $mailaddress_csc
				#rm $DIFF
	fi ;


# Clean up Backup Directory and remove the Backups which are older than the retainperiod
find $backupdir/* -mtime $retain_period -exec rm {} \; >/dev/null 2>&1

exit 0;


