FTP_HOST='avlsite001.example.com'
FTP_USER='username'
FTP_PASSWORD='mypassword'

function sysstat {
echo -e "
#####################################################################
# Health Check Report (CPU,Process,Disk Usage, Memory)
#####################################################################


Hostname : `hostname`
Kernel Version : `uname -r`
Uptime : `uptime | sed 's/.*up \([^,]*\), .*//'`
Last Reboot Time : `who -b | awk '{print $3,$4}'`



*********************************************************************
CPU Load - > Threshold < 1 Normal > 1 Caution , > 2 Unhealthy
*********************************************************************
"
MPSTAT=`which mpstat`
MPSTAT=$?
if [ $MPSTAT != 0 ]
then
        echo "Please install mpstat!"
        echo "On Debian based systems:"
        echo "sudo apt-get install sysstat"
        echo "On RHEL based systems:"
        echo "yum install sysstat"
else
echo -e ""
LSCPU=`which lscpu`
LSCPU=$?
if [ $LSCPU != 0 ]
then
        RESULT=$RESULT" lscpu required to producre acqurate reults"
else
cpus=`lscpu | grep -e "^CPU(s):" | cut -f2 -d: | awk '{print $1}'`
i=0
while [ $i -lt $cpus ]
do
        echo "CPU$i : `mpstat -P ALL | awk -v var=$i '{ if ($3 == var ) print $4 }' `"
        let i=$i+1
done
fi
echo -e "
Load Average : `uptime | awk -F'load average:' '{ print $2 }' | cut -f1 -d,`

Heath Status : `uptime | awk -F'load average:' '{ print $2 }' | cut -f1 -d, | awk '{if ($1 > 2) print "Unhealthy"; else if ($1 > 1) print "Caution"; else print "Normal"}'`
"
fi
echo -e "
*********************************************************************
Process
*********************************************************************

=> Top memory using processs/application

PID %MEM RSS COMMAND
`ps aux | awk '{print $2, $4, $6, $11}' | sort -k3rn | head -n 10`

=> Top CPU using process/application
`top -n10 | head -22 | tail -11`

*********************************************************************
Disk Usage - > Threshold < 90 Normal > 90% Caution > 95 Unhealthy
*********************************************************************
"
df -Pkh | grep -v 'Filesystem' > /tmp/df.status
while read DISK
do
        LINE=`echo $DISK | awk '{print $1,"     ",$6,"  ",$5," used","  ",$4," free space"}'`
        echo -e $LINE
        echo
done < /tmp/df.status
echo -e "
"
}

FILENAME="health-`hostname`-`date +%y%m%d`-`date +%H%M`.txt"
sysstat > $FILENAME
echo -e "Reported file $FILENAME generated in current directory." $RESULT
if [ "$FTP_HOST" != '' ] && [ "$FTP_USER" != '' ] && [ "$FTP_PASSWORD" != '' ]
then
        STATUS=`which curl`
        if [ "$?" != 0 ]
        then
                echo "The program 'curl' is currently not installed."
        else
                curl -u $FTP_USER:$FTP_PASSWORD -T $FILENAME ftp://$FTP_HOST
        fi
fi
