#!/bin/sh
#
# @(#) $Id: bconfig_fetch.sh,v 1.3 2007/08/10 11:44:18 ast Exp $
#
# Generic Driver Script for Isiweb4 Config Environment
#
# Tabstop Hint: use ts=3 

PATH=/sbin:/usr/sbin:/bin
export PATH

#
# Global Variables and Config
#
SCRIPTNAME=`basename $0`

BIGIP_INTERNAL="bigip1.example.com bigip2.example.com"
BIGIP_EXTERNAL="bigip3.exmaple.com bigip4.example.com"

BCONF_INFILE=/config/bigip.conf
BCONF_OUTDIR=/var/tmp
BCONF_OUTFILE_INT="Internal-BigIP.conf"
BCONF_OUTFILE_EXT="External-BigIP.conf"

#######################################################
# Main Program
#######################################################

# Fetch Config of Internal BigIP's
cp /dev/null $BCONF_OUTDIR/$BCONF_OUTFILE_INT 
for b in $BIGIP_INTERNAL
do
	echo "###" >> $BCONF_OUTDIR/$BCONF_OUTFILE_INT 
	echo "### Config of: $b ###" >> $BCONF_OUTDIR/$BCONF_OUTFILE_INT
	echo "###" >> $BCONF_OUTDIR/$BCONF_OUTFILE_INT 
	ssh ${b} "cat $BCONF_INFILE" >>  $BCONF_OUTDIR/$BCONF_OUTFILE_INT
done


# Fetch Config of External BigIP's
cp /dev/null $BCONF_OUTDIR/$BCONF_OUTFILE_EXT 
for b in $BIGIP_EXTERNAL
do
	echo "###" >> $BCONF_OUTDIR/$BCONF_OUTFILE_EXT 
	echo "### Config of: $b ###" >> $BCONF_OUTDIR/$BCONF_OUTFILE_EXT
	echo "###" >> $BCONF_OUTDIR/$BCONF_OUTFILE_EXT 
	ssh ${b} "cat $BCONF_INFILE" >>  $BCONF_OUTDIR/$BCONF_OUTFILE_EXT
done

exit 0
