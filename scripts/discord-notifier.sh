#!/bin/bash

WEBHOOK_URL=" "
ABUSEIPDB_API_KEY=" "
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

read -r -t 5 INPUT || INPUT=""

IP_ATACANTE=$(echo "$INPUT" | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
if [ -z "$IP_ATACANTE" ]; then
    IP_ATACANTE="IP Não Identificado"
fi

ABUSE_JSON=$(python3 "$SCRIPT_DIR/abuseipdb-check.py" "$IP_ATACANTE" "$ABUSEIPDB_API_KEY" 2>/dev/null)

if echo "$ABUSE_JSON" | grep -q '"error": null'; then
    SCORE=$(echo         "$ABUSE_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['score'])")
    COUNTRY=$(echo       "$ABUSE_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['country'])")
    ISP=$(echo           "$ABUSE_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['isp'])")
    REPORTS=$(echo       "$ABUSE_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['total_reports'])")
    LAST_SEEN=$(echo     "$ABUSE_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['last_reported'])")
    IS_TOR=$(echo        "$ABUSE_JSON" | python3 -c "import sys,json; d=json.load(sys.stdin); print('Sim' if d['is_tor'] else 'Não')")

    if [ "$SCORE" -ge 80 ]; then
        COLOR=15158528   # Vermelho
        RISK="🔴 Alto"
    elif [ "$SCORE" -ge 40 ]; then
        COLOR=16776960   # Amarelo
        RISK="🟡 Médio"
    else
        COLOR=3066993    # Verde
        RISK="🟢 Baixo"
    fi

    REPUTATION_FIELDS=$(cat <<EOF
      { "name": "Score de Reputação", "value": "$SCORE/100", "inline": true },
      { "name": "Risco", "value": "$RISK", "inline": true },
      { "name": "País", "value": "$COUNTRY", "inline": true },
      { "name": "ISP / ASN", "value": "$ISP", "inline": true },
      { "name": "Total de Reports", "value": "$REPORTS", "inline": true },
      { "name": "Último Report", "value": "$LAST_SEEN", "inline": true },
      { "name": "Nó TOR", "value": "$IS_TOR", "inline": true },
EOF
)
else
    COLOR=15158528
    REPUTATION_FIELDS='{ "name": "Reputação", "value": "AbuseIPDB indisponível", "inline": true },'
fi

read -r -d '' PAYLOAD << EOM
{
  "content": "🚨 **ALERTA DE INTRUSÃO DETECTADO**",
  "embeds": [{
    "title": "Resposta Ativa — IPS",
    "description": "O sistema de defesa ativa bloqueou uma tentativa de ataque.",
    "color": $COLOR,
    "fields": [
      { "name": "IP Atacante", "value": "$IP_ATACANTE", "inline": true },
      { "name": "Ação", "value": "IP Bloqueado (DROP)", "inline": true },
      { "name": "Serviço", "value": "SSH", "inline": true },
      $REPUTATION_FIELDS
      { "name": "Fonte", "value": "[AbuseIPDB](https://www.abuseipdb.com/check/$IP_ATACANTE)", "inline": false }
    ],
    "footer": { "text": "Wazuh SIEM — Lab do Alexandre" }
  }]
}
EOM

curl -s -H "Content-Type: application/json" -X POST -d "$PAYLOAD" "$WEBHOOK_URL"
