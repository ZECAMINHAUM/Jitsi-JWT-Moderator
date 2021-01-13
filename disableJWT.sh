#!/bin/bash

echo "Disable JWT script"
read -p 'Server name (ex: meet.example.com): ' server

dir="/etc/jitsi/meet/${server}-config.js"

if test -z "$server" || test ! -f "$dir"; then
	echo "Server Name shouldn't be empty or invalid"
	exit 1
fi

userRolesLine="$(sudo awk '/enableUserRoles/{ print NR; exit }' $dir)"
anonymousDLine="$(sudo awk '/anonymousdomain/{ print NR; exit }' $dir)"

sudo sed -i '' -e '29s/=.*/="anonymous"/g' /etc/prosody/conf.avail/${server}.cfg.lua 2> /dev/null
sed -i -e  "${userRolesLine}s/^/\/\//g" /etc/jitsi/meet/${server}-config.js
sed -i -e  "${anonymousDLine}s/^/\/\//g" /etc/jitsi/meet/${server}-config.js

restartJitsi

echo "JWT successfully disabled"

