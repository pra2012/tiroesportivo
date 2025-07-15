# 🎯 Guia de Deploy - TIROESPORTIVOBRASILEIRO.COM.BR

## 🌐 Deploy no Azure Web App com Domínio Personalizado

Este guia fornece instruções completas para fazer deploy da aplicação **Tiro Esportivo Brasileiro** no Microsoft Azure Web App usando o domínio personalizado **TIROESPORTIVOBRASILEIRO.COM.BR**.

---

## 📋 Visão Geral

### 🏗️ Arquitetura
- **Frontend**: React + Vite (SPA)
- **Backend**: Flask + SQLAlchemy
- **Banco de Dados**: SQLite
- **Autenticação**: JWT
- **Domínio**: tiroesportivobrasileiro.com.br
- **SSL**: Certificado gerenciado pelo Azure
- **Deploy**: Azure Web App (Python 3.11)

### 💰 Custos Estimados
- **S1 Standard**: ~$56.94 USD/mês (necessário para domínio personalizado)
- **Certificado SSL**: Gratuito (gerenciado pelo Azure)
- **Domínio**: Custo separado (registro de domínio)

---

## 🚀 Deploy Rápido (Recomendado)

### Windows PowerShell:
```powershell
cd azure-custom-domain
.\deploy-custom-domain.ps1
```

### Linux/macOS:
```bash
cd azure-custom-domain
./deploy-custom-domain.sh
```

### Parâmetros Personalizados:
```powershell
# Windows
.\deploy-custom-domain.ps1 -ResourceGroupName "meu-rg" -WebAppName "minha-app"

# Linux/macOS
./deploy-custom-domain.sh meu-rg minha-app
```

---

## 📋 Pré-requisitos

### 1. Azure CLI
```bash
# Windows
winget install Microsoft.AzureCLI

# macOS
brew install azure-cli

# Linux
curl -sL https://aka.ms/InstallAzureCLI | sudo bash
```

### 2. Conta Azure
- Subscription ativa
- Permissões para criar recursos
- Créditos suficientes para S1 Standard

### 3. Domínio Registrado
- **tiroesportivobrasileiro.com.br** deve estar registrado
- Acesso ao painel de DNS do provedor

---

## 🌐 Configuração DNS (OBRIGATÓRIA)

### Antes do Deploy:

#### 1. Registros DNS Básicos
Configure no seu provedor de DNS:

```
Tipo: CNAME
Nome: @
Valor: [será fornecido durante o deploy]
TTL: 3600

Tipo: TXT
Nome: asuid
Valor: [será fornecido durante o deploy]
TTL: 3600
```

#### 2. Provedores Comuns:

**Registro.br:**
1. Acesse painel do Registro.br
2. DNS > Zona DNS
3. Adicione os registros

**Cloudflare:**
1. Acesse painel do Cloudflare
2. DNS > Records
3. Adicione os registros
4. Configure SSL como "Full (strict)"

**GoDaddy:**
1. Acesse painel do GoDaddy
2. DNS > Manage Zones
3. Adicione os registros

### ⏱️ Tempo de Propagação
- **Mínimo**: 15 minutos
- **Típico**: 2-4 horas
- **Máximo**: 48 horas

---

## 🔧 Deploy Manual Detalhado

### Passo 1: Preparar Ambiente
```bash
# Login no Azure
az login

# Verificar subscription
az account show
```

### Passo 2: Criar Recursos
```bash
# Criar Resource Group
az group create \
  --name "tiroesportivo-rg" \
  --location "East US"

# Criar App Service Plan (S1 para domínio personalizado)
az appservice plan create \
  --name "tiroesportivo-plan" \
  --resource-group "tiroesportivo-rg" \
  --location "East US" \
  --sku S1 \
  --is-linux

# Criar Web App
az webapp create \
  --name "tiroesportivobrasileiro" \
  --resource-group "tiroesportivo-rg" \
  --plan "tiroesportivo-plan" \
  --runtime "PYTHON:3.11"
```

### Passo 3: Configurar Aplicação
```bash
# Configurar variáveis de ambiente
az webapp config appsettings set \
  --name "tiroesportivobrasileiro" \
  --resource-group "tiroesportivo-rg" \
  --settings \
    FLASK_ENV=production \
    SECRET_KEY="tiroesportivobrasileiro-azure-secret-key-2024" \
    CUSTOM_DOMAIN="tiroesportivobrasileiro.com.br" \
    FORCE_HTTPS=true \
    SCM_DO_BUILD_DURING_DEPLOYMENT=true \
    ENABLE_ORYX_BUILD=true

# Configurar startup command
az webapp config set \
  --name "tiroesportivobrasileiro" \
  --resource-group "tiroesportivo-rg" \
  --startup-file "startup.py"
```

### Passo 4: Deploy do Código
```bash
# Deploy via ZIP
az webapp deployment source config-zip \
  --name "tiroesportivobrasileiro" \
  --resource-group "tiroesportivo-rg" \
  --src "tiroesportivobrasileiro.zip"
```

### Passo 5: Configurar Domínio Personalizado
```bash
# Obter ID de verificação
VERIFICATION_ID=$(az webapp show \
  --name "tiroesportivobrasileiro" \
  --resource-group "tiroesportivo-rg" \
  --query "customDomainVerificationId" -o tsv)

echo "Configure DNS TXT: asuid.$VERIFICATION_ID"

# Após configurar DNS, adicionar domínio
az webapp config hostname add \
  --webapp-name "tiroesportivobrasileiro" \
  --resource-group "tiroesportivo-rg" \
  --hostname "tiroesportivobrasileiro.com.br"
```

### Passo 6: Configurar SSL
```bash
# Criar certificado gerenciado
az webapp config ssl create \
  --resource-group "tiroesportivo-rg" \
  --name "tiroesportivobrasileiro" \
  --hostname "tiroesportivobrasileiro.com.br"

# Obter thumbprint
THUMBPRINT=$(az webapp config ssl list \
  --resource-group "tiroesportivo-rg" \
  --query "[?subjectName=='tiroesportivobrasileiro.com.br'].thumbprint" \
  --output tsv)

# Vincular certificado
az webapp config ssl bind \
  --resource-group "tiroesportivo-rg" \
  --name "tiroesportivobrasileiro" \
  --certificate-thumbprint $THUMBPRINT \
  --ssl-type SNI
```

---

## 🔒 Configuração SSL Avançada

### Certificado Gerenciado (Recomendado)
- **Gratuito** para domínios personalizados
- **Renovação automática**
- **Configuração via Azure CLI ou Portal**

### Verificação SSL
```bash
# Testar certificado
openssl s_client -connect tiroesportivobrasileiro.com.br:443

# Verificar redirecionamento HTTPS
curl -I http://tiroesportivobrasileiro.com.br
```

### Ferramentas de Teste
- [SSL Labs](https://www.ssllabs.com/ssltest/)
- [SSL Checker](https://www.sslshopper.com/ssl-checker.html)

---

## 📊 Monitoramento e Logs

### Logs em Tempo Real
```bash
az webapp log tail \
  --name "tiroesportivobrasileiro" \
  --resource-group "tiroesportivo-rg"
```

### Métricas da Aplicação
```bash
# CPU e Memória
az monitor metrics list \
  --resource "/subscriptions/{subscription-id}/resourceGroups/tiroesportivo-rg/providers/Microsoft.Web/sites/tiroesportivobrasileiro" \
  --metric "CpuPercentage,MemoryPercentage"
```

### Application Insights (Opcional)
```bash
# Criar Application Insights
az monitor app-insights component create \
  --app "tiroesportivo-insights" \
  --location "East US" \
  --resource-group "tiroesportivo-rg"
```

---

## 🔄 Atualizações e Manutenção

### Atualizar Aplicação
```bash
# Novo deploy
az webapp deployment source config-zip \
  --name "tiroesportivobrasileiro" \
  --resource-group "tiroesportivo-rg" \
  --src "tiroesportivobrasileiro-v2.zip"
```

### Backup do Banco
```bash
# Download do banco SQLite
az webapp deployment source download \
  --name "tiroesportivobrasileiro" \
  --resource-group "tiroesportivo-rg"
```

### Escalonamento
```bash
# Escalar para P1V2 (mais recursos)
az appservice plan update \
  --name "tiroesportivo-plan" \
  --resource-group "tiroesportivo-rg" \
  --sku P1V2
```

---

## 🚨 Solução de Problemas

### Problema: DNS não resolve
**Solução:**
1. Verificar registros DNS
2. Aguardar propagação (até 48h)
3. Usar ferramentas de verificação DNS

### Problema: Certificado SSL falha
**Solução:**
1. Verificar se domínio está acessível
2. Aguardar propagação DNS
3. Tentar criar certificado novamente

### Problema: Aplicação não carrega
**Solução:**
1. Verificar logs da aplicação
2. Verificar configurações de startup
3. Verificar variáveis de ambiente

### Comandos de Diagnóstico
```bash
# Status da aplicação
az webapp show \
  --name "tiroesportivobrasileiro" \
  --resource-group "tiroesportivo-rg" \
  --query "state"

# Verificar configurações
az webapp config show \
  --name "tiroesportivobrasileiro" \
  --resource-group "tiroesportivo-rg"

# Reiniciar aplicação
az webapp restart \
  --name "tiroesportivobrasileiro" \
  --resource-group "tiroesportivo-rg"
```

---

## 🎯 URLs e Credenciais

### URLs da Aplicação
- **Principal**: https://tiroesportivobrasileiro.com.br
- **Temporária**: https://tiroesportivobrasileiro.azurewebsites.net

### Credenciais de Acesso
- **Demo**: demo / demo123
- **Admin**: admin / admin123

### Endpoints da API
- **Health Check**: https://tiroesportivobrasileiro.com.br/api/health
- **Autenticação**: https://tiroesportivobrasileiro.com.br/api/auth/login
- **Arsenal**: https://tiroesportivobrasileiro.com.br/api/weapons
- **Ranking**: https://tiroesportivobrasileiro.com.br/api/competitions

---

## 📞 Suporte e Recursos

### Documentação Oficial
- [Azure Web Apps](https://docs.microsoft.com/azure/app-service/)
- [Custom Domains](https://docs.microsoft.com/azure/app-service/app-service-web-tutorial-custom-domain)
- [SSL Certificates](https://docs.microsoft.com/azure/app-service/configure-ssl-certificate)

### Ferramentas Úteis
- [Azure Portal](https://portal.azure.com)
- [Azure CLI Docs](https://docs.microsoft.com/cli/azure/)
- [DNS Checker](https://dnschecker.org/)

### Comandos de Referência Rápida
```bash
# Status geral
az webapp list --resource-group "tiroesportivo-rg"

# Logs
az webapp log tail --name "tiroesportivobrasileiro" --resource-group "tiroesportivo-rg"

# Configurações
az webapp config appsettings list --name "tiroesportivobrasileiro" --resource-group "tiroesportivo-rg"

# SSL
az webapp config ssl list --resource-group "tiroesportivo-rg"

# Domínios
az webapp config hostname list --webapp-name "tiroesportivobrasileiro" --resource-group "tiroesportivo-rg"
```

---

## ✅ Checklist de Deploy

### Pré-Deploy
- [ ] Azure CLI instalado
- [ ] Conta Azure configurada
- [ ] Domínio registrado
- [ ] Acesso ao DNS do domínio

### Deploy
- [ ] Resource Group criado
- [ ] App Service Plan S1 criado
- [ ] Web App criada
- [ ] Código deployado
- [ ] Aplicação funcionando na URL temporária

### Domínio Personalizado
- [ ] Registros DNS configurados
- [ ] Propagação DNS verificada
- [ ] Domínio adicionado à Web App
- [ ] Certificado SSL criado
- [ ] Certificado SSL vinculado
- [ ] HTTPS funcionando

### Verificação Final
- [ ] https://tiroesportivobrasileiro.com.br acessível
- [ ] Login funcionando
- [ ] Todas as funcionalidades testadas
- [ ] SSL Grade A no SSL Labs
- [ ] Logs sem erros

---

## 🎉 Conclusão

Após seguir este guia, sua aplicação **Tiro Esportivo Brasileiro** estará rodando no Azure Web App com domínio personalizado **TIROESPORTIVOBRASILEIRO.COM.BR**, certificado SSL e todas as funcionalidades operacionais.

**🌐 Acesse**: https://tiroesportivobrasileiro.com.br

Para suporte adicional, consulte a documentação oficial do Azure ou entre em contato com a equipe de desenvolvimento.

