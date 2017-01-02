#!/bin/sh
log_more_reload(){
	echo $(date +%b\ %d\ %X): `echo -e "\033[36;49;1;5m"reload dualdial--------ip_custum_mode=$iphead_mode!" \033[0m"` >> "${LOG_FILE}"
}
ip_custom_check(){
		#ip地址
		ippA=$(ifconfig |grep -A1 "ppp"|grep 'P-t-P'|awk '{print $2}'|awk -F \: '{print $2}'|sed '$!{h;d}x')
		ippB=$(ifconfig |grep -A1 "ppp"|grep 'P-t-P'|awk '{print $2}'|awk -F \: '{print $2}'|sed '$!d')
		#网关地址
		gateway0=$(ifconfig |grep -A1 "ppp"|grep "P-t-P" |awk '{print $3}'|awk -F \: '{print $2}'|sed '$!{h;d}x')
		gateway1=$(ifconfig |grep -A1 "ppp"|grep "P-t-P" |awk '{print $3}'|awk -F \: '{print $2}'|sed '$!d')
		#根据预设的ip地址组数确定IP头
		if [ "$ip_custom_enable" = "1" ]; then
			ref_head0=$ippA
			ref_head1=$ippB
		elif [ "$ip_custom_enable" = "2" ]; then
			ref_head0=$gateway0
			ref_head1=$gateway1
		fi
		#wan0/wan1 IP地址或者gateway的第一组
		wan0_1=$(echo "$ref_head0"|cut -f1 -d .)
		wan1_1=$(echo "$ref_head1"|cut -f1 -d .)
		#wan0/wan1 IP地址或者gateway的前两组
		wan0_2=$(echo "$ref_head0"|cut -f1-2 -d .)
		wan1_2=$(echo "$ref_head1"|cut -f1-2 -d .)
		#wan0/wan1 IP地址或者gateway的前三组
		wan0_3=$(echo "$ref_head0"|cut -f1-3 -d .)
		wan1_3=$(echo "$ref_head1"|cut -f1-3 -d .)

		if [ "$iphead_group_wan" = "1" ]; then
			wan0_a=$(echo "$ref_head0"|cut -f1 -d .)
			wan1_b=$(echo "$ref_head1"|cut -f1 -d .)
		elif [ "$iphead_group_wan" = "2" ]; then
			wan0_a=$(echo "$ref_head0"|cut -f1-2 -d .)
			wan1_b=$(echo "$ref_head1"|cut -f1-2 -d .)
		elif [ "$iphead_group_wan" = "3" ]; then
			wan0_a=$(echo "$ref_head0"|cut -f1-3 -d .)
			wan1_b=$(echo "$ref_head1"|cut -f1-3 -d .)
		fi
		if [ "$(basename "$0")" = "dualdial_tmp.sh" ]; then
			# [ "$ip_custom_enable" = "1" -a "$logdata" = "2" ] && echo $(date +%b\ %d\ %X): '          'ip wan0/wan1: `echo -e "\033[47;30;1;5m"$ippA" / "$ippB" \033[0m"` >> "${LOG_FILE}"
			[ "$ip_custom_enable" = "2" -a "$logdata" = "2" ] && echo $(date +%b\ %d\ %X): gateway wan0/wan1:`echo -e "\033[44;37;5m "$gateway0" / "$gateway1" \033[0m"` >> "${LOG_FILE}"
			[ "$iphead_mode" != "4" ] && echo $(date +%b\ %d\ %X): '        'custom_ip_list:$ip_list >> "${LOG_FILE}"
		fi
		if [ "$iphead_mode" = "1" ];then #排除模式1
			for ip in $ip_list
			do
				num=`echo $ip|awk -F \. '{print$1,$2,$3,$4}'|wc -w`
				wan_0=wan0_$num
				wan_1=wan1_$num
				wan0=$(eval echo \$$wan_0)
				wan1=$(eval echo \$$wan_1)
				if [ "$wan0" = "$ip" -o "$wan1" = "$ip" ];then
					log_more_reload
					reload_dualdial #自定义函数
				fi
			done
		elif [ "$iphead_mode" = "2" ]; then #排除模式2
			if [ "$wan0_a" = "$wan1_b" ];then
				for ip in $ip_list
				do
					num=`echo $ip|awk -F \. '{print$1,$2,$3,$4}'|wc -w`
					wan_0=wan0_$num
					wan_1=wan1_$num
					wan0=$(eval echo \$$wan_0)
					wan1=$(eval echo \$$wan_1)
					if [ "$wan0" = "$ip" -a "$wan1" = "$ip" ];then
						log_more_reload
						reload_dualdial #自定义函数
					fi
				done
			else
				log_more_reload
				reload_dualdial #自定义函数
			fi
		elif [ "$iphead_mode" = "3" ]; then #相同模式1
			if [ "$wan0_a" = "$wan1_b" ];then
				while :
				do
					for ip in $ip_list
					do
						num=`echo $ip|awk -F \. '{print$1,$2,$3,$4}'|wc -w`
						wan_0=wan0_$num
						wan_1=wan1_$num
						wan0=$(eval echo \$$wan_0)
						wan1=$(eval echo \$$wan_1)
						if [ "$wan0" = "$ip" -a "$wan1" = "$ip" ];then
							break 2
						fi
					done
					log_more_reload
					reload_dualdial #自定义函数
				done
			else
				log_more_reload
				reload_dualdial #自定义函数
			fi
		elif [ "$iphead_mode" = "4" ]; then #相同模式二
			if [ "$wan0_a" != "$wan1_b" ];then
				log_more_reload
				reload_dualdial #自定义函数
			fi
		elif [ "$iphead_mode" = "5" ]; then #包含模式一
			while :
			do
				for ip in $ip_list
				do
					num=`echo $ip|awk -F \. '{print$1,$2,$3,$4}'|wc -w`
					wan_0=wan0_$num
					wan0=$(eval echo \$$wan_0)
					if [ "$wan0" = "$ip" ];then
						break 2
					else
						echo
					fi
				done
				log_more_reload
				reload_dualdial #自定义函数
			done
			while :
			do
				for ip in $ip_list
				do
					num=`echo $ip|awk -F \. '{print$1,$2,$3,$4}'|wc -w`
					wan_1=wan1_$num
					wan1=$(eval echo \$$wan_1)
					if [ "$wan1" = "$ip" ];then
						break 2
					else
						echo
					fi
				done
				log_more_reload
				reload_dualdial #自定义函数
			done
		elif [ "$iphead_mode" = "6" ]; then #包含模式二
			while :
			do
				for ip in $ip_list
				do
					num=`echo $ip|awk -F \. '{print$1,$2,$3,$4}'|wc -w`
					wan_0=wan0_$num
					wan_1=wan1_$num
					wan0=$(eval echo \$$wan_0)
					wan1=$(eval echo \$$wan_1)
					if [ "$wan0" = "$ip" -o "$wan1" = "$ip" ];then
						break 2
					fi
				done
				log_more_reload
				reload_dualdial #自定义函数
			done
		elif [ "$iphead_mode" = "7" ]; then #两者不同
			if [ "$wan0_a" = "$wan1_b" ];then
				log_more_reload
				reload_dualdial #自定义函数
			fi
		fi
}

#内网IP地址排除
pubip_check(){
	ippA=$(ifconfig |grep -A1 "ppp"|grep 'P-t-P'|awk '{print $2}'|awk -F \: '{print $2}'|sed '$!{h;d}x')
	ippB=$(ifconfig |grep -A1 "ppp"|grep 'P-t-P'|awk '{print $2}'|awk -F \: '{print $2}'|sed '$!d')
	pubweblist=`cat /jffs/dualdial/pubweb/pubweblist.txt`
	if [ "$pubweblist" != "" ]; then
		for pubweb in $pubweblist
		do
			[ "$(basename "$0")" = "dualdial_tmp.sh" -a "$logdata" = "2" ] && echo $(date +%b\ %d\ %X): 'pubweb='$pubweb >> "${LOG_FILE}"
			pubippA=$(wget -t 2 -T 5 -q -O - $pubweb --bind-address=$ippA)
			pubippB=$(wget -t 2 -T 5 -q -O - $pubweb --bind-address=$ippB)
			[ "$(basename "$0")" = "dualdial_tmp.sh" -a "$logdata" = "2" ] && echo $(date +%b\ %d\ %X): 'pub_wan0='$pubippA//'pub_wan1='$pubippB >> "${LOG_FILE}"
			if [ "$pubippA" != "" -a "$pubippB" != "" ]; then
				break
			fi
			[ "$(basename "$0")" = "dualdial_tmp.sh" -a "$logdata" = "2" ] && echo $(date +%b\ %d\ %X): pubweb check done >> "${LOG_FILE}"
		done
		if [ "$ippA" != "$pubippA" -o "$ippB" != "$pubippB" ]; then
			echo $(date +%b\ %d\ %X): 公网IP甄别异常，将重新拨号! >> "${LOG_FILE}"
			reload_dualdial
		else
			[ "$(basename "$0")" = "dualdial_tmp.sh" -a "$logdata" != "0" ] && echo $(date +%b\ %d\ %X): 公网IP甄别通过! >> "${LOG_FILE}"
		fi
	else
		echo $(date +%b\ %d\ %X): 外网验证网址列表为空，无法判断是否为内网IP! >> "${LOG_FILE}"
	fi
}