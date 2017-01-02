#!/bin/sh
#++++++++++++++++++++++++++++++++++++++++++
#上面参数禁止移动位置
#++++++++++++++++++++++++++++++++++++++++++
LOG_FILE="/tmp/dualdial.log"
[ "$ip_custom_enable" != "0" ] && \
source /jffs/dualdial/program/one/dualdial_function_ipone.sh
source /jffs/dualdial/program/one/dualdial_function.sh
alias echo_date:='echo $(date +%b\ %d\ %X):'
#+++++++++++++++++++++++++++++++++++++++++

#日志三级显示
logdata_more(){
	bb=$(route |grep 'default' 2>/dev/null|wc -l)
	cc=$(route|grep 'UH' 2>/dev/null|wc -l)
	c=$(nvram get wan0_pppoe_ifname)
	ippA=$(ifconfig |grep -A1 "ppp"|grep 'P-t-P'|awk '{print $2}'|awk -F \: '{print $2}'|sed -n '1p')
	pppd=$(ps |grep pppd|grep -v grep|awk '{print $4}'|grep 'S'|wc -l)
	[ "$c" != "" ] && echo -e default/uh//pppd:`echo -e "\033[36;49;5m "$bb'\t'$cc//$pppd" \033[0m"`ppoe_ifname:$c'||'ip:$ippA >> "${LOG_FILE}"
	[ "$c" = "" ] && echo -e default/uh//pppd:`echo -e "\033[36;49;5m "$bb'\t'$cc//$pppd" \033[0m"`ppoe_ifname:'    ||'ip:$ippA >> "${LOG_FILE}"
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

echo_date: no.0-------Dualdial working! >> /tmp/syslog.log
[ "$logdata" != "2" ] && (echo_date: no.0--------------------Dualdial working!) >> "${LOG_FILE}"
[ "$logdata" = "2" ] && (echo -n $(date +%b\ %d\ %X): no.0--------------------Dualdial working!) >> "${LOG_FILE}" && logdata_more >> "${LOG_FILE}"

#单线拨号
if [ "$(nvram get wans_dualwan)" = "wan none" ]; then
	[ "$(ps |grep wanduck|grep -v grep|wc -l)" -ne 0 ] && killall wanduck >/dev/null 2>&1 &
	n=0
	until [ "$(route|grep "UH"|wc -l)" != "0" ] ; do
	n=$(($n+1))
		if [ "$(ps |grep pppd|grep -v grep|awk '{print $4}'|grep 'S'|wc -l)" != "0" ] ; then
			if [ "$n" -eq 30 ] ; then
				echo $(date +%b\ %d\ %X): ------------------------No lucky,retry last time and exit!!! >> "${LOG_FILE}"
				killall pppd 2>/dev/null
				check_pppd
				sleep 6
				service restart_wan >/dev/null 2>&1 &
				exit
			fi
			if [ "$(nvram get wan0_sbstate_t)" = "2" ] ; then
				[ "$logdata" = "2" ] && echo -n $(date +%b\ %d\ %X): no lucky!wrong password' '`echo -e "\033[30;43;5m "wait more time" \033[0m"`! >> "${LOG_FILE}" && logdata_more >> "${LOG_FILE}"
				killall pppd >/dev/null 2>&1 &	#killall 之后系统会设置nvram set wan0_state_t=4//nvram set wan0_sbstate_t=0也就是显示联机中断
				check_pppd && sleep 65
				/usr/sbin/pppd file /tmp/ppp/options.wan0 >/dev/null 2>&1 &
				sleep 3
				continue
			fi
			sleep 1
		else
			echo  -n $(date +%b\ %d\ %X): ------------------------restart pppd!'    ' >> "${LOG_FILE}" && logdata_more >> "${LOG_FILE}"
			killall pppd 2>/dev/null
			check_pppd
			sleep 6
			/usr/sbin/pppd file /tmp/ppp/options.wan0 >/dev/null 2>&1 &
			sleep 6
		fi
	done
else
	echo $(date +%b\ %d\ %X): ---当前路由系统不是单线拨号,拨号辅助脚本不适用！将退出!!! |tee -a /tmp/syslog.log >> "${LOG_FILE}"
	exit
fi
#拨号阶段已结束，收尾;
[ "$logdata" != "2" ] && echo_date: ------------------------check result! >> "${LOG_FILE}"
[ "$logdata" = "2" ] && echo -n $(date +%b\ %d\ %X): ------------------------check result!'    ' >> "${LOG_FILE}" && logdata_more >> "${LOG_FILE}"

#IP地址定制-单线拨号
[ "$ip_custom_enable" != "0" ] && {
	ip_list=`cat /tmp/dualdial_custom_ip.out`
	ip_custom_check_one && \
	[ "$logdata" != "0" ] && echo_date: `echo -e "\033[36;49;5m"ip_custum_mode="$iphead_mode",check done!" \033[0m"` >> "${LOG_FILE}"
}

#内网IP地址排除
if [ "$pubip_check" = 1 ]; then
	pubip_check
fi

#恢复系统监控进程
if [ "$(ps |grep wanduck|grep -v grep|wc -l)" = "0" ];then
	/sbin/wanduck >/dev/null 2>&1 &
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
	MONITOR_FILE=/jffs/dualdial/program/one/dualdial_check_ipone.sh

	dbus_delay=`dbus list __delay 2>/dev/null|grep dualdial_check |awk -F \= '{print $2}'|awk '{print $1}'`
	[ "$autoredial_enable" = "1" ] && {
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
	[ "$autoredial_enable" = "1" ] && echo $(date +%b\ %d\ %X): 当前参数2定时监控值为1,如开启'定时重启'加上默认开启的'定时日志重置'则:共需向cron定时模块写入2条记录，向dbus提交1条方为成功 >> "${LOG_FILE}"
	[ "$autoredial_enable" = "2" ] && echo $(date +%b\ %d\ %X): 当前参数2定时监控值为2,如开启'定时重启'加上默认开启的'定时日志重置'则:共需向cron定时模块写入3条记录，向dbus提交0条方为成功 >> "${LOG_FILE}"
fi

ippA=$(ifconfig |grep -A1 ppp0 2>/dev/null|grep "P-t-P" |awk '{print $2}'|awk -F \: '{print $2}') #ip地址
gateway0=$(ifconfig |grep -A1 ppp0 2>/dev/null|grep "P-t-P" |awk '{print $3}'|awk -F \: '{print $2}') #网关地址
echo -e $(date +%b\ %d\ %X): ----Congratulation!-----Gateway（WAN0）:"$gateway0" >> /tmp/syslog.log
echo -e $(date +%b\ %d\ %X): -----------------------------IP（WAN0）:"$ippA" >> /tmp/syslog.log
echo_date: ----Congratulation!-----Gateway（WAN0/WAN1）:"$gateway0"`echo -e "\033[36;49;5m"//"\033[0m"`IP（WAN0）:$ippA >> "${LOG_FILE}"

#启动自定义脚本
if [ "$myshell" != "" ]; then
	sh $myshell &
fi

#建立定时监控:第三种方式
if [ "$autoredial_enable" = "3" ];then
	dbus remove `dbus list __delay 2>/dev/null|grep dualdial_check|awk -F \= '{print $1}'` >/dev/null 2>&1 &
	cru d dualdial_check >/dev/null 2>&1 &
	[ "$ip_custom_enable" != "0" ] && sleep 2 && /jffs/dualdial/program/one/dualdial_check_ipone.sh &
fi
exit 0
