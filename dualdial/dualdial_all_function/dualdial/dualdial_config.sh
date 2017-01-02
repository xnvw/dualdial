#!/bin/sh
#+++++++++++++++++++++++++++++++++++++++++#
#参数设定 	  （参数设定行前面不要有空格）#
#+++++++++++++++++++++++++++++++++++++++++#

#【参数A】并发/非并发<0/1/2可选;0:并发;1:非并发;2:单线拨号>
# 并发双拨/非并发双线拨号/单线拨号均适用
dial_mode=0

#【参数B】指定断开的线路;0/1/2可选;<0全断;1只断开WAN0;2只断开WAN1>
# 并发双拨/非并发双线拨号适用
# 并发模式必须选择0;非并发需选择0/1或2;对单线拨号无效（设置什么也没影响）
wan_down=0

#【参数C】拨号循环设置
# 并发双拨适用
# 设置拨号循环次数
cycle_num_base=60

# 拨号循环间隔时间;0~可选,单位:秒
# 并发双拨适用
cycle_time_base=1800

#【参数C1】循环拨号多少次后脚本退出放弃拨号
# 并发双拨适用
# 退出后会如果wan1没有ip地址就会停掉wan1的拨号进程，免得它在后台不停尝试拨号
# 0:关闭;一直拨号
# 1:开启;停止拨号>>脚本退出;
cycle_num_max=120

#【参数C2】每次拨号间隔;0~可选,单位:秒
# 并发双拨适用
# 这里控制每次拨号的间隔,参数C中的cycle_time_base控制循环的间隔
dialtime=6

#【参数D】VLAN3检测失败后的措施;(重启容易起不来的机器推荐选择3)
# 并发双拨/非并发双线拨号适用
# 针对单线双拨开了multi pppd功能的机器;开了multi pppd功能，在软重启或者执行命令service restart_wan时有几率导致VLAN3丢失
# 双线双拨的机器不会导致VLAN3失效，从而不会触发到这个参数，所以随便选;
# 1 脚本直接退出，放弃拨号
# 2 软重启路由，执行命令reboot,路由将重启，由于开机脚本services-start的存在，重启后脚本将重启拨号
# 3 重启无线，执行命令restart_wireless，路由也会重启，适合部分机器重启会起不来的，据观察这个命令也可以恢复vlan3，并且不会使路由起不来
vlan3_fail=3

#【参数1】修复网线未接0/1可选;0不需要，1需要
# 并发双拨/非并发双线拨号适用
fix_lanwan=1

#【参数2】掉线重拨;0/1/2/3可选;0关闭;1启用:以dbus的方式;2启用:以cron定时方式;3启用:sleep方式定时;
# 并发双拨/非并发双线拨号/单线拨号均适用
autoredial_enable=1

#【参数2A】2的检测间隔;0~可选;单位:秒
# 并发双拨/非并发双线拨号/单线拨号均适用
autoredial_time=60

#【参数3】更换MAC;0/1可选;0关闭;1启用<automac_each_enable每次拨号更换MAC;automac_cycle_enable每循环更换MAC>
# 并发双拨/非并发双线拨号适用
automac_each_enable=0
automac_cycle_enable=0

#【参数4】负载均衡检测;0/1可选;0关闭;1启用
# 并发双拨/非并发双线拨号适用
loadbalance_check=1

#【参数5】外网验证;0/1可选;0关闭;1启用(不适用于单线拨号)
# 并发双拨IP定制适用，并发双拨不开IP定制不适用；非并发适用
webcheck_enable=1

#【参数5A】5用到的网址
# 并发双拨IP定制适用，并发双拨不开IP定制不适用；非并发适用
webaddr1=www.jd.com
webaddr2=www.toutiao.com

#【参数5B】5的超时时间;1~可选;
# 并发双拨IP定制适用，并发双拨不开IP定制不适用；非并发适用
ping_time=10

#【参数6】日志输出;0/1/2三级可选;0最小日志内容输出;1较多日志内容输出;2最多日志内容输出
# logdata负责控制拨号过程中的日志输入量；logcheck负责控制掉线监控脚本的日志输出量
# logdata值仅并发双拨不开ip定制不适用，logcheck都适用
# 并发拨号不开启IP定制时拨号过程中的日志输出为教少量的输出，不需控制，只能控制掉线监控脚本的输入内容，即logdata无效
logdata=2
logcheck=2

#【参数6A】数据输出;0/1可选;0关闭;1启用
# 仅并发双拨开了IP定制适用
# 一般不需开启，除非玩到深处
data_out=0

#【参数7】定时重连开关
# 并发双拨/非并发双线拨号/单线拨号全部都适用
# 这里只是个开关，具体参数请到dualdial_cron.sh文件进行设置，本脚本只负责在拨号结束后把dualdial_cron.sh运行起来
# 这样有能力的可以自己把dualdial_cron.sh内的定时方式修改的更多样化，不用拘泥于脚本里设好的选项，本来cron命令支持的定时花样就很多的
# 0关闭;1启用
reconnect_enable=1

#【参数8】：IP定制/网关定制的开/关;0/1/2可选;0关闭;1启用定制IP地址;2启用定制网关
# 仅并发双拨没开IP定制的不适用
ip_custom_enable=1

#【参数8A】8的定制模式;1/2/3/4/5/6/7/8/9可选;<1排除模式一;2排除模式二;3相同模式一;4相同模式二;5包含模式一;6包含模式二;7相异模式;8排除模式;9包含模式;>
# 仅并发双拨没开IP定制的不适用
# 模式8/9仅适用单线拨号
iphead_mode=9

#【参数8B】8需对比的IP头位数;1/2/3可选;
# 仅并发双拨没开IP定制以及单线拨号的不适用
iphead_group_wan=2		#IP定制模式如选择2/3/4/7则需设置此项，这三种模式会拿wan0与wan1的ip地址或者网关的前几组自己互相对比，

#需定制的ip地址列表
# 仅并发双拨没开IP定制的不适用
# 列表每行一个，每行可以不同IP组数目，可以直接填写在list_3里，也可以放到list_1/list_2的路径下面，但是路径下面要真实存在这个文件，才能启用把前面的#号去掉，不然会报错
# 另外现在列表里每行的IP地址头的组数不用非得一样了，可以像下面list_3一样，一行一组的一行3组的，再一行也可以2组的随便混合编排。
#----------------------------------------------------------
list_1=`cat /jffs/dualdial/ip/dualdial_custom_ip_1.txt`
list_2=`cat /jffs/dualdial/ip/dualdial_custom_ip_2.txt`
#----------------------------------------------------------
#上面一行的引号和等号[=]后的引号必须保留

#【参数8C】8需选用的列表
# 仅并发双拨没开IP定制的不适用
custom_ip_list=$list_1

#【参数9】自定义脚本
# 并发双拨/非并发双线拨号/单线拨号全部都适用
myshell=

#【参数10】内网IP排除
# 并发双拨/非并发双线拨号/单线拨号全部都适用
# 用于获取公网IP的网址需要到/jffs/dualdial/pubweb/pubweblist.txt维护
# 0 关闭
# 1 开启
pubip_check=0
#+++++++++++++++++++++++++++++++++++++++++++++++++++
#	上面的 参 数 设 定 结 束，下面的不需理会 		#
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
LOG_FILE="/tmp/dualdial.log"
source /jffs/dualdial/program/dualdial_var.sh
if [ "$dial_mode" = "0" -a "$ip_custom_enable" = "0" ]; then	#并发双拨，不开IP定制
	cp -f /jffs/dualdial/program/sync_noip/dualdial_main.sh /tmp/dualdial_tmp.sh &
	sleep 2
	var_transfer_main_sync_noip
	var_transfer_monitor
elif [ "$dial_mode" = "0" -a "$ip_custom_enable" != "0" ]; then	#并发双拨，IP定制
	if [ "$iphead_mode" = "8" -o "$iphead_mode" = "9" ]; then
		echo $(date +%b\ %d\ %X): IP定制模式选择错误,请重新选择,拨号辅助脚本将退出! |tee -a /tmp/syslog.log >> /tmp/dualdial.log
		exit
	else
		ln -sf /jffs/dualdial/program/sync_ip/dualdial_main.sh /tmp/dualdial_tmp.sh &
		sleep 2
		var_transfer_main_sync_ip
		var_transfer_iplist
		var_transfer_monitor
	fi
elif [ "$dial_mode" = "1" ]; then	#非并发双拨IP定制
	if [ "$iphead_mode" = "8" -o "$iphead_mode" = "9" ]; then
		echo $(date +%b\ %d\ %X): IP定制模式选择错误,请重新选择,拨号辅助脚本将退出! |tee -a /tmp/syslog.log >> /tmp/dualdial.log
		exit
	else
		ln -sf /jffs/dualdial/program/nosync/dualdial_main.sh /tmp/dualdial_tmp.sh &
		sleep 2
		var_transfer_main_nosync
		var_transfer_iplist
		var_transfer_monitor
	fi
elif [ "$dial_mode" = "2" ]; then	#单线拨号,IP定制
	if [ "$iphead_mode" != "8" -a "$iphead_mode" != "9" ]; then
		echo $(date +%b\ %d\ %X): IP定制模式选择错误,请重新选择,拨号辅助脚本将退出! |tee -a /tmp/syslog.log >> /tmp/dualdial.log
		exit
	else
		ln -sf /jffs/dualdial/program/one/dualdial_main.sh /tmp/dualdial_tmp.sh &
		sleep 2
		var_transfer_main_one
		var_transfer_iplist
		var_transfer_monitor
	fi
fi
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#开始运行主脚本dualdial.sh的临时文件
sleep 1
/tmp/dualdial_tmp.sh &
