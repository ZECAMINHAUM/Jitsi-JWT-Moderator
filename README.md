# JWT installation and moderator control in Jitsi :robot:

After you install Jitsi completely, you'll follow the steps below to change the form of anonymous to token authentication through the URL and adding the plugin for moderator control.


### Installation
To perform the installation and configuration of JWT just run the script, remember to write the keys **ID** and **SECRET**, if the installation process fails, you will not have to reinstall everything :smile: . Remember to run the script as a super user.


[*Click here for download the script* :computer:](/instalarJWT.sh)
**OBS**: *Your computer will restart after finish installation*

### Testing
After installation, try to enter any room, if you are asked for the login and password, everything went well. Now to enter the room you will need to generate a token and include in the URL as a parameter. 
- Generating token:
  ![Exemplo](/exemplo_jwt.png)
  ***OBS**: In this example i use JWT website (https://jwt.io/).*


### Side Notes
#### Helpers

To manage more efficiently, I left here two scripts to enable and disable authentication via JWT:

- [disable JWT](/disableJWT.sh)
- [enable JWT](/enableJWT.sh)
#### Installation Issues

  If there is a problem with the installation, you can stop using JWT authentication by changing the files:

  - `/etc/prosody/conf.d/[nomeservidor].cfg.lua`:
    * First find the excerpt `VirtualHost "[hostname]"` and `VirtualHost "guest.[hostname]"` then find the key inside `authentication` and change the current value `"token"` to `"anonymous"`:
      ```lua
      ...
      VirtualHost "[hostname]"
        authentication = "anonymous";
        ...
      ...
      ```
      
  - `/etc/jitsi/meet/[hostname].config.js`:
    * find the object `hosts` then comment the key `anonymousdomain`:
      ```javascript
      ... 
      hosts = {
        ...
        // insert two forward bars before the code for comment
        // anonymousdomain: 'gest.[hostname]',
      }
      ...
      ```

    * Then find the key (probably in the middle of the file) `enableUserRolesBasedOnToken` and comment to.

  - Ind the end, you should restart the services:
    ```shell script
    service nginx stop
    /etc/init.d/jicofo restart
    /etc/init.d/jitsi-videobridge2 restart
    /etc/init.d/prosody restart
    service nginx start
    ```  

  *After any change in you custom Jitsi, restart it, so make a script for it. :wink:*

#### :bust_in_silhouette: Author

- GitHub: [@ZECAMINHAUM](github.com/ZECAMINHAUM)
- Twitter: [@Lucaaix](https://twitter.com/Lucaai_x)
- Instagram: [@lucaai_x](https://instagram.com/lucaai_x)
- E-mail: ls4388387@gmail.com