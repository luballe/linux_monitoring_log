#!/bin/bash

#Crontab:
#* * * * * /home/<username>/monitoring.sh /home/<username>/log.txt

#logPath="/home/<username>/log.txt"

# Get log path from the first parameter
logPath=$1
# List of PIDs of the spawned processes
pids=""
# Separator of log result
sep=","
# % CPU Usage= 100% - %Idle
function getCpu {
  cpuCmd=`sar 1 1 | awk 'NR==4{printf "%.1f\n",100-$9}'`
  echo $cpuCmd
}
# % of Memory usage
function getMem {
  memCmd=`sar -r 1 1 | awk 'NR==4{printf "%.1f\n",$5}'`
  echo $memCmd
}
# Consolidated disk reads (kbps)
function getDiskRead {
  diskReadCmd=`sar -b 1 1 | awk 'NR==4{printf "%.1f\n",$4}'`
  echo $diskReadCmd
}
# Consolidated disk writes (kbps)
function getDiskWrite {
  diskWriteCmd=`sar -b 1 1 | awk 'NR==4{printf "%.1f\n",$5}'`
  echo $diskWriteCmd
}
# Consolidated networking in (kbps)
function getNetIn {
  netInCmd=`sar -n DEV 1 1 | grep eth0 | awk 'NR==1{printf "%.1f\n",$6}'`
  echo $netInCmd
}
# Consolidated networking out (kbps)
function getNetOut {
  netOutCmd=`sar -n DEV 1 1 | grep eth0 | awk 'NR==1{printf "%.1f\n",$7}'`
  echo $netOutCmd
}
# Call performance variables all at once. In asynchronous fashion. The result of each function will reside in a specific file.
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
  # Wait that the last function ends before printing
  wait $pids
  # Get values from the result files
  cpuValue=$(</tmp/_outCpu)
  memValue=$(</tmp/_outMem)
  diskReadValue=$(</tmp/_outDiskRead)
  diskWriteValue=$(</tmp/_outDiskWrite)
  netInValue=$(</tmp/_outNetIn)
  netOutValue=$(</tmp/_outNetOut)
  # Set date time
  dateTimeCmd=`date +'%Y-%m-%d %H:%M:%S'`
  # Printing all variables.
  echo  $dateTimeCmd$sep$cpuValue$sep$memValue$sep$diskReadValue$sep$diskWriteValue$sep$netInValue$sep$netOutValue
}
# Run for a bit longer than a minute (This is done in order to not overlap writes over the result files)
for run in {1..61}
do
  # Run in background. Each run has to last less than a second.
  caller >> $logPath &
  sleep .98
done
