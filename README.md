# Instalação da autenticação JWT e controle de Moderador :robot:

Após instalação do Jitsi por completo, você seguirá os passos a seguir para alterar a forma de autenticação anônima para token através da URL e adição do plugin para controle de moderador.


### Instalação
Para realizar a instalação e configuração do JWT basta executar o script, lembre-se de gravar as chaves **ID** e **SECRET**, caso o processo de instalação falhe, você não terá que reinstalar tudo :smile: . Lembre-se de executar o script como super usuário.


[*Clique aqui para baixar o script* :computer:](/instalarJWT.sh)
**OBS**: *O Computador será reinicializado no fim do processo*

### Teste
Após a instalação, tente entrar numa sala qualquer, se for requisitado o login e senha, tudo ocorreu bem. Agora para entrar na sala você precisará gerar um token e incluir na URL como parâmetro. 

- Exemplo de token:
  ![Exemplo](/exemplo_jwt.png)
  ***OBS**: Neste Exemplo usei o site do JWT (https://jwt.io/).*


### Side Notes
#### Helpers

Para gerenciar de forma mais eficiente, deixei aqui dois scripts para habilitar e desabilitar autenticação via JWT:

- [Desabilitar JWT](/disableJWT.sh)
- [Habilitar JWT](/enableJWT.sh)
#### Problemas de instalação

  Caso haja algum problema na instalação, você pode interromper o uso da autenticação via JWT alterando os arquivos:

  - `/etc/prosody/conf.d/[nomeservidor].cfg.lua`:
    * Primeiro encontre o trecho `VirtualHost "[nome do servidor]"` e altere o valor de `authentication` de `"token"` para `"anonymous"`:
      ```lua
      ...
      VirtualHost "[nome do servidor]"
        authentication = "anonymous";
        ...
      ...
      ```

      - Dentro dele Altere os os parametros:
        - "authentication" com o valor "token" para "anonymous"

  - `/etc/jitsi/meet/[nome do servidor].config.js`:
    * Encontre o objeto `hosts` e comente o parâmetro `anonymousdomain`:
      ```javascript
      ... 
      hosts = {
        ...
        // insira duas barras para comentar
        // anonymousdomain: 'gest.[nome do servidor]',
      }
      ...
      ```

    * Abaixo de hosts encontre o parametro `enableUserRolesBasedOnToken` e também comente.

  - Por fim, reinicie o Jitsi e Nginx:
    ```shell script
    service nginx stop
    /etc/init.d/jicofo restart
    /etc/init.d/jitsi-videobridge2 restart
    /etc/init.d/prosody restart
    service nginx start
    ```  

  *A cada modificação no Jitsi, reinicie através desse script :wink:*

#### :bust_in_silhouette: Author

- GitHub: [@ZECAMINHAUM](github.com/ZECAMINHAUM)
- Twitter: [@Lucaaix](https://twitter.com/Lucaai_x)
- Instagram: [@lucaai_x](instagram.com/lucaai_x)
- E-mail: ls4388387@gmail.com