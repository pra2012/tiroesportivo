# Script de Deploy Completo com Azure DNS
# Tiro Esportivo Brasileiro - TIROESPORTIVOBRASILEIRO.COM.BR

param(
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "tiroesportivo",
    
    [Parameter(Mandatory=$false)]
    [string]$WebAppName = "tiroesportivobrasileiro",
    
    [Parameter(Mandatory=$false)]
    [string]$DomainName = "tiroesportivobrasileiro.com.br",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "East US",
    
    [Parameter(Mandatory=$false)]
    [string]$AppServicePlan = "tiroesportivo-plan",
    
    [Parameter(Mandatory=$false)]
    [string]$Sku = "S1"
)

Write-Host "🎯 Deploy Completo - Tiro Esportivo Brasileiro" -ForegroundColor Green
Write-Host "🌐 Domínio: $DomainName (Azure DNS)" -ForegroundColor Cyan
Write-Host ""

# Verificar se Azure CLI está instalado
try {
    az --version | Out-Null
    Write-Host "✅ Azure CLI encontrado" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI não encontrado. Instale em: https://docs.microsoft.com/cli/azure/install-azure-cli" -ForegroundColor Red
    exit 1
}

# Login no Azure (se necessário)
Write-Host "🔐 Verificando login no Azure..." -ForegroundColor Yellow
$account = az account show --query "user.name" -o tsv 2>$null
if (-not $account) {
    Write-Host "Fazendo login no Azure..." -ForegroundColor Yellow
    az login
    $account = az account show --query "user.name" -o tsv
}

Write-Host "✅ Logado como: $account" -ForegroundColor Green

# Criar Resource Group
Write-Host "📦 Criando Resource Group: $ResourceGroupName" -ForegroundColor Yellow
az group create --name $ResourceGroupName --location $Location

# ========================================
# PARTE 1: CONFIGURAR AZURE DNS
# ========================================

Write-Host ""
Write-Host "🌐 PARTE 1: Configurando Azure DNS Zone..." -ForegroundColor Magenta

# Verificar se DNS Zone já existe
$dnsZoneExists = az network dns zone show --resource-group $ResourceGroupName --name $DomainName --query "name" -o tsv 2>$null
if (-not $dnsZoneExists) {
    Write-Host "   Criando DNS Zone para $DomainName..." -ForegroundColor Yellow
    az network dns zone create --resource-group $ResourceGroupName --name $DomainName
    
    # Criar registros DNS básicos
    Write-Host "   Criando registros DNS básicos..." -ForegroundColor Yellow
    
    # Registro CNAME para www
    az network dns record-set cname create --resource-group $ResourceGroupName --zone-name $DomainName --name "www" --ttl 3600
    az network dns record-set cname set-record --resource-group $ResourceGroupName --zone-name $DomainName --record-set-name "www" --cname $DomainName
    
    # Registro TXT para verificação
    az network dns record-set txt create --resource-group $ResourceGroupName --zone-name $DomainName --name "@" --ttl 3600
    az network dns record-set txt add-record --resource-group $ResourceGroupName --zone-name $DomainName --record-set-name "@" --value "v=spf1 -all"
    
    Write-Host "✅ DNS Zone criada com sucesso!" -ForegroundColor Green
} else {
    Write-Host "✅ DNS Zone já existe" -ForegroundColor Green
}

# Obter Name Servers
$nameServers = az network dns zone show --resource-group $ResourceGroupName --name $DomainName --query "nameServers" -o tsv

Write-Host ""
Write-Host "📋 Name Servers do Azure DNS:" -ForegroundColor Cyan
foreach ($ns in $nameServers) {
    Write-Host "   $ns" -ForegroundColor White
}

# ========================================
# PARTE 2: CRIAR WEB APP
# ========================================

Write-Host ""
Write-Host "🌐 PARTE 2: Criando Web App..." -ForegroundColor Magenta

# Criar App Service Plan
Write-Host "   Criando App Service Plan: $AppServicePlan (SKU: $Sku)" -ForegroundColor Yellow
az appservice plan create `
    --name $AppServicePlan `
    --resource-group $ResourceGroupName `
    --location $Location `
    --sku $Sku `
    --is-linux

# Criar Web App
Write-Host "   Criando Web App: $WebAppName" -ForegroundColor Yellow
az webapp create `
    --name $WebAppName `
    --resource-group $ResourceGroupName `
    --plan $AppServicePlan `
    --runtime "PYTHON:3.11"

# Configurar variáveis de ambiente
Write-Host "   Configurando variáveis de ambiente..." -ForegroundColor Yellow
az webapp config appsettings set `
    --name $WebAppName `
    --resource-group $ResourceGroupName `
    --settings `
        FLASK_ENV=production `
        SECRET_KEY="tiroesportivobrasileiro-azure-dns-secret-key-2024" `
        CUSTOM_DOMAIN=$DomainName `
        AZURE_DNS_ENABLED=true `
        FORCE_HTTPS=true `
        SCM_DO_BUILD_DURING_DEPLOYMENT=true `
        ENABLE_ORYX_BUILD=true `
        WEBSITES_ENABLE_APP_SERVICE_STORAGE=true

# Configurar startup command
Write-Host "   Configurando comando de inicialização..." -ForegroundColor Yellow
az webapp config set `
    --name $WebAppName `
    --resource-group $ResourceGroupName `
    --startup-file "startup.py"

# Deploy do código
Write-Host "   Fazendo deploy do código..." -ForegroundColor Yellow
$currentDir = Get-Location
az webapp deployment source config-zip `
    --name $WebAppName `
    --resource-group $ResourceGroupName `
    --src "$currentDir\tiroesportivobrasileiro-azure-dns.zip"

# Aguardar deploy
Write-Host "   Aguardando conclusão do deploy..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Obter URL temporária e IP da Web App
$tempUrl = az webapp show --name $WebAppName --resource-group $ResourceGroupName --query "defaultHostName" -o tsv
$webAppIps = az webapp show --name $WebAppName --resource-group $ResourceGroupName --query "outboundIpAddresses" -o tsv

Write-Host "✅ Web App criada com sucesso!" -ForegroundColor Green
Write-Host "   URL temporária: https://$tempUrl" -ForegroundColor Cyan

# ========================================
# PARTE 3: CONFIGURAR DNS RECORDS
# ========================================

Write-Host ""
Write-Host "🌐 PARTE 3: Configurando registros DNS..." -ForegroundColor Magenta

# Obter IP da Web App para registro A
Write-Host "   Obtendo informações da Web App..." -ForegroundColor Yellow
$webAppInfo = az webapp show --name $WebAppName --resource-group $ResourceGroupName --query "{defaultHostName:defaultHostName,hostNames:hostNames}" -o json | ConvertFrom-Json

# Criar registro CNAME para root domain apontando para Web App
Write-Host "   Criando registro CNAME para domínio raiz..." -ForegroundColor Yellow
$cnameExists = az network dns record-set cname show --resource-group $ResourceGroupName --zone-name $DomainName --name "@" --query "name" -o tsv 2>$null
if (-not $cnameExists) {
    az network dns record-set cname create --resource-group $ResourceGroupName --zone-name $DomainName --name "@" --ttl 3600
}
az network dns record-set cname set-record --resource-group $ResourceGroupName --zone-name $DomainName --record-set-name "@" --cname $tempUrl

# Criar registro TXT para verificação de domínio personalizado
Write-Host "   Criando registro TXT para verificação..." -ForegroundColor Yellow
$verificationId = az webapp show --name $WebAppName --resource-group $ResourceGroupName --query "customDomainVerificationId" -o tsv

$txtExists = az network dns record-set txt show --resource-group $ResourceGroupName --zone-name $DomainName --name "asuid" --query "name" -o tsv 2>$null
if (-not $txtExists) {
    az network dns record-set txt create --resource-group $ResourceGroupName --zone-name $DomainName --name "asuid" --ttl 3600
}
az network dns record-set txt add-record --resource-group $ResourceGroupName --zone-name $DomainName --record-set-name "asuid" --value $verificationId

Write-Host "✅ Registros DNS configurados!" -ForegroundColor Green

# ========================================
# PARTE 4: CONFIGURAR DOMÍNIO PERSONALIZADO
# ========================================

Write-Host ""
Write-Host "🌐 PARTE 4: Configurando domínio personalizado..." -ForegroundColor Magenta

# Aguardar propagação DNS
Write-Host "   Aguardando propagação DNS (60 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

# Adicionar domínio personalizado
Write-Host "   Adicionando domínio personalizado..." -ForegroundColor Yellow
try {
    az webapp config hostname add `
        --webapp-name $WebAppName `
        --resource-group $ResourceGroupName `
        --hostname $DomainName
    
    Write-Host "✅ Domínio personalizado adicionado!" -ForegroundColor Green
    
    # Adicionar www também
    az webapp config hostname add `
        --webapp-name $WebAppName `
        --resource-group $ResourceGroupName `
        --hostname "www.$DomainName"
    
    Write-Host "✅ Subdomínio www adicionado!" -ForegroundColor Green
    
} catch {
    Write-Host "⚠️  Erro ao adicionar domínio personalizado. Verifique a propagação DNS." -ForegroundColor Yellow
    Write-Host "   Você pode configurar manualmente no Portal Azure após a propagação." -ForegroundColor White
}

# ========================================
# PARTE 5: CONFIGURAR SSL
# ========================================

Write-Host ""
Write-Host "🔒 PARTE 5: Configurando certificado SSL..." -ForegroundColor Magenta

# Aguardar um pouco mais para o domínio ser reconhecido
Start-Sleep -Seconds 30

try {
    # Criar certificado gerenciado para domínio principal
    Write-Host "   Criando certificado SSL para $DomainName..." -ForegroundColor Yellow
    az webapp config ssl create `
        --resource-group $ResourceGroupName `
        --name $WebAppName `
        --hostname $DomainName
    
    # Criar certificado para www
    Write-Host "   Criando certificado SSL para www.$DomainName..." -ForegroundColor Yellow
    az webapp config ssl create `
        --resource-group $ResourceGroupName `
        --name $WebAppName `
        --hostname "www.$DomainName"
    
    # Obter thumbprints dos certificados
    $thumbprint1 = az webapp config ssl list --resource-group $ResourceGroupName --query "[?subjectName=='$DomainName'].thumbprint" --output tsv
    $thumbprint2 = az webapp config ssl list --resource-group $ResourceGroupName --query "[?subjectName=='www.$DomainName'].thumbprint" --output tsv
    
    # Vincular certificados
    if ($thumbprint1) {
        Write-Host "   Vinculando certificado SSL para $DomainName..." -ForegroundColor Yellow
        az webapp config ssl bind `
            --resource-group $ResourceGroupName `
            --name $WebAppName `
            --certificate-thumbprint $thumbprint1 `
            --ssl-type SNI
    }
    
    if ($thumbprint2) {
        Write-Host "   Vinculando certificado SSL para www.$DomainName..." -ForegroundColor Yellow
        az webapp config ssl bind `
            --resource-group $ResourceGroupName `
            --name $WebAppName `
            --certificate-thumbprint $thumbprint2 `
            --ssl-type SNI
    }
    
    Write-Host "✅ SSL configurado com sucesso!" -ForegroundColor Green
    
} catch {
    Write-Host "⚠️  Certificado SSL não pôde ser criado automaticamente." -ForegroundColor Yellow
    Write-Host "   Configure manualmente no Portal Azure após a propagação DNS." -ForegroundColor White
}

# ========================================
# RESUMO FINAL
# ========================================

Write-Host ""
Write-Host "🎉 Deploy Completo Finalizado!" -ForegroundColor Green
Write-Host ""

# URLs finais
$customUrl = "https://$DomainName"
$wwwUrl = "https://www.$DomainName"
$tempFullUrl = "https://$tempUrl"

Write-Host "🌐 URLs da aplicação:" -ForegroundColor Yellow
Write-Host "   Principal: $customUrl" -ForegroundColor Cyan
Write-Host "   WWW: $wwwUrl" -ForegroundColor Cyan
Write-Host "   Temporária: $tempFullUrl" -ForegroundColor Gray
Write-Host ""

Write-Host "👤 Credenciais de acesso:" -ForegroundColor Yellow
Write-Host "   - Demo: demo / demo123" -ForegroundColor White
Write-Host "   - Admin: admin / admin123" -ForegroundColor White
Write-Host ""

Write-Host "🌐 Name Servers (configure no registrador):" -ForegroundColor Yellow
foreach ($ns in $nameServers) {
    Write-Host "   $ns" -ForegroundColor Cyan
}
Write-Host ""

Write-Host "📊 Recursos criados:" -ForegroundColor Yellow
Write-Host "   - Resource Group: $ResourceGroupName" -ForegroundColor White
Write-Host "   - DNS Zone: $DomainName" -ForegroundColor White
Write-Host "   - App Service Plan: $AppServicePlan" -ForegroundColor White
Write-Host "   - Web App: $WebAppName" -ForegroundColor White
Write-Host "   - SSL Certificates: Gerenciados pelo Azure" -ForegroundColor White
Write-Host ""

Write-Host "🔧 Comandos úteis:" -ForegroundColor Yellow
Write-Host "   # Ver logs:" -ForegroundColor Gray
Write-Host "   az webapp log tail --name $WebAppName --resource-group $ResourceGroupName" -ForegroundColor White
Write-Host ""
Write-Host "   # Verificar DNS:" -ForegroundColor Gray
Write-Host "   nslookup $DomainName" -ForegroundColor White
Write-Host ""
Write-Host "   # Verificar SSL:" -ForegroundColor Gray
Write-Host "   curl -I $customUrl" -ForegroundColor White
Write-Host ""

# Salvar informações de deploy
$deployInfo = @{
    ResourceGroup = $ResourceGroupName
    WebAppName = $WebAppName
    DomainName = $DomainName
    NameServers = $nameServers
    URLs = @{
        Primary = $customUrl
        WWW = $wwwUrl
        Temporary = $tempFullUrl
    }
    DeployedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}

$deployInfo | ConvertTo-Json -Depth 3 | Out-File -FilePath "deploy-info.json" -Encoding UTF8
Write-Host "💾 Informações de deploy salvas em: deploy-info.json" -ForegroundColor Cyan

Write-Host ""
Write-Host "✅ Tiro Esportivo Brasileiro está no ar com Azure DNS!" -ForegroundColor Green

