#!/bin/bash
#strict mode
set -euo pipefail
set -x
IFS=$'\n\t'


#get the directory of cloned repo
PROJ_HOME=$(pwd)

#install variable
IP_FOR_NODE=10.1.4.171


#imports
source functions.sh

#if not root exit
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#update packages
apt-get update

#remove existing docker
apt-get remove docker docker-engine docker.io containerd runc

#install required stuff to add key
apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

#add apt key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

#add fingerprint
apt-key fingerprint 0EBFCD88

#add docker repo
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

#update apt-repo
apt-get update
#install docker
apt-get install docker-ce docker-ce-cli containerd.io

#make the directory for node exporter
mkdir node_exporter

#go into directory of no exporter
cd node_exporter

#download the latest node-exporter version
get_latest_node_exporter()

#extract node exporter
tar -xvf node_exporter*

#enter the extracted directory
cd node_exporter*

#copy the executable
cp node_exporter /usr/bin/

#return the the source directory
cd $PROJ_HOME

#copy the service file into the services directory
cp node_exporter.service /etc/systemd/system/

#replace with the ip for the node
sed -i "s/replace_me/$IP_FOR_NODE/" /etc/systemd/system/node_expoerter.service

#reload the services
systemctl daemon-reload

#enable the node exporter service
systemctl enable node_exporter.service

#add user server to group docker
adduser server docker

#clone git repos
cd $HOME

#make git dir
mkdir git

#enter git dir
cd git

#clone all the repos in repos.txt
while read $PROJ_HOME/repos.txt; do
    git clone $read
done

#return to the project home
cd $PROJ_HOME