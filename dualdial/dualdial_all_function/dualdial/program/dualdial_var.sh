#!/bin/sh

#输出特定参数到主脚本临时文件dualdial_tmp.sh

var_transfer_main_one(){
	sed -i '1a autoredial_enable='$autoredial_enable'' /tmp/dualdial_tmp.sh && \
	sed -i '2a autoredial_time='$autoredial_time'' /tmp/dualdial_tmp.sh && \
	sed -i '3a logdata='$logdata'' /tmp/dualdial_tmp.sh && \
	sed -i '4a reconnect_enable='$reconnect_enable'' /tmp/dualdial_tmp.sh && \
	sed -i '5a ip_custom_enable='$ip_custom_enable'' /tmp/dualdial_tmp.sh && \
	sed -i '6a iphead_mode='$iphead_mode'' /tmp/dualdial_tmp.sh && \
	sed -i '7a myshell='$myshell'' /tmp/dualdial_tmp.sh && \
	sed -i '8a pubip_check='$pubip_check'' /tmp/dualdial_tmp.sh
}
var_transfer_main_nosync(){
	sed -i '1a wan_down='$wan_down'' /tmp/dualdial_tmp.sh && \
	sed -i '2a vlan3_fail='$vlan3_fail'' /tmp/dualdial_tmp.sh && \
	sed -i '3a fix_lanwan='$fix_lanwan'' /tmp/dualdial_tmp.sh && \
	sed -i '4a autoredial_enable='$autoredial_enable'' /tmp/dualdial_tmp.sh && \
	sed -i '5a autoredial_time='$autoredial_time'' /tmp/dualdial_tmp.sh && \
	sed -i '6a automac_each_enable='$automac_each_enable'' /tmp/dualdial_tmp.sh && \
	sed -i '7a automac_cycle_enable='$automac_cycle_enable'' /tmp/dualdial_tmp.sh && \
	sed -i '8a loadbalance_check='$loadbalance_check'' /tmp/dualdial_tmp.sh && \
	sed -i '9a webcheck_enable='$webcheck_enable'' /tmp/dualdial_tmp.sh && \
	sed -i '10a webaddr1='$webaddr1'' /tmp/dualdial_tmp.sh && \
	sed -i '11a webaddr2='$webaddr2'' /tmp/dualdial_tmp.sh && \
	sed -i '12a ping_time='$ping_time'' /tmp/dualdial_tmp.sh && \
	sed -i '13a logdata='$logdata'' /tmp/dualdial_tmp.sh && \
	sed -i '14a reconnect_enable='$reconnect_enable'' /tmp/dualdial_tmp.sh && \
	sed -i '15a ip_custom_enable='$ip_custom_enable'' /tmp/dualdial_tmp.sh && \
	sed -i '16a iphead_mode='$iphead_mode'' /tmp/dualdial_tmp.sh && \
	sed -i '17a iphead_group_wan='$iphead_group_wan'' /tmp/dualdial_tmp.sh && \
	sed -i '18a myshell='$myshell'' /tmp/dualdial_tmp.sh && \
	sed -i '19a pubip_check=0' /tmp/dualdial_tmp.sh
}
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
	sed -i '17a myshell='$myshell'' /tmp/dualdial_tmp.sh && \
	sed -i '18a pubip_check='$pubip_check'' /tmp/dualdial_tmp.sh
}
var_transfer_main_sync_ip(){
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
	sed -i '16a webcheck_enable='$webcheck_enable'' /tmp/dualdial_tmp.sh && \
	sed -i '17a webaddr1='$webaddr1'' /tmp/dualdial_tmp.sh && \
	sed -i '18a webaddr2='$webaddr2'' /tmp/dualdial_tmp.sh && \
	sed -i '19a ping_time='$ping_time'' /tmp/dualdial_tmp.sh && \
	sed -i '20a logdata='$logdata'' /tmp/dualdial_tmp.sh && \
	sed -i '21a data_out='$data_out'' /tmp/dualdial_tmp.sh && \
	sed -i '22a reconnect_enable='$reconnect_enable'' /tmp/dualdial_tmp.sh && \
	sed -i '23a ip_custom_enable='$ip_custom_enable'' /tmp/dualdial_tmp.sh && \
	sed -i '24a iphead_mode='$iphead_mode'' /tmp/dualdial_tmp.sh && \
	sed -i '25a iphead_group_wan='$iphead_group_wan'' /tmp/dualdial_tmp.sh && \
	sed -i '26a myshell='$myshell'' /tmp/dualdial_tmp.sh && \
	sed -i '27a pubip_check='$pubip_check'' /tmp/dualdial_tmp.sh
}
#+++++++++++++++++++++++++++++++++++++++++++++++
#输出IP定制列表到临时文件/tmp/dualdial_custom_ip.out
#开了IP定制时执行
var_transfer_iplist(){
if [ "$ip_custom_enable" != "0" ]; then
	[ ! -f /tmp/dualdial_custom_ip.out ] && touch /tmp/dualdial_custom_ip.out &
	echo -n "$custom_ip_list" > /tmp/dualdial_custom_ip.out
	chmod 777 "/tmp/dualdial_custom_ip.out"
fi
}
#++++++++++++++++++++++++++++++++++++++++++++++++
#输出部分参数到后台定时监控脚本dualdial_check.sh或者dualdial_check_ip.sh
var_transfer_monitor(){
	if [ "$dial_mode" != "2" ] ; then
		if [ -f /jffs/dualdial/program/dualdial_check.sh ] ; then
			sed -i '2c autoredial_enable='$autoredial_enable'' /jffs/dualdial/program/dualdial_check.sh
			sed -i '3c autoredial_time='$autoredial_time'' /jffs/dualdial/program/dualdial_check.sh
			sed -i '4c logcheck='$logcheck'' /jffs/dualdial/program/dualdial_check.sh
			sed -i '5c LOG_FILE='$LOG_FILE'' /jffs/dualdial/program/dualdial_check.sh
			sed -i '6c pubip_check='$pubip_check'' /jffs/dualdial/program/dualdial_check.sh
		else
			echo $(date +%b\ %d\ %X): monitor file missing! >> "${LOG_FILE}"
		fi
		if [ "$ip_custom_enable" != "0" ] ; then
			if [ -f /jffs/dualdial/program/dualdial_check_ip.sh ] ; then
				sed -i '2c autoredial_enable='$autoredial_enable'' /jffs/dualdial/program/dualdial_check_ip.sh
				sed -i '3c autoredial_time='$autoredial_time'' /jffs/dualdial/program/dualdial_check_ip.sh
				sed -i '4c logcheck='$logcheck'' /jffs/dualdial/program/dualdial_check_ip.sh
				sed -i '5c LOG_FILE='$LOG_FILE'' /jffs/dualdial/program/dualdial_check_ip.sh
				sed -i '6c ip_custom_enable='$ip_custom_enable'' /jffs/dualdial/program/dualdial_check_ip.sh
				sed -i '7c iphead_mode='$iphead_mode'' /jffs/dualdial/program/dualdial_check_ip.sh
				sed -i '8c iphead_group_wan='$iphead_group_wan'' /jffs/dualdial/program/dualdial_check_ip.sh
				sed -i '9c pubip_check='$pubip_check'' /jffs/dualdial/program/dualdial_check_ip.sh
			else
				echo $(date +%b\ %d\ %X): monitor file missing! >> "${LOG_FILE}"
			fi
		fi
	elif [ "$dial_mode" = "2" ] ; then
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
	fi
}
