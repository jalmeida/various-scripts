#############################
## EXTRACT VIRTUAL IPS = AVAILABLE
## Delele line that match "offline" and "unknown" and previous line
## Delete line with "available" and format to output Virtual in column
BASEDIR=`dirname $0`
CSVFILE=$BASEDIR/POOL-VIP-MAPPING-`date +%Y%m%d-%H%M`.cvs
TEMPVIPFILE=$BASEDIR/temp_listofvips

echo "POOLNAME,VIPNAME"|tee $CSVFILE

LISTOFVIPS=`tmsh -q show ltm virtual | egrep "Virtual Server|Availability" | \
grep -v "Availability" | \
cut -d " " -f3`

#LISTOFVIPS=`tmsh -q show ltm virtual | egrep "Virtual Server|Availability" | \
#sed -n '/offline/{n;x;d;};x;1d;p;${x;p;}' | \
#sed -n '/unknown/{n;x;d;};x;1d;p;${x;p;}' | \
#grep -v "available" | \
#cut -d " " -f3`

for VIRTUAL in $LISTOFVIPS
do
        echo $VIRTUAL
        VIP_IP=`tmsh -q list ltm virtual $VIRTUAL destination | grep "destination" | cut -d " " -f6`
        VIP_POOL=`tmsh -q list ltm virtual $VIRTUAL pool | grep "pool"  | cut -d " " -f6`
                VIP_STATUS=`tmsh -q show ltm virtual $VIRTUAL | grep "Availability" | cut -d ":" -f2 | cut -d " " -f2`

        # Get member list, print ip, delete first line, column to row
        VIP_MEMBERS=`tmsh show ltm pool $VIP_POOL members | egrep "Ltm::Pool" | cut -d " " -f 6 | sed  '/^$/d' | tr '\n' ' '`
        echo $VIP_STATUS,$VIRTUAL,$VIP_IP,$VIP_POOL,$VIP_MEMBERS | tee -a $CSVFILE
done

