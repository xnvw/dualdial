#!/bin/sh
#++++++++++++++++++++++++++++++++++++++++++
#上面参数禁止移动位置
#++++++++++++++++++++++++++++++++++++++++++
LOG_FILE="/tmp/dualdial.log"
source /jffs/dualdial/program/dualdial_function_ip.sh
source /jffs/dualdial/program/sync_ip/dualdial_function.sh
alias echo_date:='echo $(date +%b\ %d\ %X):'
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#临时关闭后台断线重拨监控
[ "$(nvram get wan0_enable)" = "0" ] && nvram set wan0_enable=1 && nvram commit &
[ "$(nvram get wan1_enable)" = "0" ] && nvram set wan1_enable=1 && nvram commit &

#日志三级显示
logdata_more(){
	aa=$(ip route|grep 'nexthop' 2>/dev/null|wc -l)
	bb=$(route |grep 'default' 2>/dev/null|wc -l)
	cc=$(route|grep 'UH' 2>/dev/null|wc -l)
	c=$(nvram get wan0_pppoe_ifname)
	d=$(nvram get wan1_pppoe_ifname)
	ippA=$(ifconfig |grep -A1 "ppp"|grep 'P-t-P'|awk '{print $2}'|awk -F \: '{print $2}'|sed '$!{h;d}x')
	ippB=$(ifconfig |grep -A1 "ppp"|grep 'P-t-P'|awk '{print $2}'|awk -F \: '{print $2}'|sed '$!d')
	pppd=$(ps |grep pppd|grep -v grep|awk '{print $4}'|grep 'S'|wc -l)
	[ "$c" != "" -a "$d" = "" ] && echo -e lb/default/uh//pppd:`echo -e "\033[36;49;5m "$aa'\t'$bb'\t'$cc//$pppd" \033[0m"`ppoe_ifname:$c/'    '$d'||'ip:$ippB >> "${LOG_FILE}"
	[ "$c" = "" -a "$d" != "" ] && echo -e lb/default/uh//pppd:`echo -e "\033[36;49;5m "$aa'\t'$bb'\t'$cc//$pppd" \033[0m"`ppoe_ifname:$c'    '/$d'||'ip:$ippB >> "${LOG_FILE}"
	[ "$c" = "" -a "$d" = "" ] && echo -e lb/default/uh//pppd:`echo -e "\033[36;49;5m "$aa'\t'$bb'\t'$cc//$pppd" \033[0m"`ppoe_ifname:$c'    '/'    '$d'||'ip:$ippA'\t''\t'/$ippB >> "${LOG_FILE}"
	[ "$c" != "" -a "$d" != "" ] && echo -e lb/default/uh//pppd:`echo -e "\033[36;49;5m "$aa'\t'$bb'\t'$cc//$pppd" \033[0m"`ppoe_ifname:$c/$d'||'ip:`echo -e "\033[33;49m"$ippA/$ippB"\033[0m"` >> "${LOG_FILE}"
}
vlan3_check(){
	s=180
	until [ "$(ip link|grep "vlan3@"|wc -l)" = "1" ] ; do
	s=$(($s-1))
	if [ "$s" -eq 0 ]; then
	    echo_date: dualdial Alarm: Serious error!!! >> "${LOG_FILE}"
		echo_date: vlan3 initial fail,cannot continue! >> "${LOG_FILE}"
		echo_date: caution："AC-66U" not support function "Multiple PPPd support"! >> "${LOG_FILE}"
		[ "$vlan3_fail" = "1" ] && echo_date: '     'vlan3 check fail,exit >> "${LOG_FILE}" && exit
		[ "$vlan3_fail" = "2" ] && echo_date: '     'vlan3 check fail,reboot for vlan recovery >> "${LOG_FILE}" && reboot
		[ "$vlan3_fail" = "3" ] && echo_date: '     'vlan3 check fail,restart wireless for vlan recovery >> "${LOG_FILE}" && restart_wireless >/dev/null 2>&1 && exit
	fi
	sleep 1
	[ "$logdata" = "2" ] && echo_date: '     'vlan3 check! no.:$s >> "${LOG_FILE}"
	done
}

mac_auto(){
nvram set wan0_hwaddr=$(echo "$macfac:"$(md5sum /proc/sys/kernel/random/uuid | sed 's/\(..\)/&:/g' | cut -b 1-8))
nvram set wan1_hwaddr=$(echo "$macfac:"$(md5sum /proc/sys/kernel/random/uuid | sed 's/\(..\)/&:/g' | cut -b 1-8))
nvram set wan0_hwaddr_x=$(nvram get wan0_hwaddr)
nvram set wan1_hwaddr_x=$(nvram get wan1_hwaddr)
nvram commit
}
check_pppd(){
if [ 1 -eq 1 ] ; then
	j=1
	until [ "$(ps |grep pppd|grep -v grep|awk '{print $4}'|grep 'S'|wc -l)" = "0" ]; do
	j=$(($j+1))
		if [ "$j" -eq 36 ]; then
			killall pppd 2>/dev/null &
			break
		fi
		sleep 1
	done
	sleep 3
fi
}
dualdial_cease(){
if [ "$(route|grep "default"|wc -l)" != "0" ];then
	if [ "$(nvram get wan1_pppoe_ifname)" = "" ] ; then
		kill $(ps |grep pppd 2>/dev/null|grep wan1|awk '{print $1}') &
		nvram set wan1_enable=0 && nvram commit &
	elif [ "$(nvram get wan0_pppoe_ifname)" = "" ] ; then
		kill $(ps |grep pppd 2>/dev/null|grep wan0|awk '{print $1}') &
		nvram set wan0_enable=0 && nvram commit &
	fi
else
	killall pppd >/dev/null 2>&1 &
	check_pppd && \
	/usr/sbin/pppd file /tmp/ppp/options.wan0 >/dev/null 2>&1 &
	nvram set wan1_enable=0 &&	nvram commit &
fi
}
# 检测VLAN3加载状态，开了单线双拨才执行这一步
if [ "$(nvram get wans_dualwan)" != "wan none" -a "$(nvram get multiwanbyoneline)" = "1" ]; then
	vlan3_check
fi
#判断双WAN及负载均衡是否启用
s=6
until [ "$(nvram get wans_mode)" = "lb" ] ; do
s=$(($s-1))
if [ "$s" -eq 0 ] ; then
	echo_date: -----双WAN或已开启但未启用负载均衡，脚本不适用，将退出!WANS_MODE:$isdual ---------- >> "${LOG_FILE}"
	exit 1
fi
sleep 1
done
#如果双WAN的MAC皆为空白则强制自动补齐
macfac=$(nvram get et0macaddr | cut -b 1-8)
[ "$(nvram get wan0_hwaddr_x)" = "" -a "$(nvram get wan1_hwaddr_x)" = "" ] && {
	mac_auto
}

[ "$w" = "0" ] && (echo_date: no.0-------Dualdial working!) >> /tmp/syslog.log
[ "$w" = "0" -a "$logdata" != "2" ] && (echo_date: no.0-------------------Dualdial working!) >> "${LOG_FILE}"
[ "$w" = "0" -a "$logdata" = "2" ] && echo -n $(date +%b\ %d\ %X): no.0-------------------Dualdial working! >> "${LOG_FILE}" && logdata_more >> "${LOG_FILE}"

#并发拨号
	#开始循环拨号;
	while :
	do
	i=$(($i+1))
	w=$(($w+1))
		[ "$logdata" = "1" ] && echo_date: no.1-----count:$(echo $i|awk '{printf("%02d\n",$0)}')------dualdial dialing! >> "${LOG_FILE}"
		[ "$logdata" = "2" ] && echo -n $(date +%b\ %d\ %X): no.1-----count:$(echo $i|awk '{printf("%02d\n",$0)}')------dualdial dialing! >> "${LOG_FILE}" && logdata_more >> "${LOG_FILE}"
		#单线双拨模式发生VLAN3丢失的几率比较大，在这里每个拨号循环都检测vlan3的加载状态，防止在拨号过程中失效，
		if [ "$(nvram get multiwanbyoneline)" = "1" ]; then
			[ "$(ps |grep wanduck|grep -v grep|wc -l)" -ne 0 ] && killall wanduck >/dev/null 2>&1 &
			vlan3_check
		fi
		#等待系统自动重连结束（提高效率;精准防止误杀）
		[ "$(ps |grep pppd|grep -v grep|awk '{print $4}'|grep 'S'|wc -l)" != "0" ] && {
			n=0
			until [ "$(route|grep 'UH'|wc -l)" != "0" ] ; do
			n=$(($n+1))
				[ "$n" -eq 30 ] && break
				sleep 2
				if [ "$(nvram get wan0_sbstate_t)" = "2" -a "$(nvram get wan1_sbstate_t)" = "2" ] ; then
					[ "$logdata" = "2" ] && echo_date: -----------------------'wanstate(wan0/wan1)='"$(nvram get wan0_state_t)//$(nvram get wan1_state_t)" 'wansbstate(wan0/wan1)='"$(nvram get wan0_sbstate_t)//$(nvram get wan1_sbstate_t)"! >> "${LOG_FILE}"
					[ "$logdata" = "2" ] && echo -n $(date +%b\ %d\ %X): no lucky!wrong password''`echo -e "\033[30;43;5m "wait more time" \033[0m"`! >> "${LOG_FILE}" && logdata_more >> "${LOG_FILE}"
					killall pppd >/dev/null 2>&1 &	#killall 之后系统会设置nvram set wan0_state_t=4//nvram set wan0_sbstate_t=0也就是联机中断
					check_pppd && sleep 65
					/usr/sbin/pppd file /tmp/ppp/options.wan0 >/dev/null 2>&1 &
					sleep 3
					continue
				fi
					[ "$logdata" = "2" ] && echo_date: -----------------------waitting! '$n='$n' wanstate(0/1)='"$(nvram get wan0_state_t)//$(nvram get wan1_state_t)" 'wansbstate(0/1)='"$(nvram get wan0_sbstate_t)//$(nvram get wan1_sbstate_t)"! >> "${LOG_FILE}"
				sleep 1
			done
			[ "$logdata" = "2" ] && echo -n $(date +%b\ %d\ %X): -----------------------check done `echo -e "\033[36;49;5m<\033[0m"``echo -e "\033[32;49;5m"$(echo $n|awk '{printf("%02d\n",$0)}')"\033[0m"``echo -e "\033[36;49;5m>\033[0m"`!! >> "${LOG_FILE}" && logdata_more >> "${LOG_FILE}"
			sleep 3 #此处延时必不可少，避免误杀的重要关卡
		}
		if [ "$(ifconfig |grep "P-t-P"|wc -l)" -lt 2 ];then #任意IP地址,不限制所获取的IP头
			[ "$automac_each_enable" = "1" ] && mac_auto
			if [ "$cycle_num_max" != "0" ]; then
				if [ "$w" -eq "$cycle_num_max" ];then
					reload_dualdial && exit
				fi
			fi
			if [ "$(nvram get multiwanbyoneline)" = "1" ] ; then
				if [ "$(( $i % 6 ))" = "0" ];then
					echo_date: -----------------------too much fail,`echo -e "\033[33;49;5m"restart service_wan"\033[0m"`!!!' $w='$w '$i='$i >> "${LOG_FILE}"
					sed -i '2c w='$w'' /tmp/dualdial_tmp.sh && \
					sed -i '3c i='$i'' /tmp/dualdial_tmp.sh &
					killall pppd >/dev/null 2>&1 &
					rm -f /var/run/syncppp.pid >/dev/null 2>&1 &
					sleep 36
					service restart_wan >/dev/null 2>&1 &
					sleep 6
					/tmp/dualdial_tmp.sh &
					exit
				fi
			fi
			if [ "$cycle_num_base" != "0" ];then
				z=$(($cycle_num_base+1))
				if [ "$(( $i % $z ))" = "0" ];then
					[ "$automac_each_enable" = "0" -a "$automac_cycle_enable" = "1" ] && mac_auto
					reload_dualdial
				fi
			fi
			[ "$logdata" = "1" ] && echo_date: no.2-------------------No lucky,retry!!! >> "${LOG_FILE}"
			[ "$logdata" = "2" ] && echo -n $(date +%b\ %d\ %X): no.2-------------------No lucky,retry!!! >> "${LOG_FILE}" && logdata_more >> "${LOG_FILE}"
			[ "$(ps |grep wanduck|grep -v grep|wc -l)" -ne 0 ] && killall wanduck >/dev/null 2>&1 &
			if [ "$(ps |grep pppd|grep -v grep|wc -l)" = "0" ]; then
				sleep 6
			else
				killall pppd >/dev/null 2>&1 &
				check_pppd && \
				sleep $dialtime
			fi
			/usr/sbin/pppd file /tmp/ppp/options.wan0 >/dev/null 2>&1 &
			/usr/sbin/pppd file /tmp/ppp/options.wan1 >/dev/null 2>&1 &
		else
			i=0
			break
		fi
		sleep 6
	done

#拨号阶段已结束，收尾;
[ "$logdata" != "2" ] && echo_date: -----------------------check result!'    ' >> "${LOG_FILE}"
[ "$logdata" = "2" ] && echo -n $(date +%b\ %d\ %X): -----------------------check result!'    ' >> "${LOG_FILE}" && logdata_more >> "${LOG_FILE}"

#IP地址定制
ip_list=`cat /tmp/dualdial_custom_ip.out`
ip_custom_check && \
[ "$logdata" != "0" ] && echo_date: `echo -e "\033[36;49;5m"ip_custum_mode="$iphead_mode",check done!" \033[0m"` >> "${LOG_FILE}"

#内网IP地址排除
if [ "$pubip_check" = 1 ]; then
	pubip_check
fi

#负载均衡检查（过滤异常）（不适用单线拨号）
n=0
until [ "$(ip route|grep nexthop 2>/dev/null|wc -l)" != "0" ] ; do
n=$(($n+1))
	if [ "$n" -eq 36 ] ; then
		break
	fi
	sleep 1
done
nexthopnum=$(ip route|grep nexthop 2>/dev/null|wc -l)
lb_UH=$(route |grep -c 'UH')
if [ "$lb_UH" -gt 2 -o "$nexthopnum" -lt 2 ];then
	[ "$logdata" != "0" -a "$loadbalance_check" = "1" ] && echo_date: `echo -e "\033[32;49;5m"reload dualdial--------"\033[0m"`sys route/lb abnormal!UH SUM:$(route |grep -c 'UH')/LB SUM:$nexthopnum >> "${LOG_FILE}"
	[ "$logdata" != "0" -a "$loadbalance_check" = "0" ] && echo_date: `echo -e "\033[32;49;5m"please remind----------"\033[0m"`sys route/lb abnormal!UH SUM:$(route |grep -c 'UH')/LB SUM:$nexthopnum >> "${LOG_FILE}"
	[ "$loadbalance_check" = "1" ] && reload_dualdial #自定义函数
fi
if [ "$nexthopnum" = "2" ];then
	if [ "$(ps |grep pppd|grep -v grep|awk '{print $4}'|grep 'S'|wc -l)" -gt 2 ]; then
		[ "$logdata" != "0" -a "$loadbalance_check" = "1" ] && echo_date: reload dualdial------too much active pppd process!UH SUM:$(route |grep -c 'UH') /LB SUM:$(ip route|grep 2>/dev/null nexthop|wc -l) /PPPD SUM:$(ps |grep pppd|grep -v grep|grep 'S'|wc -l) >> "${LOG_FILE}"
		[ "$logdata" != "0" -a "$loadbalance_check" = "0" ] && echo_date: `echo -e "\033[32;49;5m"please remind----------"\033[0m"`too much pppd process!UH SUM:$(route |grep -c 'UH') /LB SUM:$(ip route|grep 2>/dev/null nexthop|wc -l) /PPPD SUM:$(ps |grep pppd|grep -v grep|grep 'S'|wc -l)  >> "${LOG_FILE}"
		[ "$loadbalance_check" = "1" ] && reload_dualdial #自定义函数
	fi
fi

#外网连通验证（不适用单线拨号）
[ "$webcheck_enable" = "1" ] && {
	ping0=$(ping $webaddr1 -c 2 -w $ping_time -I ppp0 2>/dev/null|grep "64 bytes from"|wc -l)
	ping1=$(ping $webaddr1 -c 2 -w $ping_time -I ppp1 2>/dev/null|grep "64 bytes from"|wc -l)
	if [ "$ping0" = 0 ] || [ "$ping1" = 0 ];then
		echo $(date +%b\ %d\ %X): '    '-------------------ping fail,try with backup weburl! >> "${LOG_FILE}"
		ping2=$(ping $webaddr2 -c 2 -w $ping_time -I ppp0 2>/dev/null|grep "64 bytes from"|wc -l)
		ping3=$(ping $webaddr2 -c 2 -w $ping_time -I ppp1 2>/dev/null|grep "64 bytes from"|wc -l)
		if [ "$ping2" = 0 ] || [ "$ping3" = 0 ];then
			echo $(date +%b\ %d\ %X): '    '--reload dualdial--backup weburl ping timeout! >> "${LOG_FILE}"
			reload_dualdial #自定义函数
		else
			echo $(date +%b\ %d\ %X): weburl ping successful with backup weburl! >> "${LOG_FILE}"
		fi
	else
		echo $(date +%b\ %d\ %X): weburl ping successful...! >> "${LOG_FILE}"
	fi
}

#恢复系统监控进程（不适用单线拨号）
if [ "$(ps |grep wanduck|grep -v grep|wc -l)" != "0" ];then
	if [ "$fix_lanwan" = "1" ];then
		[ "$logdata" != "0" ] && echo wanduck re_found,reload dualdial.sh >> "${LOG_FILE}"
		killall wanduck >/dev/null 2>&1 &
		kill $(ps |grep pppd 2>/dev/null|grep wan1|awk '{print $1}') & #让WAN1下线
		sleep 6 && /tmp/dualdial_tmp.sh &
		exit
	fi
else
	if [ "$fix_lanwan" = "0" ];then
		/sbin/wanduck >/dev/null 2>&1 &
	fi
fi

#定时重置LOG文件
cru a dualdiallog_reset "00 06 * * * echo "'$(date +%b\ %d\ %X)'" log reset > ${LOG_FILE}"
sleep 2


#启动定时重连脚本
if [ "$reconnect_enable" = "1" ]; then
	sh /jffs/dualdial/cru/dualdial_cron.sh &
	sleep 2
fi

#建立定时监控:第一二种方式
if [ "$autoredial_enable" = "1" -o "$autoredial_enable" = "2" ];then
	MONITOR_FILE=/jffs/dualdial/program/dualdial_check_ip.sh

	dbus_delay=`dbus list __delay 2>/dev/null|grep dualdial_check |awk -F \= '{print $2}'|awk '{print $1}'`
	[ "$autoredial_enable" = 1 ] && {
		cru d dualdial_check >/dev/null 2>&1 &
		dbus delay dualdial_check "$autoredial_time" "${MONITOR_FILE}"
	}
	[ "$autoredial_enable" = "2" ] && {
		dbus remove `dbus list __delay 2>/dev/null|grep dualdial_check|awk -F \= '{print $1}'` >/dev/null 2>&1 &
		cru a dualdial_check "*/"$(expr $autoredial_time / 60)" * * * * "${MONITOR_FILE}""
	}
	#验证定时设置结果
	echo $(date +%b\ %d\ %X): 验证定时设置结果: >> "${LOG_FILE}"
	sleep 5
	dbus_delay_sum=`dbus list __delay 2>/dev/null|grep dualdial_check|wc -l`
	cron_check=$(cru l|grep dualdial|wc -l)
	echo $(date +%b\ %d\ %X): cron set status::line set: $cron_check'||'TOTAL line in cron:$(cru l|wc -l) >> "${LOG_FILE}"
	echo $(date +%b\ %d\ %X): dbus set status::line set: $dbus_delay_sum >> "${LOG_FILE}"
	[ "$autoredial_enable" = 1 ] && echo $(date +%b\ %d\ %X): 当前参数2定时监控值为1,如开启'定时重启'加上默认开启的'定时日志重置'则:共需向cron定时模块写入2条记录，向dbus提交1条方为成功 >> "${LOG_FILE}"
	[ "$autoredial_enable" = 2 ] && echo $(date +%b\ %d\ %X): 当前参数2定时监控值为2,如开启'定时重启'加上默认开启的'定时日志重置'则:共需向cron定时模块写入3条记录，向dbus提交0条方为成功 >> "${LOG_FILE}"
fi
ippA=$(ifconfig |grep -A1 "ppp0"|grep 'P-t-P'|awk '{print $2}'|awk -F \: '{print $2}')
ippB=$(ifconfig |grep -A1 "ppp1"|grep 'P-t-P'|awk '{print $2}'|awk -F \: '{print $2}')
gateway0=$(ifconfig |grep -A1 ppp0 2>/dev/null|grep "P-t-P" |awk '{print $3}'|awk -F \: '{print $2}') #网关地址
gateway1=$(ifconfig |grep -A1 ppp1 2>/dev/null|grep "P-t-P" |awk '{print $3}'|awk -F \: '{print $2}') #网关地址
echo -e $(date +%b\ %d\ %X): ----Congratulation!----Gateway（WAN0/WAN1）:"$gateway0"/"$gateway1" >> /tmp/syslog.log
echo -e $(date +%b\ %d\ %X): ----------------------------IP（WAN0/WAN1）:"$ippA"/"$ippB" >> /tmp/syslog.log
echo_date: ----Congratulation!----Gateway（WAN0/WAN1）:"$gateway0"/"$gateway1"`echo -e "\033[36;49;5m"//"\033[0m"`IP（WAN0/WAN1）:$ippA/$ippB >> "${LOG_FILE}"
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#启动自定义脚本
if [ "$myshell" != "" ]; then
	sh $myshell &
fi

#收集获取的IP地址及网关地址
#输出日志中出现的IP地址到指定文件夹
[ "$data_out" = "1" ] && {
cat "/tmp/dualdial.log"|grep "ip|" |awk -F \| '{print $4}'|awk -F '/' '{print $1}'|grep "." >> /tmp/dualdial_data.out && \
cat "/tmp/dualdial.log"|grep "ip|" |awk -F \| '{print $4}'|awk -F '/' '{print $2}'|grep "." >> /tmp/dualdial_data.out && \
cat "/tmp/dualdial.log"|grep "ip:" |awk -F 'ip:' '{print $2}'|awk -F '/' '{print $1}'|grep "." >> /tmp/dualdial_data.out && \
cat "/tmp/dualdial.log"|grep "ip:" |awk -F 'ip:' '{print $2}'|awk -F '/' '{print $2}'|grep "." >> /tmp/dualdial_data.out &
}

#建立定时监控:第三种方式
if [ "$autoredial_enable" = "3" ];then
	dbus remove `dbus list __delay 2>/dev/null|grep dualdial_check|awk -F \= '{print $1}'` >/dev/null 2>&1 &
	cru d dualdial_check >/dev/null 2>&1 &
	sleep 2 && /jffs/dualdial/program/dualdial_check_ip.sh &
fi
exit 0
