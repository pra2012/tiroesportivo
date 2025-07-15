#!/bin/bash

# Script de Setup Azure DevOps - Tiro Esportivo Brasileiro
# TIROESPORTIVOBRASILEIRO.COM.BR

set -e

# Parâmetros
ORGANIZATION_NAME=${1}
PROJECT_NAME=${2:-"TiroEsportivoBrasileiro"}
SUBSCRIPTION_ID=${3:-"130706ec-b9d5-4554-8be1-ef855c2cf41a"}
RESOURCE_GROUP_NAME=${4:-"tiroesportivo"}
LOCATION=${5:-"East US"}

# Função para exibir ajuda
show_help() {
    echo ""
    echo "🎯 Setup Azure DevOps - Tiro Esportivo Brasileiro"
    echo ""
    echo "Uso: $0 <organization> [project] <subscription-id> [resource-group] [location]"
    echo ""
    echo "Parâmetros:"
    echo "  organization      Nome da organização Azure DevOps (obrigatório)"
    echo "  project          Nome do projeto (padrão: TiroEsportivoBrasileiro)"
    echo "  subscription-id  ID da subscription Azure (obrigatório)"
    echo "  resource-group   Nome do Resource Group (padrão: tiroesportivo)"
    echo "  location         Região do Azure (padrão: East US)"
    echo ""
    echo "Exemplo:"
    echo "  $0 minha-org TiroEsportivoBrasileiro 12345678-1234-1234-1234-123456789012"
    echo ""
}

# Verificar parâmetros obrigatórios
if [[ -z "$ORGANIZATION_NAME" ]]; then
    echo "❌ Erro: Nome da organização é obrigatório"
    show_help
    exit 1
fi

echo "🚀 Configurando Azure DevOps para Tiro Esportivo Brasileiro"
echo "Organization: $ORGANIZATION_NAME"
echo "Project: $PROJECT_NAME"
echo "Subscription: $SUBSCRIPTION_ID"
echo "Resource Group: $RESOURCE_GROUP_NAME"
echo "Location: $LOCATION"
echo ""

# Verificar se Azure CLI está instalado
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI não está instalado."
    echo "Instale em: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Verificar se Azure DevOps extension está instalada
echo "📦 Verificando extensões do Azure CLI..."
if ! az extension list --query "[?name=='azure-devops'].name" -o tsv | grep -q "azure-devops"; then
    echo "Instalando extensão Azure DevOps..."
    az extension add --name azure-devops
fi

# Login no Azure
echo "🔐 Fazendo login no Azure..."
az login

# Configurar subscription padrão
az account set --subscription "$SUBSCRIPTION_ID"

# Configurar organização padrão do Azure DevOps
echo "⚙️ Configurando Azure DevOps..."
az devops configure --defaults organization="https://dev.azure.com/$ORGANIZATION_NAME" project="$PROJECT_NAME"

# Verificar se o projeto existe
echo "🔍 Verificando projeto Azure DevOps..."
if ! az devops project show --project "$PROJECT_NAME" --query "name" -o tsv &> /dev/null; then
    echo "Criando projeto Azure DevOps..."
    az devops project create \
        --name "$PROJECT_NAME" \
        --description "Sistema de controle de tiro esportivo - TIROESPORTIVOBRASILEIRO.COM.BR" \
        --visibility private
    echo "✅ Projeto criado com sucesso!"
else
    echo "✅ Projeto já existe."
fi

# Criar Service Principal para Azure DevOps
echo "🔑 Criando Service Principal..."
SP_NAME="TiroEsportivo-DevOps-$(date +%Y%m%d)"
SP_CREDENTIALS=$(az ad sp create-for-rbac \
    --name "$SP_NAME" \
    --role contributor \
    --scopes "/subscriptions/$SUBSCRIPTION_ID" \
    --sdk-auth)

if [[ -n "$SP_CREDENTIALS" ]]; then
    echo "✅ Service Principal criado com sucesso!"
    echo "📋 Credenciais do Service Principal:"
    
    # Extrair informações do JSON
    CLIENT_ID=$(echo "$SP_CREDENTIALS" | jq -r '.clientId')
    CLIENT_SECRET=$(echo "$SP_CREDENTIALS" | jq -r '.clientSecret')
    TENANT_ID=$(echo "$SP_CREDENTIALS" | jq -r '.tenantId')
    
    echo "Client ID: $CLIENT_ID"
    echo "Client Secret: $CLIENT_SECRET"
    echo "Tenant ID: $TENANT_ID"
    echo "Subscription ID: $SUBSCRIPTION_ID"
    
    # Salvar credenciais em arquivo temporário
    echo "$SP_CREDENTIALS" > service-principal-credentials.json
    echo "💾 Credenciais salvas em: service-principal-credentials.json"
    echo "⚠️ IMPORTANTE: Guarde essas credenciais em local seguro e delete o arquivo após configurar!"
fi

# Instruções para Service Connection
echo "🔗 Configurando Service Connection..."
echo "⚠️ Service Connection deve ser criado manualmente no Azure DevOps:"
echo "1. Acesse: https://dev.azure.com/$ORGANIZATION_NAME/$PROJECT_NAME/_settings/adminservices"
echo "2. Clique em 'New service connection' → 'Azure Resource Manager'"
echo "3. Escolha 'Service principal (manual)'"
echo "4. Use as credenciais salvas em service-principal-credentials.json"
echo "5. Nome da conexão: 'Azure-Connection'"
echo ""

# Criar repositório Git
echo "📁 Configurando repositório Git..."
if ! az repos show --repository "$PROJECT_NAME" --query "name" -o tsv &> /dev/null; then
    echo "Criando repositório Git..."
    az repos create --name "$PROJECT_NAME" --project "$PROJECT_NAME"
    echo "✅ Repositório criado com sucesso!"
else
    echo "✅ Repositório já existe."
fi

# Configurar políticas de branch
echo "🛡️ Configurando políticas de branch..."
echo "⚠️ Políticas de branch devem ser configuradas manualmente:"
echo "1. Acesse: https://dev.azure.com/$ORGANIZATION_NAME/$PROJECT_NAME/_settings/repositories"
echo "2. Configure políticas para branch 'main'"
echo "3. Ative: Minimum number of reviewers (1)"
echo "4. Ative: Check for linked work items"
echo "5. Ative: Check for comment resolution"
echo ""

# Criar variáveis de pipeline
echo "📊 Configurando variáveis de pipeline..."
declare -A variables=(
    ["resourceGroupName"]="$RESOURCE_GROUP_NAME"
    ["webAppName"]="tiroesportivobrasileiro"
    ["domainName"]="tiroesportivobrasileiro.com.br"
    ["location"]="$LOCATION"
    ["azureSubscription"]="Azure-Connection"
)

for var_name in "${!variables[@]}"; do
    var_value="${variables[$var_name]}"
    if az pipelines variable create --name "$var_name" --value "$var_value" --project "$PROJECT_NAME" &> /dev/null; then
        echo "✅ Variável $var_name criada"
    else
        echo "⚠️ Variável $var_name já existe ou erro na criação"
    fi
done

# Criar environments
echo "🌍 Criando environments..."
environments=("development" "production" "infrastructure")
for env in "${environments[@]}"; do
    # Criar environment via REST API
    ENV_JSON=$(cat <<EOF
{
    "name": "$env",
    "description": "Environment for $env"
}
EOF
)
    
    if echo "$ENV_JSON" | az devops invoke \
        --area distributedtask \
        --resource environments \
        --route-parameters project="$PROJECT_NAME" \
        --http-method POST \
        --in-file /dev/stdin &> /dev/null; then
        echo "✅ Environment '$env' criado"
    else
        echo "⚠️ Environment '$env' já existe ou erro na criação"
    fi
done

echo ""
echo "🎉 Setup do Azure DevOps concluído!"
echo ""
echo "📋 Próximos passos:"
echo "1. Configure o Service Connection manualmente (veja instruções acima)"
echo "2. Faça push do código para o repositório:"
echo "   git remote add origin https://dev.azure.com/$ORGANIZATION_NAME/$PROJECT_NAME/_git/$PROJECT_NAME"
echo "   git push -u origin main"
echo "3. Configure os pipelines no Azure DevOps"
echo "4. Execute o pipeline de infraestrutura primeiro"
echo "5. Configure DNS no registrador do domínio"
echo ""
echo "🌐 URLs importantes:"
echo "- Azure DevOps: https://dev.azure.com/$ORGANIZATION_NAME/$PROJECT_NAME"
echo "- Repositório: https://dev.azure.com/$ORGANIZATION_NAME/$PROJECT_NAME/_git/$PROJECT_NAME"
echo "- Pipelines: https://dev.azure.com/$ORGANIZATION_NAME/$PROJECT_NAME/_build"
echo ""
echo "⚠️ LEMBRE-SE: Delete o arquivo service-principal-credentials.json após configurar!"

