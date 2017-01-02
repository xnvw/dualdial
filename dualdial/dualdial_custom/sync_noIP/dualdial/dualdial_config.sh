#!/bin/sh
#+++++++++++++++++++++++++++++++++++++++++#
#参数设定 	  （参数设定行前面不要有空格）#
#+++++++++++++++++++++++++++++++++++++++++#
#【参数C】拨号循环设置
# 并发双拨适用
# 设置拨号循环次数
cycle_num_base=60

# 拨号循环间隔时间;0~可选,单位:秒
# 并发双拨适用
cycle_time_base=1800

#【参数C1】循环拨号多少次后脚本退出放弃拨号
# 退出后会如果wan1没有ip地址就会停掉wan1的拨号进程，免得它在后台不停尝试拨号
# 0:关闭;一直拨号
# 1:开启;停止拨号>脚本退出;
cycle_num_max=120

#【参数C2】每次拨号间隔;0~可选,单位:秒
# 这里控制每次拨号的间隔,参数C中的cycle_time_base控制循环的间隔
dialtime=6

#【参数D】VLAN3检测失败后的措施;(重启有问题的机器推荐选择3)
# 针对单线双拨开了multi pppd功能的机器;开了multi pppd功能，在软重启或者执行命令service restart_wan时有几率导致VLAN3丢失
# 双线双拨的机器不会导致VLAN3失效，从而不会触发到这个参数，所以随便选;
# 1 脚本直接退出，放弃拨号
# 2 软重启路由，执行命令reboot,路由将重启，由于开机脚本services-start的存在，重启后脚本将重启拨号
# 3 重启无线，执行命令restart_wireless，路由也会重启，适合部分机器重启会起不来的，据观察这个命令也可以恢复vlan3，并且不会使路由起不来
vlan3_fail=3

#【参数1】修复网线未接0/1可选;0不需要，1需要
fix_lanwan=1

#【参数2】掉线重拨;0/1/2/3可选;0关闭;1启用:以dbus的方式;2启用:以cron定时方式;3启用:sleep方式定时;
autoredial_enable=1

#【参数2A】2的检测间隔;0~可选;单位:秒
autoredial_time=60

#【参数3】更换MAC;0/1可选;0关闭;1启用<automac_each_enable每次拨号更换MAC;automac_cycle_enable每循环更换MAC>
automac_each_enable=0
automac_cycle_enable=0

#【参数4】负载均衡检测;0/1可选;0关闭;1启用
loadbalance_check=1

#【参数6】日志输出;0/1/2三级可选;0最小日志内容输出;1较多日志内容输出;2最多日志内容输出
# 控制掉线监控脚本的输入内容
logcheck=2

#【参数7】定时重连开关
# 这里只是个开关，具体参数请到dualdial_cron.sh文件进行设置，本脚本只负责在拨号结束后把dualdial_cron.sh运行起来
# 这样有能力的可以自己把dualdial_cron.sh内的定时方式修改的更多样化，不用拘泥于脚本里设好的选项，本来cron命令支持的定时花样就很多的
# 0关闭;1启用
reconnect_enable=1

#【参数8】内网IP排除
# 用于获取公网IP的网址需要到/jffs/dualdial/pubweb/pubweblist.txt维护
# 0 关闭
# 1 开启
pubip_check=0

#【参数9】自定义脚本
myshell=
#+++++++++++++++++++++++++++++++++++++++++++++++++++
#	上面的 参 数 设 定 结 束，下面的不需理会 		#
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
LOG_FILE="/tmp/dualdial.log"
source /jffs/dualdial/program/dualdial_var.sh
#并发双拨，不开IP定制
	cp -f /jffs/dualdial/program/sync_noip/dualdial_main.sh /tmp/dualdial_tmp.sh &
	sleep 2
	var_transfer_main_sync_noip
	var_transfer_monitor
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#开始运行主脚本dualdial.sh的临时文件
sleep 1
/tmp/dualdial_tmp.sh &
