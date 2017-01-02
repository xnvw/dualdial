#!/bin/sh
#重新载入主脚本
reload_dualdial(){
	if [ "$wan_down" = "0" ] ; then
		killall pppd >/dev/null 2>&1 &
		check_pppd && \
		/usr/sbin/pppd file /tmp/ppp/options.wan0 >/dev/null 2>&1 &
		sleep 3
		/usr/sbin/pppd file /tmp/ppp/options.wan1 >/dev/null 2>&1 &
	else
		if [ "$wan_down" = "1" ]; then
			kill $(ps |grep pppd 2>/dev/null|grep wan0|awk '{print $1}') && sleep 6 && \
			/usr/sbin/pppd file /tmp/ppp/options.wan0 >/dev/null 2>&1 &
		elif [ "$wan_down" = "2" ]; then
			kill $(ps |grep pppd 2>/dev/null|grep wan1|awk '{print $1}') && sleep 6 && \
			/usr/sbin/pppd file /tmp/ppp/options.wan1 >/dev/null 2>&1 &
		fi
	fi
	sleep 3 && \
	/tmp/dualdial_tmp.sh &
	exit
}