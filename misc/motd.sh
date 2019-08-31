#!/run/current-system/sw/bin/bash

USER=`whoami`
HOSTNAME=`uname -n`

LINUX=`uname -rs`

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

IPV4=`dig +short sene.ovh @resolver1.opendns.com`
IPV6=`ip -6 addr show enp2s0 | awk '/inet6/{print $2}' | cut -d/ -f1 | head -1`

echo "============================================================"
echo "Good $TIME $USER"
echo `curl -s wttr.in/Haguenau\?format=3`
echo "============================================================
 - Hostname............: $HOSTNAME
 - IPv4................: $IPV4
 - IPv6................: $IPV6
 - Release.............: `nixos-version`
 - Kernel..............: $LINUX
============================================================
 - Users...............: Currently `users | wc -w` user(s) logged on
 - Current user........: $USER
 - CPU usage...........: $LOAD1, $LOAD5, $LOAD15 (1, 5, 15 min)
 - Memory used.........: $MEMORY
 - Swap in use.........: `free -m | tail -n 1 | awk '{print $3}'` MB
 - System uptime.......: $upDays days $upHours hours $upMins minutes $upSecs seconds
============================================================"
services=( "grafana.service" "searx.service" "gitea.service" "matrix-synapse.service" "docker.service" "" "dovecot2.service" "postfix.service" "rspamd.service" "" "haproxy.service" "nginx.service" "phpfpm-web.service" "phpfpm-roundcube.service" "phpfpm-nextcloud.service" "" "influxdb.service" "pgmanage.service" "postgresql.service" "mysql.service" "" "jellyfin.service" "transmission.service" "jackett.service" "radarr.service" "sonarr.service" )

for var in "${services[@]}"
do
    if [[ -z $var ]]; then
      printf "\n"
    else
      if systemctl -q is-active ${var}; then
        printf "%-40s [\e[32mOK\e[39m]\n" $var
      else
        printf "%-40s [\e[31mFAIL\e[39m]\n" $var
      fi
    fi
done

echo "============================================================"
