#!/bin/sh
#重新载入主脚本
reload_dualdial(){
	killall pppd >/dev/null 2>&1 &
	check_pppd && \
	sleep 3
	/usr/sbin/pppd file /tmp/ppp/options.wan0 >/dev/null 2>&1 &
	sleep 6 && \
	/tmp/dualdial_tmp.sh &
	exit
}