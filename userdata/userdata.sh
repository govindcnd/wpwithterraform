#!/bin/bash -v
apt-get update -y
apt-get install -y nginx > /tmp/nginx.log
##echo ${aws_db_instance.default.address}  &> /tmp/dbname.txt
