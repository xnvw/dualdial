#!/bin/sh
autoredial_enable=1
autoredial_time=60
logcheck=2
LOG_FILE=/tmp/dualdial.log

#上面4行参数由主脚本自动传送过来，跟主脚本临时文件/tmp/dualdial_tmp.sh内个人所设置的参数同步一致，这里不需手动改动。
#++++++++++++++++++++++++++++++++++++++
. /jffs/dualdial/program/dualdial_function_ip.sh
#+++++++++++++++++++++++++++++++++++++
#防止重复运行
[ "$(ps |grep "dualdial.sh"|grep -v grep|awk '{print $4}'|grep "S"|wc -l)" -gt 0 ] && exit &
[ "$(ps |grep "dualdial_tmp.sh"|grep -v grep|awk '{print $4}'|grep "S"|wc -l)" -gt 0 ] && exit &
[ "$(ps |grep dualdial_check.sh|grep -v grep|wc -l)" -gt 2 ] && {
	echo $(date +%b\ %d\ %X): another check process running already,exit! >> /tmp/dualdial.log
	exit
}

#检查是否开启负载均衡
[ "$(nvram get wans_dualwan)" != "wan none" ] && {
s=6
until [ "$(nvram get wans_mode)" = "lb" ] ; do
s=$(($s-1))
if [ "$s" = "0" ] ; then
	echo $(date +%b\ %d\ %X): -----------------dualwan not initial,exit!---------------- >> "${LOG_FILE}"
	#清理定时断线重拨监控设置
	dbus remove `dbus list __delay 2>/dev/null|grep dualdial_check|awk -F \= '{print $1}'` >/dev/null 2>&1 &
	cru d dualdial_check >/dev/null 2>&1 &
	exit 0
fi
sleep 1
done
}
reload_dualdial(){
	[ "$(ps |grep "dualdial.sh"|grep -v grep|awk '{print $4}'|grep "S"|wc -l)" = "0" ] && \
	sh /jffs/scripts/dualdial.sh start &
	exit
}
#掉线检测

if [ "$(nvram get wans_dualwan)" != "wan none" ] && [ "$(nvram get wan0_enable)" != "0" -a  "$(nvram get wan1_enable)" != "0" ] ; then
	if [ "$(ip route|grep nexthop|wc -l)" -lt 2 ];then
		echo $(date +%b\ %d\ %X): Dualdial notice: connect abnomal,redial!!! >> "${LOG_FILE}"
		reload_dualdial
	fi
else
	if [ "$(ifconfig|grep -A1  ppp|grep P-t-P|wc -l)" = "0" ];then
		echo $(date +%b\ %d\ %X): Dualdial notice: connect abnomal,redial! >> "${LOG_FILE}"
		reload_dualdial
	fi	
fi

[ "$logcheck" != "0" ] && echo $(date +%b\ %d\ %X): Dualdial notice: check only! >> "${LOG_FILE}"

if [ "$autoredial_enable" = "3" ];then
	sleep $autoredial_time && \
	/jffs/dualdial/program/dualdial_check.sh &	
fi
exit
