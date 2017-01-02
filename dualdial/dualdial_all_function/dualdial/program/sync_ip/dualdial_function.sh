#!/bin/sh
#重新载入主脚本
reload_dualdial(){
	if [ "$cycle_num_max" != "0" ]; then
		if [ "$cycle_num_max" = "$w" ]; then
			echo $(date +%b\ %d\ %X): '     'MAX_cycle reached,Dualdial will exit!'$w='$w >> "${LOG_FILE}"
			dualdial_cease && sleep 6
			if [ "$fix_lanwan" = "0" ]; then
				[ "$(ps |grep wanduck|grep -v grep|wc -l)" = "0" ] && /sbin/wanduck &
			elif [ "$fix_lanwan" = "1" ]; then
				if [ "$autoredial_enable" = "3" ];then
					sleep 2
					/jffs/dualdial/program/dualdial_check.sh &
				else
					cru a dualdial_check "*/2 * * * * /jffs/dualdial/program/dualdial_check.sh"
				fi
			fi
			exit
		fi
	fi
	if [ "$i" != "0" -a "$(( $i % $(($cycle_num_base+1)) ))" = "0" ];then
		[  "$logdata" != "0" ] && echo $(date +%b\ %d\ %X): -----------------------cycle_num_base reached,'$w='$w reset! >> "${LOG_FILE}"
		sed -i '2c w='$w'' /tmp/dualdial_tmp.sh && \
		sed -i '3c i='$i'' /tmp/dualdial_tmp.sh &
		if [ "$cycle_time_base" -ge 300 ] ; then
			dualdial_cease
			cru a dualdial_jump "*/"$(expr $cycle_time_base / 60)" * * * * /tmp/dualdial_tmp.sh &"
			if [ "$fix_lanwan" = "0" ]; then
				[ "$(ps |grep wanduck|grep -v grep|wc -l)" = "0" ] && /sbin/wanduck &
			elif [ "$fix_lanwan" = "1" ]; then
				if [ "$autoredial_enable" = "3" ];then
					sleep 2
					/jffs/dualdial/program/dualdial_check.sh &
				else
					cru a dualdial_check "*/2 * * * * /jffs/dualdial/program/dualdial_check.sh"
				fi
			fi
			exit
		else
			if [ "$cycle_time_base" -lt 60 ] ;then
				killall pppd >/dev/null 2>&1 &
				check_pppd && \
				sleep $cycle_time_base && \
				if [ "$(nvram get multiwanbyoneline)" = "0" ]; then 
					service restart_wan >/dev/null 2>&1
				elif [ "$(nvram get multiwanbyoneline)" = "1" ]; then
					/usr/sbin/pppd file /tmp/ppp/options.wan0 >/dev/null 2>&1 &
					/usr/sbin/pppd file /tmp/ppp/options.wan1 >/dev/null 2>&1 &
				fi
			else
				dualdial_cease
				sleep $cycle_time_base
			fi
			sleep 3 && \
			/tmp/dualdial_tmp.sh &
			exit
		fi
	fi
	#没有达到循环次数时都执行下面的命令
	sed -i '2c w='$w'' /tmp/dualdial_tmp.sh && \
	sed -i '3c i='$i'' /tmp/dualdial_tmp.sh &
	killall pppd >/dev/null 2>&1 &
	check_pppd && \
	sleep $dialtime
	/usr/sbin/pppd file /tmp/ppp/options.wan0 >/dev/null 2>&1 &
	/usr/sbin/pppd file /tmp/ppp/options.wan1 >/dev/null 2>&1 &
	sleep 6 && \
	/tmp/dualdial_tmp.sh &
	exit
}