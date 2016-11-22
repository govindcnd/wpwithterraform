#!/bin/bash
terraform apply -state=$4terraform.tfstate  -var "asg_min=$1" -var "aws_access_key=$2" -var "aws_secret_key=$3" -var "env-name=$4" -var "instance_type=$5" -var "key_name=$6" | tee file1.txt
dname=$(cat file1.txt | grep 'elb_dns_name' |  awk '{print $3}')
echo $dname
echo "to be completed soon"
domain=http://${dname}
path='/wp-admin/install.php'
base_url="$domain$path"
a=4
while [ $a -ge 0 ] ; do
sts=$(curl -s -o /dev/null --globoff -w "%{http_code}" -I  "$base_url")
if [ "$sts" = "200" ]; then
    a=0
    break
  else
    sleep 5
    echo -n '.'
  fi
done
echo "ELB END POINT NAME IS $dname"
