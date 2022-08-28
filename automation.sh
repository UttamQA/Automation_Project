#!/bin/bash

myname="Uttam"
s3_bucket="upgrad-uttam"

apt update -y
dpkg -l | grep "apache2"
package_present=$?
if [ $package_present -ne 0 ]
then
	yes Y | apt install apache2 
fi

systemctl status apache2
apache2_status=$?
if [ $apache2_status -ne 0 ]
then
	systemctl start apache2
fi

systemctl is-enabled apache2
apache2_is_enabled=$?
if [ $apache2_is_enabled -ne 0 ]
then
        systemctl enable apache2
fi

timestamp=$(date '+%d%m%Y-%H%M%S')
archived_log_file="/tmp/$myname-httpd-logs-$timestamp.tar"
tar -cvf $archived_log_file /var/log/apache2/*.log

aws s3 \
cp $archived_log_file \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

bookeeping_file="/var/www/html/inventory.html"
archived_log_size=`du -sh $archived_log_file | awk '{print $1}'`

if [ ! -e $bookeeping_file ]
then
	touch $bookeeping_file
	echo -e "Log Type\tTime Created\t\tType\t\tSize">>$bookeeping_file
	echo -e "httpd-logs\t$timestamp\t\ttar\t\t$archived_log_size">>$bookeeping_file
else
	echo -e "httpd-logs\t$timestamp\t\ttar\t\t$archived_log_size">>$bookeeping_file
fi

cronjob_file="/etc/cron.d/automation"
if [ ! -e $cronjob_file ]
then
	touch $cronjob_file
	echo "0 0 * * * root /root/Automation_Project/automation.sh">>$cronjob_file
fi
