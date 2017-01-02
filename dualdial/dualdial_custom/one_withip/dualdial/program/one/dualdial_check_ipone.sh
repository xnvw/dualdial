#!/bin/sh
autoredial_enable=1
autoredial_time=60
logcheck=2
LOG_FILE=/tmp/dualdial.log
ip_custom_enable=1
iphead_mode=2

#上面7行参数由主脚本自动传送过来，跟主脚本临时文件/tmp/dualdial.sh内个人所设置的参数同步一致，这里不需手动改动。
#++++++++++++++++++++++++++++++++++++++
. /jffs/dualdial/program/one/dualdial_function_ipone.sh
#+++++++++++++++++++++++++++++++++++++
#防止重复运行
[ "$(ps |grep "dualdial_tmp.sh" 2>/dev/null|grep -v grep|awk '{print $4}'|grep "S"|wc -l)" -gt 0 ] && exit &
[ "$(ps |grep dualdial_check_ip.sh 2>/dev/null|grep -v grep|wc -l)" -gt 2 ] && {
	echo $(date +%b\ %d\ %X): another check process running already,exit! >> /tmp/dualdial.log
	exit
}

reload_dualdial(){
	[ "$(ps |grep "dualdial.sh"|grep -v grep|awk '{print $4}'|grep "S"|wc -l)" = "0" ] && \
	sh /jffs/scripts/dualdial.sh start &
	exit
}
#掉线检测
if [ "$(ifconfig|grep -A1  ppp|grep P-t-P|wc -l)" = "0" ];then
	(echo) >> "${LOG_FILE}"
	echo $(date +%b\ %d\ %X): Dualdial notice: connect abnomal,redial! >> "${LOG_FILE}"
	reload_dualdial
fi

#内网IP地址检测
if [ "$pubip_check" = 1 ]; then
	pubip_check
fi

#IP定制检测
[ ! -f /tmp/dualdial_custom_ip.out ] && {
		echo $(date +%b\ %d\ %X): cannt find "dualdial_custom_ip.out",reload dualdial,exit! >> "${LOG_FILE}"
		reload_dualdial
}
ip_list=`cat /tmp/dualdial_custom_ip.out`
if [ "$ip_list"  != "" ]; then
	ip_custom_check_one #ip检测
else
	#虽然开启了IP定制，列表却为空
	echo $(date +%b\ %d\ %X): dualdial_custum_ip_list empty,do nothing ! >> "${LOG_FILE}"
fi

[ "$logcheck" != "0" ] && echo $(date +%b\ %d\ %X): Dualdial notice: custum_ip_mode=$iphead_mode,check only! >> "${LOG_FILE}"

if [ "$autoredial_enable" = "3" ];then
	sleep $autoredial_time && \
	/jffs/dualdial/program/one/dualdial_check_ipone.sh &
fi
exit
