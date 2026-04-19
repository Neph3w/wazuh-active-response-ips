#!/bin/bash

# URL do seu Webhook
WEBHOOK_URL=""

read -r INPUT
IP_ATACANTE=$(echo $INPUT | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)

# Se por algum motivo o IP vier vazio, definimos um padrão
if [ -z "$IP_ATACANTE" ]; then
    IP_ATACANTE="IP Não Identificado"
fi

read -r -d '' PAYLOAD << EOM
{
  "content": "🚨 **ALERTA DE INTRUSÃO DETECTADO**",
  "embeds": [{
    "title": "Resposta Ativa - IPS",
    "description": "O sistema de defesa ativa bloqueou uma tentativa de ataque.",
    "color": 15158528,
    "fields": [
      { "name": "IP Atacante", "value": "$IP_ATACANTE", "inline": true },
      { "name": "Ação", "value": "IP Bloqueado (DROP)", "inline": true },
      { "name": "Serviço", "value": "SSH", "inline": true }
    ],
    "footer": { "text": "Wazuh SIEM - Lab do Alexandre" }
  }]
}
EOM

curl -H "Content-Type: application/json" -X POST -d "$PAYLOAD" $WEBHOOK_URL