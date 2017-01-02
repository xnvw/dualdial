#!/bin/sh

start_file_set(){
	if [ ! -f /jffs/scripts/services-start ]; then
      cat > /jffs/scripts/services-start <<EOF
#!/bin/sh
EOF
	fi
	servicesset=`cat "/jffs/scripts/services-start" | grep "dualdial"|wc -l`
	if [ "$servicesset" -lt 1 ];then
		sed -i '1a \sh\ \/jffs/scripts/dualdial.sh start &' /jffs/scripts/services-start
	fi
	chmod +x /jffs/scripts/services-start
}

start_file_remove(){
sed -i '/dualdial.sh/d' /jffs/scripts/services-start
}

start_main(){
	sh /jffs/dualdial/dualdial_config.sh &
}

clear_cron(){
dbus remove `dbus list __delay 2>/dev/null|grep dualdial_check|awk -F \= '{print $1}'` >/dev/null 2>&1
cru d dualdial_check >/dev/null 2>&1 && \
cru d dualdial_jump >/dev/null 2>&1 && \
cru d dualdiallog_reset >/dev/null 2>&1 && \
cru d dualdial_reconnect >/dev/null 2>&1
}

kill_process_monitor(){
killall dualdial_check.sh >/dev/null 2>&1
}

kill_process_main(){
killall dualdial_tmp.sh >/dev/null 2>&1
rm -f /tmp/dualdial_tmp.sh
sleep 2
}

remove_file(){
rm -rf /jffs/dualdial/
rm -rf /jffs/scripts/dualdial.sh
reboot
}


case $1 in
  start)
	start_file_set
	clear_cron
	kill_process_monitor
	kill_process_main
	start_main
    ;;
  stop)
	start_file_remove
	clear_cron
	kill_process_monitor
	kill_process_main
    ;;
  remove)
  	start_file_remove
	clear_cron
	kill_process_monitor
	kill_process_main
    remove_file
    ;;
  *)
    echo "Usage: sh `basename $0` [start,stop,remove]" && exit
    ;;
esac