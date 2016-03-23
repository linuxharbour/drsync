#!/bin/sh
# drsync.sh
# developed by Sammy Fung <sammy@sammy.hk>
ADMIN=root
timesec=`date +%s`
logfile=/var/log/drsync-${timesec}
tasklog=/var/log/drsync-task.log
PIDFILE=/var/run/drsync.pid
conffile=/etc/drsync.conf
if [ -f ${PIDFILE} ];
then
  pidrun=`cat ${PIDFILE}`
  t=`date`
  echo [${0}] ${t} drsync process ${pidrun} is running, aborted. | tee -a /var/log/drsync-on-hold.log
  exit
else
  echo $$ > ${PIDFILE}
fi
for task in `cat ${conffile}`
do
  lab=`echo ${task} | cut -f 1 -d ,`
  src=`echo ${task} | cut -f 2 -d ,`
  dst=`echo ${task} | cut -f 3 -d ,`
  sshport=`echo ${task} | cut -f 4 -d ,`
  if [ a${sshport} == 'a' ];
  then
    sshport=22
  fi
  start=`date`
  echo Rsync Started at ${start} >> ${logfile}-${lab}.log
  rsync -av -e "ssh -p ${sshport}" ${src} ${dst} | tee -a ${logfile}-${lab}.log 
  end=`date`
  echo Rsync Ended at ${end} >> ${logfile}-${lab}.log
  rstat=`tail -n 4 ${logfile}-${lab}.log | head -n 2 | sed -e "s/[\r\n]//g" -e "s/sent //g" -e "s/bytes //g" -e "s/received //g" -e "s/total //g" -e "s/speedup //g" -e "s/is //g" -e "s/bytes\/sec//g" -e "s/size //g" -e "s/,//g"`
  echo ${lab},${src},${dst},${start},${end},${rstat},${logfile}-${lab}.log >> ${tasklog}
done
rm ${PIDFILE}
