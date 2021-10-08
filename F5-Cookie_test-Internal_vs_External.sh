TEMP=~/atemporal.log
TEMPP=~/atemporal2.log
OUTPUT=~/acookie.log
DATE='date'
ts=`date +%Y-%m%d-%H%M%S`

curl -kvs https://www.example.co.uk/client/ &> /dev/stdout | tee -a $TEMP
CookieA[0]=$(grep "LTM" $TEMP |cut -d ' ' -f3 |cut -d '=' -f2 |cut -d '.' -f1)
CookieA[1]=$(grep "LTM" $TEMP |cut -d ' ' -f3 |cut -d '=' -f2 |cut -d '.' -f2)


if grep -q LTM_cookie_global "$TEMP"
then
    # code if fo
        echo "$ts ${CookieA[0]}.${CookieA[1]} External OK" >> $OUTPUT
        echo "External OK"
else
    # code if not found
        echo "$ts External NO" >> $OUTPUT
        echo "External NO"

fi
rm $TEMP

curl -kvs https://www-int.example.co.uk:18325/ &> /dev/stdout | tee -a $TEMPP
CookieB[0]=$(grep "LTM" $TEMPP |cut -d ' ' -f3 |cut -d '=' -f2 |cut -d '.' -f1)
CookieB[1]=$(grep "LTM" $TEMPP |cut -d ' ' -f3 |cut -d '=' -f2 |cut -d '.' -f2)



if grep -q LTM_cookie_global "$TEMPP"
then
    # code if found
        echo "$ts ${CookieB[0]}.${CookieB[1]} Internal OK" >> $OUTPUT
        echo "Internal OK"

else
    # code if not found
        echo "$ts Internal NO" >> $OUTPUT
        echo "Internal NO"

fi
rm $TEMPP
