
# Configuração de Servidor Web com Monitoramento

**Objetivo:** Desenvolver e testar habilidades em Linux e automação de processos atráves da configuração de um ambiente de servidor web monitorado.

## 1. Etapas:
- __Configurar o ambiente__
    - Baixar e instalar o VirtualBox
    - Baixar e instalar o Linux Mint
- __Configurar o Servidor Web__
    - Instalar o NGINX
    - Criar uma página HTML para exibir
- __Monitoramento e Notificações__
    - Criar scripts em Bash
    - Criar logs das verificações
    - Enviar uma notificação via Discord em caso de indisponibilidade
    - Configurar um cron para rodar o automaticamente o script a cada 1 minuto
- __Testes e Documentação__
    - Verificar se o site está acessível no navegador
    - Parar o NGINX e verificar se as notificações estão sendo enviadas corretamente
    - Criar uma documentação no Github explicando o projeto e como configurar passo a passo

## 2. Passo a Passo:
### 2.1. Instalar o VirtualBox
- Faça o download do VirtualBox através do [link](https://www.virtualbox.org/wiki/Downloads).
    
    Após o download faça a instalação do programa.
### 2.2. Instalar o Linux Mint
- Faça o download do Linux Mint através do [link](https://linuxmint.com/edition.php?id=319)

    Após o download, abra o VirtualBox, dê um nome para sua máquina virtual e selecione a ISO do Linux Mint
    ![VirtualBox exemplo](https://github.com/user-attachments/assets/4c073ba6-f6be-4aff-8345-7f1bfba7f594)


**Para continuar com os próximos passos é necessário estarmos como usuário _root_**

Para logar como usuário _root_, digite o comando:

``` sudo -i ```

Após isso, bastar digitar a sua senha

![Login root exemplo](https://github.com/user-attachments/assets/ec91e2ea-9164-4f34-86f4-898a6b3cc901)

### 2.3. Instalar o NGINX
- No terminal do Mint, digite o comando:

    ``` apt install nginx ```

    Podemos verificar se o NGINX está ativo com o seguinte comando: 

    ``` systemctl status ngix.service ```

    E também indo até **localhost:80** no navegador, você deverá ver a seguinte página:

    ![Nginx padrão](https://github.com/user-attachments/assets/12a605a2-b075-4c83-aa0f-77243a69694c)

### 2.4. Criar uma página HTML
- No terminal, digite os comandos:

    ```cd /var/www/html/ ; nano index.html```

- Copie e cole o seguinte código:
    ```
    <!doctype html>
    <html lang="pt-BR">
    <head>
      <meta charset="utf-8" />
      <title>Projeto Nginx</title>
    </head>
    <body style="text-align: center;">
      <h1>Projeto: Servidor Web com Monitoramento</h1>
      <p>Este projeto implementa um servidor web (NGINX) com monitoramento para verificar o estado do serviço e notificar quando houver indisponibilidade.</p>
    </body>
    </html>
    ```
    **Aperte _Ctrl + O_ para salvar e _Ctrl + X_ para sair**

    ![HTML exemplo](https://github.com/user-attachments/assets/16b60246-d7ee-4a75-99b3-a64106cd4a0c)

### 2.5. Criar scripts em Bash
- Para criar o script de monitoramento e logs, digite os comandos:

    ``` cd / ; nano service_monitoring.sh ```

- Copie e cole o seguinte código:

    ```
    #!/bin/bash

    SERVICE="nginx"
    LOG_DIR="/var/log/${SERVICE}_logs"
    LOG_FILE="${LOG_DIR}/${SERVICE}.log"

    mkdir -p "$LOG_DIR"

    DATE=$(date '+%d/%m/%Y %H:%M:%S')

    if systemctl is-active "$SERVICE"; then
        echo "[$DATE]: O serviço $SERVICE está ativo!" >> "$LOG_FILE"
    else
        echo "[$DATE]: O serviço $SERVICE está desativado." >> "$LOG_FILE"
        /bin/bash /discord_alert.sh
        systemctl restart nginx
    fi
    ```

    **Aperte _Ctrl + O_ para salvar e _Ctrl + X_ para sair**

    Após isso devemos tornar o arquivo executável com o seguinte comando:

    ```chmod +x service_monitoring.sh ```

- Criando um _Webhook_ no _Discord_ para enviar alertas:

    Para criar um _Webhook_ acesse o servidor do _Discord_, selecione o canal de texto em que você deseja receber as notificações e siga os seguintes passos:

    - Canal > Editar canal > Integrações > Webhooks

    ![Discord configurações](https://github.com/user-attachments/assets/e42e1442-6a55-4656-928f-a4a7b2414549)

    Clique em _Novo webhook_, edite o nome e a imagem como preferir, e clique para copiar a URL

    ![Webhook exemplo](https://github.com/user-attachments/assets/e071721e-dead-437f-afe6-c2f350c094ff)

- Para criar o script de alertas no _Discord_, digite o comando:

    ``` nano discord_alert.sh ```

- Copie e cole o seguinte código:

    ``` 
        #!/bin/bash

        curl -H "Content-Type: application/json" -X POST \
            -d '{
          "username": "Nginx Status",
          "embeds": [
            {
              "title": "NGINX",
              "description": "O NGINX está desativado.",
              "color": 15158332,
              "footer": {"text": " '"$(date '+%d/%m/%Y %H:%M:%S')"'  "}
            }
          ]
        }' "$WEBHOOK_URL"
    ```

    **Aperte _Ctrl + O_ para salvar e _Ctrl + X_ para sair**

    Também devemos tornar este arquivo um executável com o comando:

    ``` chmod +x discord_alert.sh ```


    **_$WEBHOOK_URL_ é uma variável de ambiente que criaremos ao configurar o cron**

### 2.6. Configurar um cron para rodar o script automaticamente a cada 1 minuto

Por padrão o cron já vem instalado, mas caso não esteja, digite o seguinte comando:

``` apt install cron ```

- Para abrir o arquivo do crontab, digite o comando:

    ``` nano /etc/crontab ```

- Adicione as seguintes linhas:

    ``` WEBHOOK_URL=SUA_URL ```

    **Substitua _SUA_URL_ pela URL do Webhook criado anteriormente**

    ``` */1 * * * * root /bin/bash /service_monitoring.sh ```

![Exemplo do Crontab](https://github.com/user-attachments/assets/fefc346e-5249-4ee2-9155-a39934ad6646)

### 2.7. Verificar se o site está acessível via navegador

- Abra o navegador de sua preferência e digite **localhost:80** ou o IP da sua máquina, você pode verificar o IP através do comando:

    ``` ip a ```

### 2.8. Parar o NGINX e verificar se as notificações estão sendo enviadas corretamente

- No terminal, digite o seguinte comando:

    ``` systemctl stop nginx ```

    Após um minuto você deverá recebar uma notificação como a da imagem da seção abaixo

### 3. Resultado

- Notificação no canal do _Discord_:

    ![Notificação Discord](https://github.com/user-attachments/assets/339f8dfc-bffa-4248-a9d1-e9ec004d2d31)

- Também podemos ver o arquivo com os logs com o seguinte comando:

    ``` cat /var/log/nginx_logs/nginx.log ```

    ![Logs exemplo](https://github.com/user-attachments/assets/861400f8-452b-444c-a017-eeb4daa7f034)

    O serviço estava ativo, foi desativado manualmente e logo em seguida foi automaticamente reiniciado pelo script feito na seção 2.5


