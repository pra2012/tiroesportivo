# 🔒 Configuração SSL para TIROESPORTIVOBRASILEIRO.COM.BR

## 📋 Opções de Certificado SSL

### 1. Certificado Gerenciado pelo Azure (Recomendado)
- **Gratuito** para domínios personalizados
- **Renovação automática**
- **Fácil configuração**

### 2. Certificado Let's Encrypt
- **Gratuito**
- **Renovação manual necessária**
- **Válido por 90 dias**

### 3. Certificado Comercial
- **Pago**
- **Maior confiabilidade**
- **Suporte estendido**

## 🚀 Configuração via Azure CLI

### 1. Adicionar Domínio Personalizado
```bash
# Adicionar domínio à Web App
az webapp config hostname add \
  --webapp-name tiroesportivobrasileiro \
  --resource-group tiroesportivo-rg \
  --hostname tiroesportivobrasileiro.com.br

# Adicionar subdomínio www
az webapp config hostname add \
  --webapp-name tiroesportivobrasileiro \
  --resource-group tiroesportivo-rg \
  --hostname www.tiroesportivobrasileiro.com.br
```

### 2. Criar Certificado Gerenciado
```bash
# Criar certificado para domínio principal
az webapp config ssl create \
  --resource-group tiroesportivo-rg \
  --name tiroesportivobrasileiro \
  --hostname tiroesportivobrasileiro.com.br

# Criar certificado para www
az webapp config ssl create \
  --resource-group tiroesportivo-rg \
  --name tiroesportivobrasileiro \
  --hostname www.tiroesportivobrasileiro.com.br
```

### 3. Vincular Certificado
```bash
# Vincular certificado ao domínio
az webapp config ssl bind \
  --resource-group tiroesportivo-rg \
  --name tiroesportivobrasileiro \
  --certificate-thumbprint [THUMBPRINT] \
  --ssl-type SNI
```

## 🌐 Configuração via Portal Azure

### Passo 1: Acessar Web App
1. Acesse [portal.azure.com](https://portal.azure.com)
2. Navegue até sua Web App
3. No menu lateral, clique em "Custom domains"

### Passo 2: Adicionar Domínio
1. Clique em "Add custom domain"
2. Digite: `tiroesportivobrasileiro.com.br`
3. Clique em "Validate"
4. Siga as instruções de verificação DNS
5. Clique em "Add custom domain"

### Passo 3: Configurar SSL
1. No menu lateral, clique em "TLS/SSL settings"
2. Vá para a aba "Private Key Certificates (.pfx)"
3. Clique em "Create App Service Managed Certificate"
4. Selecione o domínio: `tiroesportivobrasileiro.com.br`
5. Clique em "Create"

### Passo 4: Vincular Certificado
1. Vá para a aba "Bindings"
2. Clique em "Add TLS/SSL Binding"
3. Selecione o domínio: `tiroesportivobrasileiro.com.br`
4. Selecione o certificado criado
5. Escolha "SNI SSL"
6. Clique em "Add Binding"

## 🔧 Script PowerShell Automatizado

```powershell
# Configurar domínio personalizado e SSL
param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$WebAppName,
    
    [Parameter(Mandatory=$true)]
    [string]$DomainName = "tiroesportivobrasileiro.com.br"
)

Write-Host "🔒 Configurando SSL para $DomainName" -ForegroundColor Green

# Adicionar domínio personalizado
Write-Host "📋 Adicionando domínio personalizado..." -ForegroundColor Yellow
az webapp config hostname add `
    --webapp-name $WebAppName `
    --resource-group $ResourceGroupName `
    --hostname $DomainName

# Aguardar verificação DNS
Write-Host "⏳ Aguardando verificação DNS (pode levar alguns minutos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

# Criar certificado gerenciado
Write-Host "🔐 Criando certificado SSL gerenciado..." -ForegroundColor Yellow
az webapp config ssl create `
    --resource-group $ResourceGroupName `
    --name $WebAppName `
    --hostname $DomainName

# Obter thumbprint do certificado
$thumbprint = az webapp config ssl list `
    --resource-group $ResourceGroupName `
    --query "[?subjectName=='$DomainName'].thumbprint" `
    --output tsv

# Vincular certificado
Write-Host "🔗 Vinculando certificado SSL..." -ForegroundColor Yellow
az webapp config ssl bind `
    --resource-group $ResourceGroupName `
    --name $WebAppName `
    --certificate-thumbprint $thumbprint `
    --ssl-type SNI

Write-Host "✅ SSL configurado com sucesso!" -ForegroundColor Green
Write-Host "🌐 Acesse: https://$DomainName" -ForegroundColor Cyan
```

## ✅ Verificação do SSL

### Comandos de Verificação
```bash
# Verificar certificado SSL
openssl s_client -connect tiroesportivobrasileiro.com.br:443 -servername tiroesportivobrasileiro.com.br

# Verificar redirecionamento HTTPS
curl -I http://tiroesportivobrasileiro.com.br

# Testar conectividade SSL
curl -I https://tiroesportivobrasileiro.com.br
```

### Ferramentas Online
- [SSL Labs Test](https://www.ssllabs.com/ssltest/)
- [SSL Checker](https://www.sslshopper.com/ssl-checker.html)
- [DigiCert SSL Installation Checker](https://www.digicert.com/help/)

## 🔄 Renovação Automática

### Certificado Gerenciado pelo Azure
- **Renovação automática** 30 dias antes do vencimento
- **Sem ação necessária**
- **Notificações por email** em caso de problemas

### Monitoramento
```bash
# Verificar status do certificado
az webapp config ssl list \
  --resource-group tiroesportivo-rg \
  --query "[].{name:name,thumbprint:thumbprint,expirationDate:expirationDate}"
```

## 🚨 Solução de Problemas

### Erro: "Domain verification failed"
1. Verificar registros DNS
2. Aguardar propagação DNS (até 48h)
3. Tentar novamente a verificação

### Erro: "Certificate creation failed"
1. Verificar se domínio está acessível
2. Verificar configuração DNS
3. Tentar criar certificado manualmente

### Erro: "SSL binding failed"
1. Verificar se certificado foi criado
2. Verificar thumbprint do certificado
3. Tentar vincular novamente

## 📞 Suporte
- [Documentação Azure SSL](https://docs.microsoft.com/azure/app-service/configure-ssl-certificate)
- [Troubleshooting SSL](https://docs.microsoft.com/azure/app-service/troubleshoot-ssl)
- [Azure Support](https://azure.microsoft.com/support/)

