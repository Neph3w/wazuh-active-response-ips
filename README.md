# 🛡️ Wazuh Active Response Lab - Intrusion Prevention System (IPS)

## 📌 Descrição do Projeto
Este projeto demonstra a implementação de uma camada de **Defesa Ativa** utilizando o SIEM Wazuh em um ambiente Ubuntu Server. O objetivo principal foi configurar o sistema para detectar ataques de força bruta (Brute Force) via SSH e automatizar a resposta de mitigação através do firewall (IPtables).

## 🚀 Tecnologias Utilizadas
* **Wazuh Manager**: Motor de análise e correlação de eventos.
* **IPtables**: Firewall do Linux utilizado para o bloqueio de rede.
* **Ubuntu Server**: Sistema operacional da máquina alvo (Vítima).
* **XML**: Linguagem utilizada para customização das regras do Wazuh.

## ⚙️ Implementação Técnica
A configuração foi realizada no arquivo `ossec.conf` do Wazuh Manager, definindo:
1.  **Command**: Instrução que aciona o script `firewall-drop` do sistema.
2.  **Active Response**: Gatilho configurado para reagir a qualquer alerta de **Nível 10 ou superior** relacionado a falhas de autenticação.
3.  **Timeout**: Bloqueio automático temporário de 600 segundos (10 minutos) para o IP atacante.

## 📊 Prova de Conceito (PoC)
Durante o teste, o sistema identificou o IP atacante `192.168.100.9` tentando realizar múltiplos logins inválidos. 

**Resultado no Log de Resposta Ativa:**
- O Wazuh extraiu o `srcip` do evento e executou o comando `add`.
- O log confirmou a execução: `active-response/bin/firewall-drop: Ended`.

**Resultado no Firewall (IPtables):**
A regra de bloqueio foi inserida dinamicamente na chain de INPUT:
`DROP all -- 192.168.100.9 0.0.0.0/0`

---
*Projeto desenvolvido para fins de estudo em Segurança Defensiva e Operações de SOC.*
