#!/bin/sh

#输出特定参数到主脚本临时文件dualdial_tmp.sh
var_transfer_main_sync_noip(){
	sed -i '1a w=0' /tmp/dualdial_tmp.sh && \
	sed -i '2a i=0' /tmp/dualdial_tmp.sh && \
	sed -i '5a cycle_num_base='$cycle_num_base'' /tmp/dualdial_tmp.sh && \
	sed -i '6a cycle_time_base='$cycle_time_base'' /tmp/dualdial_tmp.sh && \
	sed -i '7a cycle_num_max='$cycle_num_max'' /tmp/dualdial_tmp.sh && \
	sed -i '8a dialtime='$dialtime'' /tmp/dualdial_tmp.sh && \
	sed -i '9a vlan3_fail='$vlan3_fail'' /tmp/dualdial_tmp.sh && \
	sed -i '10a fix_lanwan='$fix_lanwan'' /tmp/dualdial_tmp.sh && \
	sed -i '11a autoredial_enable='$autoredial_enable'' /tmp/dualdial_tmp.sh && \
	sed -i '12a autoredial_time='$autoredial_time'' /tmp/dualdial_tmp.sh && \
	sed -i '13a automac_each_enable='$automac_each_enable'' /tmp/dualdial_tmp.sh && \
	sed -i '14a automac_cycle_enable='$automac_cycle_enable'' /tmp/dualdial_tmp.sh && \
	sed -i '15a loadbalance_check='$loadbalance_check'' /tmp/dualdial_tmp.sh && \
	sed -i '16a reconnect_enable='$reconnect_enable'' /tmp/dualdial_tmp.sh && \
	sed -i '17a myshell='$myshell'' /tmp/dualdial_tmp.sh
	sed -i '18a pubip_check='$pubip_check'' /tmp/dualdial_tmp.sh
}
#++++++++++++++++++++++++++++++++++++++++++++++++
#输出部分参数到后台定时监控脚本dualdial_check.sh或者dualdial_check_ip.sh
var_transfer_monitor(){
	if [ -f /jffs/dualdial/program/dualdial_check.sh ] ; then
		sed -i '2c autoredial_enable='$autoredial_enable'' /jffs/dualdial/program/dualdial_check.sh
		sed -i '3c autoredial_time='$autoredial_time'' /jffs/dualdial/program/dualdial_check.sh
		sed -i '4c logcheck='$logcheck'' /jffs/dualdial/program/dualdial_check.sh
		sed -i '5c LOG_FILE='$LOG_FILE'' /jffs/dualdial/program/dualdial_check.sh
		sed -i '6c pubip_check='$pubip_check'' /jffs/dualdial/program/dualdial_check.sh
	else
		echo $(date +%b\ %d\ %X): monitor file missing! >> "${LOG_FILE}"
	fi
}
