#!/bin/bash

clear
echo "JITSI JWT Pre -Instalação"
echo "Digite o nome do servidor:"
echo "Ex: meet.example.com"
read  -p "Address: " SERVER

clear
echo "Agora defina o issuers:"
read ISSUERS 

clear
echo "Por fim! Defina o audiences:"
read AUDIENCES

# Pré instalação das packages necessárias
clear
sudo cd
sudo aptdd-get install nginx -y
sudo wget -qO - https://download.jitsi.org/jitsi-key.gpg.key | sudo apt-key add -
sudo sh -c "echo 'deb https://download.jitsi.org stable/' > /etc/apt/sources.list.d/jitsi-stable.list"
sudo apt-get -y update
sudo apt-get install jitsi-meet-tokens -y

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
sudo sed '25s/$/component_ports = { 5347 }/g' /etc/prosody/prosody.cfg.lua
sudo sed '26s/$/component_interface = "0.0.0.0"/g' /etc/prosody/prosody.cfg.lua
sudo sed -e '103s/true/false/g' /etc/prosody/prosody.cfg.lua
sudo sed -e '212s/Include "conf.d/*.cfg.lua"/Include "conf.d/*.cfg.lua"/g' /etc/prosody/prosody.cfg.lua

# arquivo - /etc/prosody/conf.avail/<SERVER>.cfg.lua
sudo sed '24s/$/asap_accepted_issuers = { "jitsi", ${ISSUERS} }/g' /etc/prosody/conf.avail/$SERVER
sudo sed '25/$/asap_accepted_audiences = { "jitsi", ${AUDIENCES} }/g' /etc/prosody/conf.avail/$SERVER
sudo sed -e '29s/anonymous/token/g' /etc/prosody/conf.avail/$SERVER
sudo sed -e '32,33s/=.*/=giusoft' /etc/prosody/conf.avail/$SERVER
if grep -q  "presence_identity" /etc/prosody/conf.avail/$SERVER; then
	echo "presence_identity encontrado entre os módulos"
else
	sudo sed -i '' -e  $'52s/$/\\\n"presence_identity;"/g' /etc/prosody/conf.avail/$SERVER
fi

if grep -q "token_verification" /etc/prosody/conf.avail/$SERVER; then
	echo "token_verification encontrado entre os módulos de conferência"
else
	sudo sed -i '' -e  $'64s/$/\\\n"token_verification;"/g' /etc/prosody/conf.avail/$SERVER
fi
sudo sed -i '' -e  $'65s/$/\\\n"token_moderation;"/g' /etc/prosody/conf.avail/$SERVER
sudo cat "VirtualHost '${SERVER}'
    				authentication = 'token';
		    		app_id = 'example_app_id';
    				app_secret = 'example_app_secret';
    				c2s_require_encryption = true;
    				allow_empty_token = true;" >> /etc/prosody/conf.avail/$SERVER


# Arquivo /etc/jitsi/meet/$SERVER-config.js
sudo sed -i .bk  -e "12s/.*/        anonymousdomain: 'dev.giusoft.com.br',/g" /etc/jitsi/meet/$SERVER-config.js
sudo sed -i  '/UI/a   enableUserRolesBasedOnToken: true,' /etc/jitsi/meet/$SERVER-config.js

# Arquivo de configuração do jicofo
sudo sed -e '3s/=.*/${SERVER}/g' /etc/jitsi/jicofo/config

# Arquivo de configurações do Video Bridge
sudo sed -e '7s/=.*/${SERVER}/g' /etc/jitsi/videobridge/config
sudo cat "AUTHBIND=yes" >> /etc/jitsi/videobridge/config

# Arquivo sip
sudo cat "org.jitsi.jicofo.auth.URL=XMPP:DOMINIO" >> /etc/jitsi/jicofo/sip-communicator.properties
sudo cat "org.jitsi.jicofo.auth.DISABLE_AUTOLOGIN=true" >> /etc/jitsi/jicofo/sip-communicator.properties

# reinstalando lua-cjson 
# (package pré instalada com erro, por isso a reinstalação)
sudo luarocks remove lua-cjson
sudo luarocks install lua-cjson 2.1.0-1

clear
echo "Pré instalação realizada com sucesso, reiniciando em 3 segundos"
sleep 3
sudo reboot now
