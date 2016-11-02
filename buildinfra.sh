#!/bin/bash
terraform apply -state=$4terraform.tfstate  -var "asg_min=$1" -var "aws_access_key=$2" -var "aws_secret_key=$3" -var "env-name=$4" -var "instance_type=$5" -var "key_name=$6"

