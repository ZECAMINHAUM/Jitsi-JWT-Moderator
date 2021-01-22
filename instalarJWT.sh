#!/bin/bash

clear
echo "JITSI JWT Pre -Instalação"
echo "Digite o nome do servidor:"
echo "Ex: meet.example.com"
read  -p "Address: " SERVER
if test -z "$SERVER"; then 
	echo "Server Name shouldn't be empty"
	exit 1
fi

clear
echo "Agora defina o ID:"
read ISSUERS 
if test -z "$APP_ID"; then 
	echo "APP ID is required"
	exit 1
fi

clear
echo "Por fim! Defina o SECRET:"
read AUDIENCES
if test -z "$SECRET"; then 
	echo "SECRET is required"
	exit 1
fi


# abrindo portas 
sudo ufw enable
sudo ufw allow in 22/tcp
sudo ufw allow in openssh
sudo ufw allow in 80/tcp
sudo ufw allow in 443/tcp
sudo ufw allow in 4443/tcp
sudo ufw allow in 5222/tcp
sudo ufw allow in 5347/tcp
sudo ufw allow in 10000:20000/udp

# Colocando modulo de controle de moderador na pasta de modulos
sudo cd /usr/share/jitsi-meet/prosody-plugins/
sudo wget https://hg.prosody.im/prosody-modules/raw-file/8298b06e6603/mod_pinger/mod_pinger.lua
sudo wget https://raw.githubusercontent.com/nvonahsen/jitsi-token-moderation-plugin/master/mod_token_moderation.lua
sudo cd

# Alterando os arquivos
# arquivo - /etc/prosody/prosody.cfg.lua
sudo sed -i '/admins = { }/a component_ports = { 5347 }' /etc/prosody/prosody.cfg.lua
sudo sed -i '/component_ports = { 5347 }/a component_interface = "0.0.0.0"' /etc/prosody/prosody.cfg.lua
sudo sed -i 's/c2s_require_encryption = true/c2s_require_encryption = false/g' /etc/prosody/prosody.cfg.lua

# arquivo - /etc/prosody/conf.avail/<SERVER>.cfg.lua
sudo sed -i $'/consider_bosh_secure = true;/a asap_accepted_issuers = { "jitsi", "meet" };' /etc/prosody/conf.avail/$SERVER.cfg.lua
sudo sed -i '/asap_accepted_issuers = { "jitsi", "meet" };/a asap_accepted_audiences = { "jitsi", "meet" };' /etc/prosody/conf.avail/$SERVER.cfg.lua
if grep -q  "presence_identity" /etc/prosody/conf.avail/$SERVER.cfg.lua; then
	echo "presence_identity encontrado entre os módulos"
else
	sudo sed -i $'/"muc_lobby_rooms";/a \\\t"presence_identity";' /etc/prosody/conf.avail/$SERVER.cfg.lua
fi
sudo sed -i $'/"token_verification";/a \\\t"token_moderation";' /etc/prosody/conf.avail/$SERVER.cfg.lua

sudo echo -e "\nVirtualHost 'guest.${SERVER}'" >> /etc/prosody/conf.avail/${SERVER}.cfg.lua
sudo echo "    authentication = 'token';" >> /etc/prosody/conf.avail/${SERVER}.cfg.lua
sudo echo "    app_id = '$APP_ID';" >> /etc/prosody/conf.avail/${SERVER}.cfg.lua
sudo echo "    app_secret = '$SECRET';"  >> /etc/prosody/conf.avail/${SERVER}.cfg.lua  				
sudo echo "    c2s_require_encryption = true;" >> /etc/prosody/conf.avail/${SERVER}.cfg.lua
sudo echo "    allow_empty_token = false;" >> /etc/prosody/conf.avail/${SERVER}.cfg.lua


# Arquivo /etc/jitsi/meet/$SERVER-config.js
sudo sed -i  "12s/.*/        anonymousdomain: 'guest.${SERVER}',/g" /etc/jitsi/meet/$SERVER-config.js
sudo sed -i  $'/UI/a\    enableUserRolesBasedOnToken: true,'  /etc/jitsi/meet/$SERVER-config.js

# Arquivo de configuração do jicofo
sudo sed -i "3s/=.*/=${SERVER}/g" /etc/jitsi/jicofo/config

# Arquivo de configurações do Video Bridge
sudo sed -i "s/JVB_HOST=.*/JVB_HOST=${SERVER}/g" /etc/jitsi/videobridge/config
sudo echo -e "\nAUTHBIND=yes" >> /etc/jitsi/videobridge/config

# Arquivo sip
sudo echo "org.jitsi.jicofo.auth.URL=XMPP:${SERVER}" >> /etc/jitsi/jicofo/sip-communicator.properties
sudo echo "org.jitsi.jicofo.auth.DISABLE_AUTOLOGIN=true" >> /etc/jitsi/jicofo/sip-communicator.properties

# reinstalando lua-cjson 
# (package pré instalada antes de instalar o jitsi meet tokens)
sudo apt-get install lua5.2 -y 
sudo apt-get install liblua5.2 -y
sudo apt-get install luarocks -y
sudo luarocks install basexx
sudo wget -c https://launchpad.net/~rael-gc/+archive/ubuntu/rvm/+files/libssl1.0.0_1.0.2n-1ubuntu5.3_amd64.deb
sudo wget -c https://launchpad.net/~rael-gc/+archive/ubuntu/rvm/+files/libssl1.0-dev_1.0.2n-1ubuntu5.3_amd64.deb
sudo dpkg -i libssl1.0.0_1.0.2n-1ubuntu5.3_amd64.deb
sudo dpkg -i libssl1.0-dev_1.0.2n-1ubuntu5.3_amd64.deb
sudo luarocks install luacrypto
sudo mkdir src
cd src
sudo luarocks download lua-cjson
sudo luarocks unpack lua-cjson-2.1.0.6-1.src.rock
cd lua-cjson-2.1.0.6-1/lua-cjson
sudo sed -i 's/lua_objlen/lua_rawlen/g' lua_cjson.c
sudo sed -i 's|$(PREFIX)/include|/usr/include/lua5.2|g' Makefile
sudo luarocks make
sudo luarocks install luajwtjitsi

# Instalação do jitsi-meet-tokens
cd
sudo wget -qO - https://download.jitsi.org/jitsi-key.gpg.key | sudo apt-key add -
sudo sh -c "echo 'deb https://download.jitsi.org stable/' > /etc/apt/sources.list.d/jitsi-stable.list" 
sudo apt-get -y update
sudo apt-get -y update
sudo apt-get install jitsi-meet-tokens -y


clear
echo "Pré instalação realizada com sucesso, reiniciando em 3 segundos"
sleep 3
sudo reboot now
