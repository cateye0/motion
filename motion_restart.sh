#!/bin/bash

# crontab
# m h  dom mon dow   command
#*/5 * * * * /root/motion_restart.sh >/dev/null 2>&1

#MYPROG="/usr/bin/motion"
STOP="/usr/sbin/service motion stop"
START="/usr/sbin/service motion start"
#PGREP="/usr/bin/pgrep"
LOG="/tmp/motion.log"
VAR1="!!! MOTION RESTARTED BY CRONTAB !!!"
VAR2=`date '+%Y-%m-%d %H:%M:%S'`

# find myprog pid
#$PGREP ${MYPROG}
# if not running
#if [ $? -ne 0 ]
#then
#   $STOP
#   sleep 10
#   $START
#   echo -e $VAR1 >> $LOG
#   echo -e $VAR2 >> $LOG
#fi


if ps -ef | grep -v grep | grep /usr/bin/motion ; then
        exit 0
else
        $STOP
        sleep 10
        $START
        echo -e $VAR1 >> $LOG
        echo -e $VAR2 >> $LOG
        exit 0
fi
