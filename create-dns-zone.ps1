# Script para Configurar Azure DNS Zone
# Tiro Esportivo Brasileiro - TIROESPORTIVOBRASILEIRO.COM.BR

param(
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "tiroesportivo",
    
    [Parameter(Mandatory=$false)]
    [string]$DomainName = "tiroesportivobrasileiro.com.br",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "East US"
)

Write-Host "🌐 Configurando Azure DNS Zone para $DomainName" -ForegroundColor Green
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

# Criar Resource Group se não existir
Write-Host "📦 Verificando/Criando Resource Group: $ResourceGroupName" -ForegroundColor Yellow
$rgExists = az group exists --name $ResourceGroupName
if ($rgExists -eq "false") {
    az group create --name $ResourceGroupName --location $Location
    Write-Host "✅ Resource Group criado" -ForegroundColor Green
} else {
    Write-Host "✅ Resource Group já existe" -ForegroundColor Green
}

# Criar DNS Zone
Write-Host "🌐 Criando DNS Zone para $DomainName..." -ForegroundColor Yellow
az network dns zone create `
    --resource-group $ResourceGroupName `
    --name $DomainName

Write-Host "✅ DNS Zone criada com sucesso!" -ForegroundColor Green

# Obter Name Servers
Write-Host "📋 Obtendo Name Servers..." -ForegroundColor Yellow
$nameServers = az network dns zone show `
    --resource-group $ResourceGroupName `
    --name $DomainName `
    --query "nameServers" -o tsv

Write-Host ""
Write-Host "🎯 IMPORTANTE: Configure os seguintes Name Servers no seu registrador de domínio:" -ForegroundColor Red
Write-Host ""
foreach ($ns in $nameServers) {
    Write-Host "   $ns" -ForegroundColor Cyan
}
Write-Host ""

# Criar registros DNS básicos
Write-Host "📝 Criando registros DNS básicos..." -ForegroundColor Yellow

# Registro A para root domain (será atualizado depois com IP da Web App)
Write-Host "   Criando registro A temporário..." -ForegroundColor Gray
az network dns record-set a create `
    --resource-group $ResourceGroupName `
    --zone-name $DomainName `
    --name "@" `
    --ttl 3600

# Registro CNAME para www
Write-Host "   Criando registro CNAME para www..." -ForegroundColor Gray
az network dns record-set cname create `
    --resource-group $ResourceGroupName `
    --zone-name $DomainName `
    --name "www" `
    --ttl 3600

az network dns record-set cname set-record `
    --resource-group $ResourceGroupName `
    --zone-name $DomainName `
    --record-set-name "www" `
    --cname $DomainName

# Registros MX básicos (opcional)
Write-Host "   Criando registros MX básicos..." -ForegroundColor Gray
az network dns record-set mx create `
    --resource-group $ResourceGroupName `
    --zone-name $DomainName `
    --name "@" `
    --ttl 3600

az network dns record-set mx add-record `
    --resource-group $ResourceGroupName `
    --zone-name $DomainName `
    --record-set-name "@" `
    --exchange "mail.$DomainName" `
    --preference 10

# Registro TXT para verificação
Write-Host "   Criando registro TXT para verificação..." -ForegroundColor Gray
az network dns record-set txt create `
    --resource-group $ResourceGroupName `
    --zone-name $DomainName `
    --name "@" `
    --ttl 3600

az network dns record-set txt add-record `
    --resource-group $ResourceGroupName `
    --zone-name $DomainName `
    --record-set-name "@" `
    --value "v=spf1 -all"

Write-Host "✅ Registros DNS básicos criados!" -ForegroundColor Green

# Mostrar resumo
Write-Host ""
Write-Host "📊 Resumo da Configuração:" -ForegroundColor Yellow
Write-Host "   Resource Group: $ResourceGroupName" -ForegroundColor White
Write-Host "   DNS Zone: $DomainName" -ForegroundColor White
Write-Host "   Location: $Location" -ForegroundColor White
Write-Host ""

# Verificar zona DNS
Write-Host "🔍 Verificando configuração da zona DNS..." -ForegroundColor Yellow
az network dns zone show `
    --resource-group $ResourceGroupName `
    --name $DomainName `
    --query "{name:name,resourceGroup:resourceGroup,nameServers:nameServers}" `
    --output table

Write-Host ""
Write-Host "🎉 Azure DNS Zone configurada com sucesso!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Próximos passos:" -ForegroundColor Yellow
Write-Host "   1. Configure os Name Servers no seu registrador de domínio" -ForegroundColor White
Write-Host "   2. Aguarde a propagação DNS (até 48 horas)" -ForegroundColor White
Write-Host "   3. Execute o script de deploy da Web App" -ForegroundColor White
Write-Host ""

# Salvar informações em arquivo
$dnsInfo = @{
    ResourceGroup = $ResourceGroupName
    DomainName = $DomainName
    NameServers = $nameServers
    CreatedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}

$dnsInfo | ConvertTo-Json | Out-File -FilePath "dns-zone-info.json" -Encoding UTF8
Write-Host "💾 Informações salvas em: dns-zone-info.json" -ForegroundColor Cyan

Write-Host ""
Write-Host "🔧 Para verificar a propagação DNS:" -ForegroundColor Yellow
Write-Host "   nslookup $DomainName" -ForegroundColor White
Write-Host "   dig $DomainName NS" -ForegroundColor White

