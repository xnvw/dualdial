#!/bin/sh
#+++++++++++++++++++++++++++++++++++++++++#
#参数设定 	  （参数设定行前面不要有空格）#
#+++++++++++++++++++++++++++++++++++++++++#

#【参数1】掉线重拨;0/1/2/3可选;0关闭;1启用:以dbus的方式;2启用:以cron定时方式;3启用:sleep方式定时;
autoredial_enable=1

#【参数1A】2的检测间隔;0~可选;单位:秒
autoredial_time=60

#【参数2】日志输出;0/1/2三级可选;0最小日志内容输出;1较多日志内容输出;2最多日志内容输出
# logdata负责控制拨号过程中的日志输入量；logcheck负责控制掉线监控脚本的日志输出量
logdata=2
logcheck=2

#【参数3】定时重连开关
# 这里只是个开关，具体参数请到dualdial_cron.sh文件进行设置，本脚本只负责在拨号结束后把dualdial_cron.sh运行起来
# 这样有能力的可以自己把dualdial_cron.sh内的定时方式修改的更多样化，不用拘泥于脚本里设好的选项，本来cron命令支持的定时花样就很多的
# 0关闭;1启用
reconnect_enable=1

#【参数4】：IP定制/网关定制的开/关;1/2可选;1启用定制IP地址;2启用定制网关
ip_custom_enable=1

#【参数4A】4的定制模式;1/2可选;1排除模式;2包含模式;
# 模式1/2仅适用单线拨号
iphead_mode=1

#需定制的ip地址列表
#列表每行一个，每行可以不同IP组数目，可以直接填写在list_3里，也可以放到list_1/list_2的路径下面，但是路径下面要真实存在这个文件，才能启用把前面的#号去掉，不然会报错
#另外列表里每行的IP地址头的组数不用非得一样，可以一行一组的一行3组的，再一行也可以2组的随便混合编排。
#----------------------------------------------------------
list_1=`cat /jffs/dualdial/ip/dualdial_custom_ip_1.txt`
list_2=`cat /jffs/dualdial/ip/dualdial_custom_ip_2.txt`
#----------------------------------------------------------

#【参数4C】4需选用的列表
custom_ip_list=$list_1

#【参数5】内网IP排除
# 用于获取公网IP的网址需要到/jffs/dualdial/pubweb/pubweblist.txt维护
# 0 关闭
# 1 开启
pubip_check=1

#【参数6】自定义脚本
myshell=
#+++++++++++++++++++++++++++++++++++++++++++++++++++
#	上面的 参 数 设 定 结 束，下面的不需理会 		#
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
LOG_FILE="/tmp/dualdial.log"
source /jffs/dualdial/program/dualdial_var.sh
#单线拨号,IP定制
if [ "$iphead_mode" != "1" -a "$iphead_mode" != "2" ]; then
	echo $(date +%b\ %d\ %X): IP定制模式选择错误,请重新选择,拨号辅助脚本将退出! |tee -a /tmp/syslog.log >> "${LOG_FILE}"
	exit
else
	cp -f /jffs/dualdial/program/one/dualdial_main.sh /tmp/dualdial_tmp.sh &
	sleep 2
	var_transfer_main_one
	var_transfer_iplist
	var_transfer_monitor
fi
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#开始运行主脚本dualdial.sh的临时工作文件
sleep 1
/tmp/dualdial_tmp.sh &
