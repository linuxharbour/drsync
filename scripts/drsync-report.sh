#!/bin/sh
# drsync-report.sh
# developed by Sammy Fung <sammy@sammy.hk>
# Use space to seperate multiple admin email addresses
conffile=/etc/drsync.conf
ADMIN_EMAIL=`grep ^admin= ${conffile} | tail -n 1 | sed -e "s/^admin=//"`
if [ a${admin} == 'a' ];
then
  ADMIN_EMAIL='root'
fi
CONT="Dear Admin,\n\nReport of drsync backup(s) are attached for your refernece."
hostname=`hostname -f`
OLDTASKFILE=/var/log/drsync-task.log
TASKFILE=/var/log/drsync-task.log.csv
TXLFILE=/var/log/drsync-tx-filelist.log.txt
REPTIME=`date +%s`
ARCHDIR=/var/log/drsync
rm /var/log/test*.log
cat /var/log/drsync-[0-9]*.log > /var/log/test.log
sed -e "s/^sent .* bytes\/sec//g" -e "s/^total size is .*//g" -e "s/[Rr]sync [SEse].*//g" -e "s/^receiving incremental file list$//g" -e "s/^[A-Z]* (Start|End) .* HKT [0-9]*$//g" /var/log/test.log >> /var/log/test2.log
sort /var/log/test2.log | uniq -c > ${TXLFILE}

touch ${TASKFILE}
mv ${OLDTASKFILE} ${TASKFILE}

echo ${CONT} | mutt -a ${TASKFILE} -a ${TXLFILE} -s "[${hostname}] drsync report" -- ${ADMIN_EMAIL}
mkdir ${ARCHDIR}/${REPTIME}
mv ${TASKFILE} ${ARCHDIR}/${REPTIME}/drsync-task-${REPTIME}.csv
mv /var/log/drsync-[0-9]*.log ${ARCHDIR}/${REPTIME}

rm /var/log/test*.log
