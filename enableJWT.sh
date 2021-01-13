#!/bin/bash

echo "Enable JWT script"
read -p "ServerName (ex: meet.example.com): " server

dir="/etc/jitsi/meet/${server}-config.js"

if test -z "$server" || test ! -f "$dir"; then 
	echo "Server Name shouldn't be empty or invalid"
	exit 1
fi
sudo sed -i '' -e '29s/=.*/="token"/g' /etc/prosody/conf.avail/${server}.cfg.lua 2> /dev/null
userRolesLine="$(sudo awk '/enableUserRoles/{ print NR; exit }' $dir)"
anonymousDLine="$(sudo awk '/anonymousdomain/{ print NR; exit }' $dir)"

sudo sed -i "${userRolesLine}s/\/\///g" ${dir}
sudo sed -i "${anonymousDLine}s/\/\///g" ${dir}

service nginx stop
/etc/init.d/jicofo restart
/etc/init.d/jitsi-videobridge2 restart
/etc/init.d/prosody restart
service nginx start

echo "JWT successfully enabled"
