#!/bin/sh
autoredial_enable=1
autoredial_time=60
logcheck=2
LOG_FILE=/tmp/dualdial.log
ip_custom_enable=1
iphead_mode=9
iphead_group_wan=2

#上面7行参数由主脚本自动传送过来，跟主脚本临时文件/tmp/dualdial.sh内个人所设置的参数同步一致，这里不需手动改动。
#++++++++++++++++++++++++++++++++++++++
. /jffs/dualdial/program/dualdial_function_ip.sh
#+++++++++++++++++++++++++++++++++++++
#防止重复运行
[ "$(ps |grep "dualdial_tmp.sh" 2>/dev/null|grep -v grep|awk '{print $4}'|grep "S"|wc -l)" -gt 0 ] && exit &
[ "$(ps |grep "dualdial_check.sh" 2>/dev/null|grep -v grep|awk '{print $4}'|grep "S"|wc -l)" -gt 0 ] && exit &
[ "$(ps |grep dualdial_check_ip.sh 2>/dev/null|grep -v grep|wc -l)" -gt 2 ] && {
	echo $(date +%b\ %d\ %X): another check process running already,exit! >> /tmp/dualdial.log
	exit
}
#检查是否开启负载均衡
[ "$(nvram get wans_dualwan)" != "wan none" ] && {
	s=6
	until [ "$(nvram get wans_mode)" = "lb" ] ; do
	s=$(($s-1))
	if [ "$s" = "0" ] ; then
		echo $(date +%b\ %d\ %X): ---------------dualwan not initial,exit!---------------- >> "${LOG_FILE}"
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
		(echo) >> "${LOG_FILE}"
		echo $(date +%b\ %d\ %X): Dualdial notice: connect abnomal,redial! >> "${LOG_FILE}"
		reload_dualdial
	fi
	#内网IP地址检测
	if [ "$pubip_check" = 1 ]; then
		pubip_check
	fi
else
	if [ "$(ifconfig|grep -A1  ppp|grep P-t-P|wc -l)" = "0" ];then
		(echo) >> "${LOG_FILE}"
		echo $(date +%b\ %d\ %X): Dualdial notice: connect abnomal,redial! >> "${LOG_FILE}"
		reload_dualdial
	fi
fi

#IP定制检测
[ "$ip_custom_enable" != "0" ] && {
	[ ! -f /tmp/dualdial_custom_ip.out ] && {
		echo $(date +%b\ %d\ %X): cannt find "dualdial_custom_ip.out",reload dualdial,exit! >> "${LOG_FILE}"
		reload_dualdial
	}
	ip_list=`cat /tmp/dualdial_custom_ip.out`
	if [ "$ip_list"  != "" ]; then
		ip_custom_check #ip检测
	else
		#虽然开启了IP定制，列表却为空
		echo $(date +%b\ %d\ %X): dualdial_custum_ip_list empty,do nothing ! >> "${LOG_FILE}"
	fi
}

[ "$logcheck" != "0" ] && echo $(date +%b\ %d\ %X): Dualdial notice: custum_ip_mode=$iphead_mode,check only! >> "${LOG_FILE}"

if [ "$autoredial_enable" = "3" ];then
	sleep $autoredial_time && \
	/jffs/dualdial/program/dualdial_check_ip.sh &
fi
exit
