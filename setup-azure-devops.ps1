# Script de Setup Azure DevOps - Tiro Esportivo Brasileiro
# TIROESPORTIVOBRASILEIRO.COM.BR

param(
    [Parameter(Mandatory=$false)]
    [string]$OrganizationName,
    
    [Parameter(Mandatory=$false)]
    [string]$ProjectName = "TiroEsportivoBrasileiro",
    
    [Parameter(Mandatory=$false)]
    [string]$SubscriptionId = "130706ec-b9d5-4554-8be1-ef855c2cf41a",
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "tiroesportivo",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "East US"
)

Write-Host "🚀 Configurando Azure DevOps para Tiro Esportivo Brasileiro" -ForegroundColor Green
Write-Host "Organization: $OrganizationName" -ForegroundColor Yellow
Write-Host "Project: $ProjectName" -ForegroundColor Yellow
Write-Host "Subscription: $SubscriptionId" -ForegroundColor Yellow

# Verificar se Azure CLI está instalado
if (!(Get-Command "az" -ErrorAction SilentlyContinue)) {
    Write-Error "Azure CLI não está instalado. Instale em: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
}

# Verificar se Azure DevOps extension está instalada
Write-Host "📦 Verificando extensões do Azure CLI..." -ForegroundColor Blue
$devopsExtension = az extension list --query "[?name=='azure-devops'].name" -o tsv
if (!$devopsExtension) {
    Write-Host "Instalando extensão Azure DevOps..." -ForegroundColor Yellow
    az extension add --name azure-devops
}

# Login no Azure
Write-Host "🔐 Fazendo login no Azure..." -ForegroundColor Blue
az login

# Configurar subscription padrão
az account set --subscription $SubscriptionId

# Configurar organização padrão do Azure DevOps
Write-Host "⚙️ Configurando Azure DevOps..." -ForegroundColor Blue
az devops configure --defaults organization=https://dev.azure.com/$OrganizationName project=$ProjectName

# Verificar se o projeto existe
Write-Host "🔍 Verificando projeto Azure DevOps..." -ForegroundColor Blue
$projectExists = az devops project show --project $ProjectName --query "name" -o tsv 2>$null
if (!$projectExists) {
    Write-Host "Criando projeto Azure DevOps..." -ForegroundColor Yellow
    az devops project create --name $ProjectName --description "Sistema de controle de tiro esportivo - TIROESPORTIVOBRASILEIRO.COM.BR" --visibility private
    Write-Host "✅ Projeto criado com sucesso!" -ForegroundColor Green
} else {
    Write-Host "✅ Projeto já existe." -ForegroundColor Green
}

# Criar Service Principal para Azure DevOps
Write-Host "🔑 Criando Service Principal..." -ForegroundColor Blue
$spName = "TiroEsportivo-DevOps-$((Get-Date).ToString('yyyyMMdd'))"
$spCredentials = az ad sp create-for-rbac --name $spName --role contributor --scopes "/subscriptions/$SubscriptionId" --sdk-auth | ConvertFrom-Json

if ($spCredentials) {
    Write-Host "✅ Service Principal criado com sucesso!" -ForegroundColor Green
    Write-Host "📋 Credenciais do Service Principal:" -ForegroundColor Yellow
    Write-Host "Client ID: $($spCredentials.clientId)" -ForegroundColor White
    Write-Host "Client Secret: $($spCredentials.clientSecret)" -ForegroundColor White
    Write-Host "Tenant ID: $($spCredentials.tenantId)" -ForegroundColor White
    Write-Host "Subscription ID: $($spCredentials.subscriptionId)" -ForegroundColor White
    
    # Salvar credenciais em arquivo temporário
    $spCredentials | ConvertTo-Json | Out-File -FilePath "service-principal-credentials.json"
    Write-Host "💾 Credenciais salvas em: service-principal-credentials.json" -ForegroundColor Yellow
    Write-Host "⚠️ IMPORTANTE: Guarde essas credenciais em local seguro e delete o arquivo após configurar!" -ForegroundColor Red
}

# Criar Service Connection
Write-Host "🔗 Criando Service Connection..." -ForegroundColor Blue
try {
    $serviceConnectionJson = @{
        data = @{
            subscriptionId = $SubscriptionId
            subscriptionName = (az account show --query "name" -o tsv)
            environment = "AzureCloud"
            scopeLevel = "Subscription"
            creationMode = "Manual"
        }
        name = "Azure-Connection"
        type = "AzureRM"
        url = "https://management.azure.com/"
        authorization = @{
            parameters = @{
                tenantid = $spCredentials.tenantId
                serviceprincipalid = $spCredentials.clientId
                authenticationType = "spnKey"
                serviceprincipalkey = $spCredentials.clientSecret
            }
            scheme = "ServicePrincipal"
        }
        isShared = $false
        isReady = $true
        serviceEndpointProjectReferences = @(
            @{
                projectReference = @{
                    id = (az devops project show --project $ProjectName --query "id" -o tsv)
                    name = $ProjectName
                }
                name = "Azure-Connection"
            }
        )
    } | ConvertTo-Json -Depth 10
    
    $serviceConnectionJson | Out-File -FilePath "service-connection.json"
    
    # Criar service connection via REST API (az devops service-endpoint create tem limitações)
    Write-Host "⚠️ Service Connection deve ser criado manualmente no Azure DevOps:" -ForegroundColor Yellow
    Write-Host "1. Acesse: https://dev.azure.com/$OrganizationName/$ProjectName/_settings/adminservices" -ForegroundColor White
    Write-Host "2. Clique em 'New service connection' → 'Azure Resource Manager'" -ForegroundColor White
    Write-Host "3. Escolha 'Service principal (manual)'" -ForegroundColor White
    Write-Host "4. Use as credenciais salvas em service-principal-credentials.json" -ForegroundColor White
    Write-Host "5. Nome da conexão: 'Azure-Connection'" -ForegroundColor White
    
} catch {
    Write-Warning "Erro ao criar Service Connection automaticamente. Configure manualmente."
}

# Criar repositório Git
Write-Host "📁 Configurando repositório Git..." -ForegroundColor Blue
$repoExists = az repos show --repository $ProjectName --query "name" -o tsv 2>$null
if (!$repoExists) {
    Write-Host "Criando repositório Git..." -ForegroundColor Yellow
    az repos create --name $ProjectName --project $ProjectName
    Write-Host "✅ Repositório criado com sucesso!" -ForegroundColor Green
} else {
    Write-Host "✅ Repositório já existe." -ForegroundColor Green
}

# Configurar branch policies
Write-Host "🛡️ Configurando políticas de branch..." -ForegroundColor Blue
try {
    # Política para branch main
    $mainBranchPolicy = @{
        isEnabled = $true
        isBlocking = $true
        type = @{
            id = "fa4e907d-c16b-4a4c-9dfa-4906e5d171dd" # Minimum number of reviewers
        }
        settings = @{
            minimumApproverCount = 1
            creatorVoteCounts = $false
            allowDownvotes = $false
            resetOnSourcePush = $true
            requireVoteOnLastIteration = $true
            scope = @(
                @{
                    repositoryId = (az repos show --repository $ProjectName --query "id" -o tsv)
                    refName = "refs/heads/main"
                    matchKind = "exact"
                }
            )
        }
    } | ConvertTo-Json -Depth 10
    
    Write-Host "⚠️ Políticas de branch devem ser configuradas manualmente:" -ForegroundColor Yellow
    Write-Host "1. Acesse: https://dev.azure.com/$OrganizationName/$ProjectName/_settings/repositories" -ForegroundColor White
    Write-Host "2. Configure políticas para branch 'main'" -ForegroundColor White
    Write-Host "3. Ative: Minimum number of reviewers (1)" -ForegroundColor White
    Write-Host "4. Ative: Check for linked work items" -ForegroundColor White
    Write-Host "5. Ative: Check for comment resolution" -ForegroundColor White
    
} catch {
    Write-Warning "Configure as políticas de branch manualmente no Azure DevOps."
}

# Criar variáveis de pipeline
Write-Host "📊 Configurando variáveis de pipeline..." -ForegroundColor Blue
$variables = @{
    "resourceGroupName" = $ResourceGroupName
    "webAppName" = "tiroesportivobrasileiro"
    "domainName" = "tiroesportivobrasileiro.com.br"
    "location" = $Location
    "azureSubscription" = "Azure-Connection"
}

foreach ($var in $variables.GetEnumerator()) {
    try {
        az pipelines variable create --name $var.Key --value $var.Value --project $ProjectName
        Write-Host "✅ Variável $($var.Key) criada" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Variável $($var.Key) já existe ou erro na criação" -ForegroundColor Yellow
    }
}

# Criar environments
Write-Host "🌍 Criando environments..." -ForegroundColor Blue
$environments = @("development", "production", "infrastructure")
foreach ($env in $environments) {
    try {
        az devops invoke --area distributedtask --resource environments --route-parameters project=$ProjectName --http-method POST --in-file @"
{
    "name": "$env",
    "description": "Environment for $env"
}
"@
        Write-Host "✅ Environment '$env' criado" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Environment '$env' já existe ou erro na criação" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "🎉 Setup do Azure DevOps concluído!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Próximos passos:" -ForegroundColor Yellow
Write-Host "1. Configure o Service Connection manualmente (veja instruções acima)" -ForegroundColor White
Write-Host "2. Faça push do código para o repositório:" -ForegroundColor White
Write-Host "   git remote add origin https://dev.azure.com/$OrganizationName/$ProjectName/_git/$ProjectName" -ForegroundColor Gray
Write-Host "   git push -u origin main" -ForegroundColor Gray
Write-Host "3. Configure os pipelines no Azure DevOps" -ForegroundColor White
Write-Host "4. Execute o pipeline de infraestrutura primeiro" -ForegroundColor White
Write-Host "5. Configure DNS no registrador do domínio" -ForegroundColor White
Write-Host ""
Write-Host "🌐 URLs importantes:" -ForegroundColor Yellow
Write-Host "- Azure DevOps: https://dev.azure.com/$OrganizationName/$ProjectName" -ForegroundColor White
Write-Host "- Repositório: https://dev.azure.com/$OrganizationName/$ProjectName/_git/$ProjectName" -ForegroundColor White
Write-Host "- Pipelines: https://dev.azure.com/$OrganizationName/$ProjectName/_build" -ForegroundColor White
Write-Host ""
Write-Host "⚠️ LEMBRE-SE: Delete o arquivo service-principal-credentials.json após configurar!" -ForegroundColor Red

