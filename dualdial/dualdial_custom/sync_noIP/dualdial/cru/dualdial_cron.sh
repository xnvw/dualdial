#!/bin/sh
#++++++++++++++++++++++++++++++++++++++++++
# 参数设定 	  （参数设定行前面不要有空格）#
#+++++++++++++++++++++++++++++++++++++++++#
#【参数7】定时重连;1/2/3可选;
#开关需要到dualdial.sh的参数7中设置
#1启用定时重拨，2启用定时重启路由，3启用定时开关无线
reconnect_enable=3
#【参数7A】7的重连模式;0/1可选;0指定每周某天重连;1每隔几天重连
reconnect_mode=0
#【参数7B】7的周日设置
redial_weekday=1,2,3,4,5,6,0
#【参数7C】7的间隔天数
redial_day=3
#【参数7D】7的时间点
redial_hour=4

if [ "$reconnect_enable" != "0" ];then
	if [ "$reconnect_enable" = "1" ];then
		[ "$reconnect_mode" = "0" ] && cru a dualdial_reconnect "0 "$redial_hour" * * "$redial_weekday" killall pppd"
		[ "$reconnect_mode" = "1" ] && cru a dualdial_reconnect "0 "$redial_hour" "$redial_day" * * killall pppd"
	elif [ "$reconnect_enable" = "2" ];then
		[ "$reconnect_mode" = "0" ] && cru a dualdial_reconnect "0 "$redial_hour" * * "$redial_weekday" reboot"
		[ "$reconnect_mode" = "1" ] && cru a dualdial_reconnect "0 "$redial_hour" "$redial_day" * * reboot"
	elif [ "$reconnect_enable" = "3" ];then
		[ "$reconnect_mode" = "0" ] && cru a dualdial_reconnect "0 "$redial_hour" * * "$redial_weekday" wl -i eth1 down && wl -i eth2 down && sleep 60 && wl -i eth1 up && wl -i eth2 up &"
		[ "$reconnect_mode" = "1" ] && cru a dualdial_reconnect "0 "$redial_hour" "$redial_day" * * wl -i eth1 down && wl -i eth2 down && sleep 60 && wl -i eth1 up && wl -i eth2 up &"
	fi	
fi
