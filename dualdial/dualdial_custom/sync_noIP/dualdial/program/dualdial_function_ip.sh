#!/bin/sh

#内网IP地址排除
pubip_check(){
	ippA=$(ifconfig |grep -A1 "ppp"|grep 'P-t-P'|awk '{print $2}'|awk -F \: '{print $2}'|sed '$!{h;d}x')
	ippB=$(ifconfig |grep -A1 "ppp"|grep 'P-t-P'|awk '{print $2}'|awk -F \: '{print $2}'|sed '$!d')
	pubweblist=`cat /jffs/dualdial/pubweb/pubweblist.txt`
	if [ "$pubweblist" != "" ]; then
		for pubweb in $pubweblist
		do
			[ "$(basename "$0")" = "dualdial_tmp.sh" -a "$logdata" = "2" ] && echo $(date +%b\ %d\ %X): 'pubweb='$pubweb >> "${LOG_FILE}"
			pubippA=$(wget -t 2 -T 10 -q -O - $pubweb --bind-address=$ippA)
			pubippB=$(wget -t 2 -T 10 -q -O - $pubweb --bind-address=$ippB)
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