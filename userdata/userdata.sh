#!/bin/bash -v
apt-get update -y
apt-get install -y ansible > /tmp/userdata.log
apt-get install -y git > /tmp/git.log
cd /tmp
git clone https://github.com/govindcnd/wpwithterraform.git  > /tmp/getcode.log
ansible-playbook /tmp/wpwithterraform/ansible/deploy.yml  -i /tmp/wpwithterraform/ansible/hosts --connection=local  > /tmp/ansible.log
