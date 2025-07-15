# Script de Deploy para Azure Web App
# Shooting Sports - Controle de Tiro Esportivo

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$WebAppName,
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "East US",
    
    [Parameter(Mandatory=$false)]
    [string]$AppServicePlan = "$WebAppName-plan"
)

Write-Host "🎯 Iniciando deploy do Shooting Sports no Azure Web App" -ForegroundColor Green

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
}

Write-Host "✅ Logado como: $account" -ForegroundColor Green

# Criar Resource Group
Write-Host "📦 Criando Resource Group: $ResourceGroupName" -ForegroundColor Yellow
az group create --name $ResourceGroupName --location $Location

# Criar App Service Plan
Write-Host "🏗️ Criando App Service Plan: $AppServicePlan" -ForegroundColor Yellow
az appservice plan create `
    --name $AppServicePlan `
    --resource-group $ResourceGroupName `
    --location $Location `
    --sku B1 `
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
        SECRET_KEY="shooting-sports-azure-secret-key-2024" `
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
    --src "$currentDir\shooting-sports-azure.zip"

# Obter URL da aplicação
$appUrl = az webapp show --name $WebAppName --resource-group $ResourceGroupName --query "defaultHostName" -o tsv
$fullUrl = "https://$appUrl"

Write-Host ""
Write-Host "🎉 Deploy concluído com sucesso!" -ForegroundColor Green
Write-Host "🌐 URL da aplicação: $fullUrl" -ForegroundColor Cyan
Write-Host "👤 Credenciais de acesso:" -ForegroundColor Yellow
Write-Host "   - Demo: demo / demo123" -ForegroundColor White
Write-Host "   - Admin: admin / admin123" -ForegroundColor White
Write-Host ""
Write-Host "📊 Para monitorar a aplicação:" -ForegroundColor Yellow
Write-Host "   az webapp log tail --name $WebAppName --resource-group $ResourceGroupName" -ForegroundColor White
Write-Host ""

# Abrir aplicação no navegador
$openBrowser = Read-Host "Deseja abrir a aplicação no navegador? (y/n)"
if ($openBrowser -eq "y" -or $openBrowser -eq "Y") {
    Start-Process $fullUrl
}

