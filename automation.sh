#!/bin/bash

myname="Uttam"
s3_bucket="upgrad-uttam"

apt update -y
dpkg -l | grep "apache2"
package_present=$?
if [ $package_present -eq 1 ]
then
	echo "Installing apache2"
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
tar -cvf /tmp/$myname-httpd-logs-$timestamp.tar /var/log/apache2/*.log

aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

