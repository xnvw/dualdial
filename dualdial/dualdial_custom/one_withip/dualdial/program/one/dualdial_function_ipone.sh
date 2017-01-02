#!/bin/sh
log_more_reload(){
	echo $(date +%b\ %d\ %X): `echo -e "\033[36;49;5m"reload dualdial---------ip_custum_mode=$iphead_mode!" \033[0m"` >> "${LOG_FILE}"
}
ip_custom_check_one(){
		ippA=$(ifconfig |grep -A1 "ppp"|grep 'P-t-P'|awk '{print $2}'|awk -F \: '{print $2}'|sed -n '1p') #ip地址
		gateway0=$(ifconfig |grep -A1 ppp 2>/dev/null|grep "P-t-P" |awk '{print $3}'|awk -F \: '{print $2}'|sed -n '1p') #网关地址
		#根据预设的ip地址组数确定IP头
		if [ "$ip_custom_enable" = "1" ]; then
			ref_head0=$ippA
		elif [ "$ip_custom_enable" = "2" ]; then
			ref_head0=$gateway0
		fi
		#wan0 IP地址或者gateway的第一组
		wan0_1=$(echo "$ref_head0"|cut -f1 -d .)
		
		#wan0 IP地址或者gateway的前两组
		wan0_2=$(echo "$ref_head0"|cut -f1-2 -d .)
		
		#wan0 IP地址或者gateway的前三组
		wan0_3=$(echo "$ref_head0"|cut -f1-3 -d .)

		if [ "$(basename "$0")" = "dualdial_tmp.sh" ]; then
			[ "$ip_custom_enable" = "1" ] && echo $(date +%b\ %d\ %X): '                'ip wan0:`echo -e "\033[47;30;1;5m"$ippA" \033[0m"` >> "${LOG_FILE}"
			[ "$ip_custom_enable" = "2" ] && echo $(date +%b\ %d\ %X): gateway wan0:`echo -e "\033[44;37;5m "$gateway0" \033[0m"` >> "${LOG_FILE}"
			[ "$iphead_mode" != "4" ] && echo $(date +%b\ %d\ %X): '         'custom_ip_list:$ip_list >> "${LOG_FILE}"
		fi

		if [ "$iphead_mode" = "1" ];then #排除模式
			for ip in $ip_list
			do
				num=`echo $ip|awk -F \. '{print$1,$2,$3,$4}'|wc -w`
				wan_0=wan0_$num
				wan0=$(eval echo \$$wan_0)
				if [ "$wan0" = "$ip" ];then
					log_more_reload
					reload_dualdial #自定义函数
				fi
			done
		elif [ "$iphead_mode" = "2" ]; then #包含模式二
			while :
			do
				for ip in $ip_list
				do
					num=`echo $ip|awk -F \. '{print$1,$2,$3,$4}'|wc -w`
					wan_0=wan0_$num
					wan0=$(eval echo \$$wan_0)
					if [ "$wan0" = "$ip" ];then
						break 2
					fi
				done
				log_more_reload
				reload_dualdial #自定义函数
			done
		fi
}
#内网IP地址排除
pubip_check(){
	ippA=$(ifconfig |grep -A1 ppp0 2>/dev/null|grep "P-t-P" |awk '{print $2}'|awk -F \: '{print $2}') #ip地址
	pubweblist=`cat /jffs/dualdial/pubweb/pubweblist.txt`
	if [ "$pubweblist" != "" ]; then
		for pubweb in $pubweblist
		do
			[ "$logdata" = "2" ] && echo $(date +%b\ %d\ %X): 'pubweb='$pubweb >> "${LOG_FILE}"
			pubippA=$(wget -t 2 -T 5 -q -O - $pubweb)
			[ "$logdata" = "2" ] && echo $(date +%b\ %d\ %X): 'pub_wan0='$pubippA >> "${LOG_FILE}"
			if [ "$pubippA" != "" ]; then
				break
			fi
			[ "$logdata" = "2" ] && echo $(date +%b\ %d\ %X): pubweb check done >> "${LOG_FILE}"
		done
		if [ "$ippA" != "$pubippA" ]; then
			echo $(date +%b\ %d\ %X): 公网IP甄别异常，将重新拨号! >> "${LOG_FILE}"
			reload_dualdial
		else
			[ "$(basename "$0")" = "dualdial_tmp.sh" -a "$logdata" != "0" ] && echo $(date +%b\ %d\ %X): 公网IP甄别通过! >> "${LOG_FILE}"
		fi
	else
		[ "$logdata" != "0" ] && echo $(date +%b\ %d\ %X): 外网验证网址列表为空，无法判断是否为内网IP! >> "${LOG_FILE}"
	fi
}