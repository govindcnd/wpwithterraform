#!/bin/bash
terraform apply -state=$4terraform.tfstate  -var "asg_min=$1" -var "aws_access_key=$2" -var "aws_secret_key=$3" -var "env-name=$4" -var "instance_type=$5" -var "key_name=$6"
echo " now the infrastructure is deployed  once the instance starts listening on ELB try accessing the dns name as shown in the output ( usually takes 2-5 minutes for ansible to build the image and instance to be listening on ELB"
