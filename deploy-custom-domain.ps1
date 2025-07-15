# Script de Deploy para Azure Web App com Domínio Personalizado
# Tiro Esportivo Brasileiro - TIROESPORTIVOBRASILEIRO.COM.BR

param(
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "tiroesportivo-rg",
    
    [Parameter(Mandatory=$false)]
    [string]$WebAppName = "tiroesportivobrasileiro",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "East US",
    
    [Parameter(Mandatory=$false)]
    [string]$AppServicePlan = "tiroesportivo-plan",
    
    [Parameter(Mandatory=$false)]
    [string]$CustomDomain = "tiroesportivobrasileiro.com.br",
    
    [Parameter(Mandatory=$false)]
    [string]$Sku = "S1"
)

Write-Host "🎯 Deploy - Tiro Esportivo Brasileiro" -ForegroundColor Green
Write-Host "🌐 Domínio: $CustomDomain" -ForegroundColor Cyan
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

# Criar App Service Plan (S1 para suportar domínio personalizado)
Write-Host "🏗️ Criando App Service Plan: $AppServicePlan (SKU: $Sku)" -ForegroundColor Yellow
az appservice plan create `
    --name $AppServicePlan `
    --resource-group $ResourceGroupName `
    --location $Location `
    --sku $Sku `
    --is-linux

# Criar Web App
Write-Host "🌐 Criando Web App: $WebAppName" -ForegroundColor Yellow
az webapp create `
    --name $WebAppName `
    --resource-group $ResourceGroupName `
    --plan $AppServicePlan `
    --runtime "PYTHON:3.11"

# Configurar variáveis de ambiente
Write-Host "⚙️ Configurando variáveis de ambiente..." -ForegroundColor Yellow
az webapp config appsettings set `
    --name $WebAppName `
    --resource-group $ResourceGroupName `
    --settings `
        FLASK_ENV=production `
        SECRET_KEY="tiroesportivobrasileiro-azure-secret-key-2024" `
        CUSTOM_DOMAIN=$CustomDomain `
        FORCE_HTTPS=true `
        SCM_DO_BUILD_DURING_DEPLOYMENT=true `
        ENABLE_ORYX_BUILD=true `
        WEBSITES_ENABLE_APP_SERVICE_STORAGE=true

# Configurar startup command
Write-Host "🚀 Configurando comando de inicialização..." -ForegroundColor Yellow
az webapp config set `
    --name $WebAppName `
    --resource-group $ResourceGroupName `
    --startup-file "startup.py"

# Deploy do código
Write-Host "📤 Fazendo deploy do código..." -ForegroundColor Yellow
$currentDir = Get-Location
az webapp deployment source config-zip `
    --name $WebAppName `
    --resource-group $ResourceGroupName `
    --src "$currentDir\tiroesportivobrasileiro.zip"

# Aguardar deploy
Write-Host "⏳ Aguardando conclusão do deploy..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Obter URL temporária
$tempUrl = az webapp show --name $WebAppName --resource-group $ResourceGroupName --query "defaultHostName" -o tsv
$tempFullUrl = "https://$tempUrl"

Write-Host ""
Write-Host "✅ Deploy inicial concluído!" -ForegroundColor Green
Write-Host "🌐 URL temporária: $tempFullUrl" -ForegroundColor Cyan

# Configurar domínio personalizado
Write-Host ""
Write-Host "🔧 Configurando domínio personalizado..." -ForegroundColor Yellow

# Obter ID de verificação de domínio
$verificationId = az webapp show `
    --name $WebAppName `
    --resource-group $ResourceGroupName `
    --query "customDomainVerificationId" -o tsv

Write-Host "📋 ID de Verificação de Domínio: $verificationId" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  IMPORTANTE: Configure os seguintes registros DNS:" -ForegroundColor Red
Write-Host "   Tipo: TXT" -ForegroundColor White
Write-Host "   Nome: asuid" -ForegroundColor White
Write-Host "   Valor: $verificationId" -ForegroundColor White
Write-Host ""
Write-Host "   Tipo: CNAME" -ForegroundColor White
Write-Host "   Nome: @" -ForegroundColor White
Write-Host "   Valor: $tempUrl" -ForegroundColor White
Write-Host ""

# Perguntar se DNS foi configurado
$dnsConfigured = Read-Host "DNS foi configurado? Aguarde a propagação e digite 'y' para continuar (y/n)"

if ($dnsConfigured -eq "y" -or $dnsConfigured -eq "Y") {
    Write-Host "🌐 Adicionando domínio personalizado..." -ForegroundColor Yellow
    
    try {
        # Adicionar domínio personalizado
        az webapp config hostname add `
            --webapp-name $WebAppName `
            --resource-group $ResourceGroupName `
            --hostname $CustomDomain
        
        Write-Host "✅ Domínio personalizado adicionado!" -ForegroundColor Green
        
        # Configurar SSL
        Write-Host "🔒 Configurando certificado SSL..." -ForegroundColor Yellow
        
        # Aguardar um pouco para o domínio ser reconhecido
        Start-Sleep -Seconds 30
        
        # Criar certificado gerenciado
        az webapp config ssl create `
            --resource-group $ResourceGroupName `
            --name $WebAppName `
            --hostname $CustomDomain
        
        # Obter thumbprint do certificado
        $thumbprint = az webapp config ssl list `
            --resource-group $ResourceGroupName `
            --query "[?subjectName=='$CustomDomain'].thumbprint" `
            --output tsv
        
        if ($thumbprint) {
            # Vincular certificado
            az webapp config ssl bind `
                --resource-group $ResourceGroupName `
                --name $WebAppName `
                --certificate-thumbprint $thumbprint `
                --ssl-type SNI
            
            Write-Host "✅ SSL configurado com sucesso!" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Certificado SSL não pôde ser criado automaticamente." -ForegroundColor Yellow
            Write-Host "   Configure manualmente no Portal Azure." -ForegroundColor White
        }
        
    } catch {
        Write-Host "⚠️  Erro ao configurar domínio personalizado: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "   Configure manualmente no Portal Azure." -ForegroundColor White
    }
}

# URLs finais
$customUrl = "https://$CustomDomain"

Write-Host ""
Write-Host "🎉 Deploy concluído com sucesso!" -ForegroundColor Green
Write-Host "🌐 URL principal: $customUrl" -ForegroundColor Cyan
Write-Host "🌐 URL temporária: $tempFullUrl" -ForegroundColor Cyan
Write-Host ""
Write-Host "👤 Credenciais de acesso:" -ForegroundColor Yellow
Write-Host "   - Demo: demo / demo123" -ForegroundColor White
Write-Host "   - Admin: admin / admin123" -ForegroundColor White
Write-Host ""
Write-Host "📊 Para monitorar a aplicação:" -ForegroundColor Yellow
Write-Host "   az webapp log tail --name $WebAppName --resource-group $ResourceGroupName" -ForegroundColor White
Write-Host ""
Write-Host "🔧 Para configurar SSL manualmente:" -ForegroundColor Yellow
Write-Host "   1. Acesse portal.azure.com" -ForegroundColor White
Write-Host "   2. Vá para sua Web App > TLS/SSL settings" -ForegroundColor White
Write-Host "   3. Crie um certificado gerenciado" -ForegroundColor White
Write-Host "   4. Vincule ao domínio $CustomDomain" -ForegroundColor White
Write-Host ""

# Abrir aplicação no navegador
$openBrowser = Read-Host "Deseja abrir a aplicação no navegador? (y/n)"
if ($openBrowser -eq "y" -or $openBrowser -eq "Y") {
    if ($dnsConfigured -eq "y" -or $dnsConfigured -eq "Y") {
        Start-Process $customUrl
    } else {
        Start-Process $tempFullUrl
    }
}

