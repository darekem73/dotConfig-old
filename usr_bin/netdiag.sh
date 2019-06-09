IP=$(/sbin/ip route | awk '/default/ { print $3 }')
if [ -z "$IP" ]; then
        echo "net down"
        exit 33
fi

P=`ping 8.8.8.8 -n -q -c 1 -W 1 | grep rtt | cut -d= -f 2 | cut -d/ -f 1`

if [ -z "$P" ]; then
	t1=`date +%s.%N`
	eval curl -m 1 google.pl >/dev/null 2>&1 3>&1
	err=$?
	t2=`date +%s.%N`
	if [ $err != 0 ]; then 
		echo "net error"
		exit 33
	else 
		P=`echo "($t2-$t1)*1000/1"|bc`
		echo "curl:"${P%.*}"ms"
	fi
else 
	echo "ping:"${P%.*}"ms"
fi

test ${P%.*} -ge 100 && exit 33 || exit 0

