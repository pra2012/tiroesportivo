# 🌐 TIRO ESPORTIVO BRASILEIRO - GUIA COMPLETO AZURE CLOUD SHELL

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Pré-requisitos](#pré-requisitos)
3. [Configuração Inicial](#configuração-inicial)
4. [Deploy Passo a Passo](#deploy-passo-a-passo)
5. [Configuração Azure DevOps](#configuração-azure-devops)
6. [Monitoramento e Manutenção](#monitoramento-e-manutenção)
7. [Troubleshooting](#troubleshooting)
8. [Referências](#referências)

---

## 🎯 Visão Geral

Este guia fornece instruções completas para deploy da aplicação **Tiro Esportivo Brasileiro** usando exclusivamente o **Azure Cloud Shell**. A solução inclui:

### ✅ **Recursos Implementados**
- **Backend**: Flask + SQLite + JWT Authentication
- **Frontend**: React + Vite + Design Responsivo
- **Infraestrutura**: Azure Web App + DNS Zone + Application Insights
- **CI/CD**: Azure DevOps Pipelines automatizados
- **Domínio**: tiroesportivobrasileiro.com.br
- **SSL**: Certificados gerenciados automaticamente
- **Monitoramento**: Application Insights + Alertas

### 🏗️ **Arquitetura da Solução**
```
Azure Cloud Shell
├── Scripts de Automação
│   ├── setup-cloudshell.sh      # Configuração inicial
│   ├── upload-project.sh        # Deploy da aplicação
│   └── configure-pipelines.sh   # Configuração DevOps
├── Infraestrutura Azure
│   ├── Resource Group: tiroesportivo
│   ├── DNS Zone: tiroesportivobrasileiro.com.br
│   ├── Web Apps: Produção + Desenvolvimento
│   └── Application Insights
└── Azure DevOps
    ├── Repositório Git
    ├── Pipelines CI/CD
    └── Environments (Dev/Prod)
```

### 💰 **Custo Estimado**
- **Azure DNS**: ~$3/mês
- **Web App S1**: ~$57/mês
- **Application Insights**: ~$5/mês
- **Total**: ~$65/mês

---

## 🔧 Pré-requisitos

### ✅ **Conta Azure**
- Subscription ativa: `130706ec-b9d5-4554-8be1-ef855c2cf41a`
- Permissões de Contributor no Resource Group
- Acesso ao Azure Portal

### ✅ **Domínio**
- Domínio registrado: `tiroesportivobrasileiro.com.br`
- Acesso ao painel de DNS do registrador
- Capacidade de alterar Name Servers

### ✅ **Azure DevOps**
- Organização Azure DevOps criada
- Personal Access Token (PAT) com permissões:
  - Code (read/write)
  - Build (read/write/execute)
  - Release (read/write/execute)
  - Service Connections (read/write)

### ✅ **Arquivos do Projeto**
- Código fonte da aplicação
- Scripts do Cloud Shell
- Configurações de deployment

---

## 🚀 Configuração Inicial

### **1. Acessar Azure Cloud Shell**

1. Acesse [portal.azure.com](https://portal.azure.com)
2. Clique no ícone do Cloud Shell (>_) no topo
3. Selecione **Bash** como ambiente
4. Aguarde a inicialização do ambiente

### **2. Verificar Configuração**

```bash
# Verificar subscription ativa
az account show

# Verificar se é a subscription correta
az account show --query id -o tsv
# Deve retornar: 130706ec-b9d5-4554-8be1-ef855c2cf41a

# Se necessário, trocar subscription
az account set --subscription "130706ec-b9d5-4554-8be1-ef855c2cf41a"
```

### **3. Preparar Ambiente de Trabalho**

```bash
# Criar diretório do projeto
mkdir -p ~/tiroesportivo
cd ~/tiroesportivo

# Verificar ferramentas disponíveis
az --version
python --version
node --version
git --version
```

### **4. Upload dos Arquivos**

**Opção A: Via Git Clone (Recomendado)**
```bash
# Se o projeto já está em um repositório
git clone https://github.com/seu-usuario/tiroesportivo.git .
```

**Opção B: Via Upload Manual**
1. Use o botão "Upload/Download files" no Cloud Shell
2. Faça upload do arquivo ZIP do projeto
3. Extraia os arquivos:
```bash
unzip tiroesportivo.zip
```

**Opção C: Via Azure Files**
```bash
# Montar Azure Files (se configurado)
# Os arquivos estarão disponíveis automaticamente
```

---

## 🎯 Deploy Passo a Passo

### **Passo 1: Configuração da Infraestrutura**

Execute o script de setup inicial:

```bash
cd ~/tiroesportivo
chmod +x cloud-shell/*.sh
./cloud-shell/setup-cloudshell.sh
```

**O que este script faz:**
- ✅ Configura Azure CLI com subscription correta
- ✅ Cria Resource Group `tiroesportivo`
- ✅ Cria DNS Zone `tiroesportivobrasileiro.com.br`
- ✅ Cria App Service Plan (S1 Standard)
- ✅ Cria Web Apps (Produção + Desenvolvimento)
- ✅ Configura Application Insights
- ✅ Cria Service Principal para DevOps
- ✅ Configura registros DNS básicos

**Saída esperada:**
```
============================================
  CONFIGURAÇÃO DNS NECESSÁRIA
============================================
Configure estes Name Servers no seu registrador:
  - ns1-01.azure-dns.com.
  - ns2-01.azure-dns.net.
  - ns3-01.azure-dns.org.
  - ns4-01.azure-dns.info.
============================================
```

### **Passo 2: Configurar DNS no Registrador**

1. Acesse o painel do seu registrador de domínio
2. Localize as configurações de DNS/Name Servers
3. Substitua os Name Servers atuais pelos fornecidos pelo script
4. Aguarde propagação DNS (pode levar até 48 horas)

**Verificar propagação:**
```bash
# Verificar se DNS está propagando
nslookup tiroesportivobrasileiro.com.br
dig tiroesportivobrasileiro.com.br
```

### **Passo 3: Deploy da Aplicação**

Execute o script de upload e deploy:

```bash
./cloud-shell/upload-project.sh
```

**O que este script faz:**
- ✅ Prepara arquivos para deploy
- ✅ Faz build do frontend React
- ✅ Configura variáveis de ambiente
- ✅ Deploy para ambiente de desenvolvimento
- ✅ Deploy para ambiente de produção
- ✅ Inicializa banco de dados
- ✅ Testa aplicações deployadas

**URLs geradas:**
- **Desenvolvimento**: https://tiroesportivobrasileiro-dev.azurewebsites.net
- **Produção**: https://tiroesportivobrasileiro.azurewebsites.net
- **Domínio personalizado**: https://tiroesportivobrasileiro.com.br (após propagação DNS)

### **Passo 4: Testar Aplicação**

```bash
# Testar ambiente de desenvolvimento
curl -I https://tiroesportivobrasileiro-dev.azurewebsites.net

# Testar ambiente de produção
curl -I https://tiroesportivobrasileiro.azurewebsites.net

# Testar domínio personalizado (após propagação DNS)
curl -I https://tiroesportivobrasileiro.com.br
```

**Credenciais de acesso:**
- **Usuário Demo**: `demo` / `demo123`
- **Administrador**: `admin` / `admin123`

---

## 🔄 Configuração Azure DevOps

### **Passo 1: Preparar Azure DevOps**

1. Acesse [dev.azure.com](https://dev.azure.com)
2. Crie uma organização (se não existir)
3. Gere um Personal Access Token:
   - Vá em User Settings → Personal Access Tokens
   - Clique em "New Token"
   - Selecione escopo: Full access
   - Copie o token gerado

### **Passo 2: Configurar Pipelines**

Execute o script de configuração:

```bash
./cloud-shell/configure-pipelines.sh
```

**Informações solicitadas:**
- **Organização Azure DevOps**: nome da sua organização
- **Personal Access Token**: token gerado no passo anterior

**O que este script faz:**
- ✅ Instala Azure DevOps CLI extension
- ✅ Cria projeto `TiroEsportivoBrasileiro`
- ✅ Cria repositório Git
- ✅ Configura Git local e faz push
- ✅ Cria pipelines CI/CD
- ✅ Configura variáveis de pipeline

### **Passo 3: Configurar Service Connection**

**⚠️ Este passo deve ser feito manualmente no portal Azure DevOps:**

1. Acesse: `https://dev.azure.com/SUA-ORG/TiroEsportivoBrasileiro/_settings/adminservices`
2. Clique em "New service connection"
3. Selecione "Azure Resource Manager"
4. Selecione "Service principal (automatic)"
5. Configure:
   - **Subscription**: `130706ec-b9d5-4554-8be1-ef855c2cf41a`
   - **Resource Group**: `tiroesportivo`
   - **Service connection name**: `Azure-Connection`
6. Clique em "Save"

### **Passo 4: Executar Pipelines**

1. Acesse: `https://dev.azure.com/SUA-ORG/TiroEsportivoBrasileiro/_build`
2. Execute o pipeline `TiroEsportivo-Infrastructure` primeiro
3. Após sucesso, execute `TiroEsportivo-CI-CD`

**Fluxo de Deploy Automatizado:**
```
Commit → Build → Test → Deploy Dev → Deploy Prod → Health Check
```

---


## 📊 Monitoramento e Manutenção

### **Application Insights**

**Acessar métricas:**
```bash
# Via Azure CLI
az monitor app-insights component show \
  --app tiroesportivo-insights \
  --resource-group tiroesportivo

# Obter chave de instrumentação
az monitor app-insights component show \
  --app tiroesportivo-insights \
  --resource-group tiroesportivo \
  --query instrumentationKey -o tsv
```

**Portal de monitoramento:**
- Acesse: [portal.azure.com](https://portal.azure.com)
- Navegue: Resource Groups → tiroesportivo → tiroesportivo-insights
- Visualize: Métricas, Logs, Alertas

### **Logs da Aplicação**

**Visualizar logs em tempo real:**
```bash
# Logs da aplicação de produção
az webapp log tail \
  --resource-group tiroesportivo \
  --name tiroesportivobrasileiro

# Logs da aplicação de desenvolvimento
az webapp log tail \
  --resource-group tiroesportivo \
  --name tiroesportivobrasileiro-dev
```

**Configurar logging:**
```bash
# Habilitar logging detalhado
az webapp log config \
  --resource-group tiroesportivo \
  --name tiroesportivobrasileiro \
  --application-logging true \
  --level verbose

# Download de logs
az webapp log download \
  --resource-group tiroesportivo \
  --name tiroesportivobrasileiro \
  --log-file logs.zip
```

### **Métricas de Performance**

**Comandos úteis para monitoramento:**
```bash
# Status das aplicações
az webapp show \
  --resource-group tiroesportivo \
  --name tiroesportivobrasileiro \
  --query "{name:name, state:state, defaultHostName:defaultHostName}"

# Uso de recursos
az monitor metrics list \
  --resource "/subscriptions/130706ec-b9d5-4554-8be1-ef855c2cf41a/resourceGroups/tiroesportivo/providers/Microsoft.Web/sites/tiroesportivobrasileiro" \
  --metric "CpuPercentage,MemoryPercentage,HttpResponseTime"

# Verificar saúde da aplicação
curl -I https://tiroesportivobrasileiro.com.br/health || echo "Health check endpoint não configurado"
```

### **Backup e Recuperação**

**Backup do banco de dados:**
```bash
# Conectar via SSH e fazer backup
az webapp ssh \
  --resource-group tiroesportivo \
  --name tiroesportivobrasileiro \
  --command "cd /home/site/wwwroot && cp tiroesportivo.db backup_$(date +%Y%m%d).db"

# Download do backup
az webapp log download \
  --resource-group tiroesportivo \
  --name tiroesportivobrasileiro \
  --log-file backup.zip
```

**Backup da aplicação completa:**
```bash
# Criar backup via Azure
az webapp config backup create \
  --resource-group tiroesportivo \
  --webapp-name tiroesportivobrasileiro \
  --backup-name "backup-$(date +%Y%m%d)" \
  --storage-account-url "https://STORAGE_ACCOUNT.blob.core.windows.net/backups"
```

### **Alertas e Notificações**

**Configurar alertas via CLI:**
```bash
# Alerta de CPU alta
az monitor metrics alert create \
  --name "tiroesportivo-high-cpu" \
  --resource-group tiroesportivo \
  --scopes "/subscriptions/130706ec-b9d5-4554-8be1-ef855c2cf41a/resourceGroups/tiroesportivo/providers/Microsoft.Web/sites/tiroesportivobrasileiro" \
  --condition "avg Percentage CPU > 80" \
  --description "CPU usage above 80%" \
  --evaluation-frequency 5m \
  --window-size 15m \
  --severity 2

# Alerta de erros HTTP
az monitor metrics alert create \
  --name "tiroesportivo-http-errors" \
  --resource-group tiroesportivo \
  --scopes "/subscriptions/130706ec-b9d5-4554-8be1-ef855c2cf41a/resourceGroups/tiroesportivo/providers/Microsoft.Web/sites/tiroesportivobrasileiro" \
  --condition "total Http5xx > 10" \
  --description "High number of HTTP 5xx errors" \
  --evaluation-frequency 5m \
  --window-size 15m \
  --severity 1
```

### **Manutenção Preventiva**

**Script de manutenção semanal:**
```bash
#!/bin/bash
# maintenance.sh - Execute semanalmente

echo "🔧 Iniciando manutenção preventiva..."

# 1. Verificar status das aplicações
az webapp list --resource-group tiroesportivo --query "[].{name:name, state:state}"

# 2. Verificar uso de recursos
az monitor metrics list \
  --resource "/subscriptions/130706ec-b9d5-4554-8be1-ef855c2cf41a/resourceGroups/tiroesportivo/providers/Microsoft.Web/sites/tiroesportivobrasileiro" \
  --metric "CpuPercentage" \
  --start-time $(date -d '7 days ago' -u +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ)

# 3. Limpar logs antigos
az webapp log config \
  --resource-group tiroesportivo \
  --name tiroesportivobrasileiro \
  --application-logging true

# 4. Verificar certificados SSL
az webapp config ssl list \
  --resource-group tiroesportivo

# 5. Testar endpoints
curl -f https://tiroesportivobrasileiro.com.br || echo "❌ Produção com problemas"
curl -f https://tiroesportivobrasileiro-dev.azurewebsites.net || echo "❌ Desenvolvimento com problemas"

echo "✅ Manutenção concluída"
```

### **Atualizações da Aplicação**

**Deploy manual via Cloud Shell:**
```bash
# 1. Atualizar código
git pull origin main

# 2. Rebuild e deploy
./cloud-shell/upload-project.sh

# 3. Verificar deploy
curl -I https://tiroesportivobrasileiro.com.br
```

**Deploy via Azure DevOps:**
```bash
# Trigger pipeline manualmente
az pipelines run \
  --name "TiroEsportivo-CI-CD" \
  --organization https://dev.azure.com/SUA-ORG \
  --project TiroEsportivoBrasileiro
```

---

## 🔧 Troubleshooting

### **Problemas Comuns**

#### **1. DNS não está propagando**

**Sintomas:**
- Domínio não resolve
- Erro "This site can't be reached"

**Soluções:**
```bash
# Verificar Name Servers
dig NS tiroesportivobrasileiro.com.br

# Verificar propagação global
# Use: https://www.whatsmydns.net/

# Forçar atualização DNS local
sudo systemctl flush-dns  # Linux
ipconfig /flushdns         # Windows
```

#### **2. Aplicação não inicia**

**Sintomas:**
- HTTP 500 errors
- "Application Error" na página

**Diagnóstico:**
```bash
# Verificar logs
az webapp log tail \
  --resource-group tiroesportivo \
  --name tiroesportivobrasileiro

# Verificar configurações
az webapp config show \
  --resource-group tiroesportivo \
  --name tiroesportivobrasileiro

# Testar startup command
az webapp ssh \
  --resource-group tiroesportivo \
  --name tiroesportivobrasileiro \
  --command "cd /home/site/wwwroot && python startup.py"
```

**Soluções:**
```bash
# Reconfigurar startup command
az webapp config set \
  --resource-group tiroesportivo \
  --name tiroesportivobrasileiro \
  --startup-file "startup.py"

# Reiniciar aplicação
az webapp restart \
  --resource-group tiroesportivo \
  --name tiroesportivobrasileiro
```

#### **3. SSL Certificate Issues**

**Sintomas:**
- Certificado inválido
- Warnings de segurança

**Soluções:**
```bash
# Verificar certificados
az webapp config ssl list \
  --resource-group tiroesportivo

# Reconfigurar SSL
az webapp config ssl bind \
  --certificate-type SNI \
  --name tiroesportivobrasileiro \
  --resource-group tiroesportivo \
  --ssl-type SNI

# Verificar domínio personalizado
az webapp config hostname list \
  --webapp-name tiroesportivobrasileiro \
  --resource-group tiroesportivo
```

#### **4. Pipeline Failures**

**Sintomas:**
- Build failures
- Deploy errors

**Diagnóstico:**
```bash
# Verificar último build
az pipelines build list \
  --organization https://dev.azure.com/SUA-ORG \
  --project TiroEsportivoBrasileiro \
  --top 1

# Ver logs detalhados
az pipelines build show \
  --organization https://dev.azure.com/SUA-ORG \
  --project TiroEsportivoBrasileiro \
  --id BUILD_ID
```

#### **5. Database Issues**

**Sintomas:**
- Login não funciona
- Dados não persistem

**Soluções:**
```bash
# Reinicializar banco
az webapp ssh \
  --resource-group tiroesportivo \
  --name tiroesportivobrasileiro \
  --command "cd /home/site/wwwroot && python populate_db.py"

# Verificar arquivo de banco
az webapp ssh \
  --resource-group tiroesportivo \
  --name tiroesportivobrasileiro \
  --command "ls -la /home/site/wwwroot/*.db"
```

### **Comandos de Emergência**

**Rollback rápido:**
```bash
# Parar aplicação
az webapp stop \
  --resource-group tiroesportivo \
  --name tiroesportivobrasileiro

# Deploy de versão anterior (se disponível)
az webapp deployment source config-zip \
  --resource-group tiroesportivo \
  --name tiroesportivobrasileiro \
  --src backup-version.zip

# Reiniciar aplicação
az webapp start \
  --resource-group tiroesportivo \
  --name tiroesportivobrasileiro
```

**Reset completo:**
```bash
# ⚠️ CUIDADO: Isso apagará todos os dados!

# Parar aplicações
az webapp stop --resource-group tiroesportivo --name tiroesportivobrasileiro
az webapp stop --resource-group tiroesportivo --name tiroesportivobrasileiro-dev

# Recriar aplicações
az webapp delete --resource-group tiroesportivo --name tiroesportivobrasileiro
az webapp delete --resource-group tiroesportivo --name tiroesportivobrasileiro-dev

# Executar setup novamente
./cloud-shell/setup-cloudshell.sh
./cloud-shell/upload-project.sh
```

### **Contatos de Suporte**

**Azure Support:**
- Portal: [portal.azure.com](https://portal.azure.com) → Help + Support
- Documentação: [docs.microsoft.com/azure](https://docs.microsoft.com/azure)

**Azure DevOps Support:**
- Portal: [dev.azure.com](https://dev.azure.com) → Help
- Documentação: [docs.microsoft.com/azure/devops](https://docs.microsoft.com/azure/devops)

---

## 📚 Referências

### **Documentação Oficial**

- [Azure Cloud Shell](https://docs.microsoft.com/azure/cloud-shell/)
- [Azure Web Apps](https://docs.microsoft.com/azure/app-service/)
- [Azure DNS](https://docs.microsoft.com/azure/dns/)
- [Azure DevOps](https://docs.microsoft.com/azure/devops/)
- [Application Insights](https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview)

### **Tutoriais Úteis**

- [Deploy Flask to Azure](https://docs.microsoft.com/azure/app-service/quickstart-python)
- [Custom Domain Setup](https://docs.microsoft.com/azure/app-service/app-service-web-tutorial-custom-domain)
- [SSL Certificates](https://docs.microsoft.com/azure/app-service/configure-ssl-certificate)
- [Azure DevOps Pipelines](https://docs.microsoft.com/azure/devops/pipelines/)

### **Ferramentas Complementares**

- [Azure CLI Reference](https://docs.microsoft.com/cli/azure/)
- [Azure Resource Manager Templates](https://docs.microsoft.com/azure/azure-resource-manager/templates/)
- [Azure Monitor](https://docs.microsoft.com/azure/azure-monitor/)
- [Azure Key Vault](https://docs.microsoft.com/azure/key-vault/)

### **Comunidade e Suporte**

- [Azure Community](https://techcommunity.microsoft.com/t5/azure/ct-p/Azure)
- [Stack Overflow - Azure](https://stackoverflow.com/questions/tagged/azure)
- [GitHub - Azure Samples](https://github.com/Azure-Samples)
- [Azure Updates](https://azure.microsoft.com/updates/)

---

## 🎯 Conclusão

Este guia fornece uma solução completa para deploy da aplicação **Tiro Esportivo Brasileiro** usando Azure Cloud Shell. A arquitetura implementada oferece:

### ✅ **Benefícios Alcançados**
- **Simplicidade**: Deploy em 3 comandos
- **Automação**: CI/CD completo com Azure DevOps
- **Escalabilidade**: Infraestrutura Azure robusta
- **Monitoramento**: Application Insights integrado
- **Segurança**: SSL automático e autenticação JWT
- **Manutenibilidade**: Scripts de manutenção automatizados

### 🚀 **Próximos Passos**
1. Execute os scripts na ordem apresentada
2. Configure DNS no seu registrador
3. Monitore a aplicação via Application Insights
4. Implemente melhorias baseadas no feedback dos usuários

### 📞 **Suporte**
Para dúvidas ou problemas, consulte a seção de Troubleshooting ou entre em contato com o suporte Azure.

**🌐 URL Final**: https://tiroesportivobrasileiro.com.br  
**👤 Credenciais**: demo/demo123 | admin/admin123

---

*Guia criado para Azure Cloud Shell - Versão 1.0*  
*Última atualização: $(date)*

