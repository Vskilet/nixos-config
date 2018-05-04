#!/run/current-system/sw/bin/bash 

USER=`whoami`
HOSTNAME=`uname -n`

LINUX=`uname -rs`

DISK=`df -m | awk '$NF=="/"{printf "Disk Usage: %d/%dGB (%s)\n", $3/1000,$2/1000,$5}'`

MEMORY=`free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }'`

# time of day
HOUR=$(date +"%H")
if [ $HOUR -lt 12  -a $HOUR -ge 0 ]
then    TIME="morning"
elif [ $HOUR -lt 17 -a $HOUR -ge 12 ] 
then    TIME="afternoon"
else 
    TIME="evening"
fi

#System uptime
uptime=`cat /proc/uptime | cut -f1 -d.`
upDays=$((uptime/60/60/24))
upHours=$((uptime/60/60%24))
upMins=$((uptime/60%60))
upSecs=$((uptime%60))

#System load
LOAD1=`cat /proc/loadavg | awk {'print $1'}`
LOAD5=`cat /proc/loadavg | awk {'print $2'}`
LOAD15=`cat /proc/loadavg | awk {'print $3'}`

IP=`dig +short myip.opendns.com @resolver1.opendns.com`

DOCKER=`docker --version | awk -F'[, ]' '{printf "%s",$3} END {print ""}'`
RKT=`rkt version | awk {'print $3; exit'} `

echo "Good $TIME $USER"

echo "
===========================================================================
 - Hostname............: $HOSTNAME
 - IPv4................: $IP
 - Release.............: `nixos-version`
 - Kernel..............: $LINUX
 - Users...............: Currently `users | wc -w` user(s) logged on
===========================================================================
 - Current user........: $USER
 - CPU usage...........: $LOAD1, $LOAD5, $LOAD15 (1, 5, 15 min)
 - Memory used.........: $MEMORY
 - Swap in use.........: `free -m | tail -n 1 | awk '{print $3}'` MB
 - System uptime.......: $upDays days $upHours hours $upMins minutes $upSecs seconds
 - Disk space ROOT.....: $DISK
===========================================================================
 - Docker..............: $DOCKER
 - rkt.................: $RKT
"
services=( "haproxy.service" "nginx.service" "dovecot2.service" "phpfpm-nextcloud.service" "searx.service" "matrix-synapse.service" "grafana.service" "shellinaboxd.service" "emby.service" "transmission.service" )

for var in "${services[@]}"
do
        if systemctl -q is-active ${var}
        then
                printf "%-40s [\e[32mOK\e[39m]\n" $var
        else
                printf "%-40s [\e[31mFAIL\e[39m]\n" $var
        fi
done

echo "
===========================================================================
"
