# Installing the best terminal multiplexer and the best interactive monitoring tool (just to make sure the data logs are correct)
apt-get install -y htop tmux
# Installing pip and python development kit
apt-get install -y python-pip python-dev
# Installing system stats tool
apt-get install -y sysstat
# Installing git client
apt-get install -y git
# Clonning repository
git clone https://github.com/luballe/linux_monitoring_log
# Change permissions over the shell script
chmod 755 linux_monitoring_log/monitoring.sh
# Run it for one minute. The log will be at the repository folder
./linux_monitoring_log/monitoring linux_monitoring_log/log.txt
