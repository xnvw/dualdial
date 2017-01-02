#!/bin/sh

#输出特定参数到主脚本临时工作文件dualdial_tmp.sh
var_transfer_main_one(){
	sed -i '1a autoredial_enable='$autoredial_enable'' /tmp/dualdial_tmp.sh && \
	sed -i '2a autoredial_time='$autoredial_time'' /tmp/dualdial_tmp.sh && \
	sed -i '3a logdata='$logdata'' /tmp/dualdial_tmp.sh && \
	sed -i '4a reconnect_enable='$reconnect_enable'' /tmp/dualdial_tmp.sh && \
	sed -i '5a ip_custom_enable='$ip_custom_enable'' /tmp/dualdial_tmp.sh && \
	sed -i '6a iphead_mode='$iphead_mode'' /tmp/dualdial_tmp.sh && \
	sed -i '7a myshell='$myshell'' /tmp/dualdial_tmp.sh
	sed -i '8a pubip_check='$pubip_check'' /tmp/dualdial_tmp.sh
}
#+++++++++++++++++++++++++++++++++++++++++++++++
#输出IP定制列表到临时文件/tmp/dualdial_custom_ip.out
var_transfer_iplist(){
	[ ! -f /tmp/dualdial_custom_ip.out ] && touch /tmp/dualdial_custom_ip.out &
	echo -n "$custom_ip_list" > /tmp/dualdial_custom_ip.out
	chmod 777 "/tmp/dualdial_custom_ip.out"
}
#++++++++++++++++++++++++++++++++++++++++++++++++
#输出部分参数到后台定时监控脚本dualdial_check.sh或者dualdial_check_ip.sh
var_transfer_monitor(){
	if [ -f /jffs/dualdial/program/one/dualdial_check_ipone.sh ] ; then
		sed -i '2c autoredial_enable='$autoredial_enable'' /jffs/dualdial/program/one/dualdial_check_ipone.sh
		sed -i '3c autoredial_time='$autoredial_time'' /jffs/dualdial/program/one/dualdial_check_ipone.sh
		sed -i '4c logcheck='$logcheck'' /jffs/dualdial/program/one/dualdial_check_ipone.sh
		sed -i '5c LOG_FILE='$LOG_FILE'' /jffs/dualdial/program/one/dualdial_check_ipone.sh
		sed -i '6c ip_custom_enable='$ip_custom_enable'' /jffs/dualdial/program/one/dualdial_check_ipone.sh
		sed -i '7c iphead_mode='$iphead_mode'' /jffs/dualdial/program/one/dualdial_check_ipone.sh
		sed -i '8c pubip_check='$pubip_check'' /jffs/dualdial/program/one/dualdial_check_ipone.sh
	else
		echo $(date +%b\ %d\ %X): monitor file missing! >> "${LOG_FILE}"
	fi
}
