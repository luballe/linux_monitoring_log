#!/bin/bash

#logPath="/home/ec2-user/log.txt"
#Crontab:
#* * * * * /home/ideca-ider/monitoring.sh /home/ideca-ider/log.txt
#* * * * * /home/g2waysportsaws/monitoring.sh /home/g2waysportsaws/log.txt

logPath=$1
pids=""
sep=","
function getCpu {
  cpuCmd=`sar 1 1 | awk 'NR==4{printf "%.1f\n",100-$9}'`
  echo $cpuCmd
}
function getMem {
  memCmd=`sar -r 1 1 | awk 'NR==4{printf "%.1f\n",$5}'`
  echo $memCmd
}
function getDiskRead {
  diskReadCmd=`sar -b 1 1 | awk 'NR==4{printf "%.1f\n",$4}'`
  echo $diskReadCmd
}
function getDiskWrite {
  diskWriteCmd=`sar -b 1 1 | awk 'NR==4{printf "%.1f\n",$5}'`
  echo $diskWriteCmd
}
function getNetIn {
  netInCmd=`sar -n DEV 1 1 | grep eth0 | awk 'NR==1{printf "%.1f\n",$6}'`
  echo $netInCmd
}
function getNetOut {
  netOutCmd=`sar -n DEV 1 1 | grep eth0 | awk 'NR==1{printf "%.1f\n",$7}'`
  echo $netOutCmd
}
function caller {
  getCpu > /tmp/_outCpu &
  pids="$pids $!"
  getMem > /tmp/_outMem &
  pids="$pids $!"
  getDiskRead > /tmp/_outDiskRead &
  pids="$pids $!"
  getDiskWrite > /tmp/_outDiskWrite &
  pids="$pids $!"
  getNetIn > /tmp/_outNetIn &
  pids="$pids $!"
  getNetOut > /tmp/_outNetOut &
  pids="$pids $!"
  wait $pids
  cpuValue=$(</tmp/_outCpu)
  memValue=$(</tmp/_outMem)
  diskReadValue=$(</tmp/_outDiskRead)
  diskWriteValue=$(</tmp/_outDiskWrite)
  netInValue=$(</tmp/_outNetIn)
  netOutValue=$(</tmp/_outNetOut)
  dateTimeCmd=`date +'%Y-%m-%d %H:%M:%S'`
  echo  $dateTimeCmd$sep$cpuValue$sep$memValue$sep$diskReadValue$sep$diskWriteValue$sep$netInValue$sep$netOutValue
}

for run in {1..61}
do
  caller >> $logPath &
  sleep .98
done
