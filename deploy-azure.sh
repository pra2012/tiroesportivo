#!/bin/bash

# Script de Deploy para Azure Web App
# Shooting Sports - Controle de Tiro Esportivo

set -e

# Parâmetros
RESOURCE_GROUP_NAME=${1:-""}
WEB_APP_NAME=${2:-""}
LOCATION=${3:-"East US"}
APP_SERVICE_PLAN=${4:-"${WEB_APP_NAME}-plan"}

# Função para exibir ajuda
show_help() {
    echo "🎯 Script de Deploy - Shooting Sports no Azure Web App"
    echo ""
    echo "Uso: $0 <resource-group-name> <web-app-name> [location] [app-service-plan]"
    echo ""
    echo "Parâmetros:"
    echo "  resource-group-name  Nome do Resource Group (obrigatório)"
    echo "  web-app-name        Nome da Web App (obrigatório)"
    echo "  location            Região do Azure (opcional, padrão: 'East US')"
    echo "  app-service-plan    Nome do App Service Plan (opcional)"
    echo ""
    echo "Exemplo:"
    echo "  $0 shooting-sports-rg shooting-sports-app"
    echo ""
    exit 1
}

# Verificar parâmetros obrigatórios
if [ -z "$RESOURCE_GROUP_NAME" ] || [ -z "$WEB_APP_NAME" ]; then
    echo "❌ Erro: Parâmetros obrigatórios não fornecidos"
    show_help
fi

echo "🎯 Iniciando deploy do Shooting Sports no Azure Web App"

# Verificar se Azure CLI está instalado
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI não encontrado. Instale em: https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi

echo "✅ Azure CLI encontrado"

# Login no Azure (se necessário)
echo "🔐 Verificando login no Azure..."
ACCOUNT=$(az account show --query "user.name" -o tsv 2>/dev/null || echo "")
if [ -z "$ACCOUNT" ]; then
    echo "Fazendo login no Azure..."
    az login
    ACCOUNT=$(az account show --query "user.name" -o tsv)
fi

echo "✅ Logado como: $ACCOUNT"

# Criar Resource Group
echo "📦 Criando Resource Group: $RESOURCE_GROUP_NAME"
az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION"

# Criar App Service Plan
echo "🏗️ Criando App Service Plan: $APP_SERVICE_PLAN"
az appservice plan create \
    --name "$APP_SERVICE_PLAN" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --location "$LOCATION" \
    --sku B1 \
    --is-linux

# Criar Web App
echo "🌐 Criando Web App: $WEB_APP_NAME"
az webapp create \
    --name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --plan "$APP_SERVICE_PLAN" \
    --runtime "PYTHON:3.11"

# Configurar variáveis de ambiente
echo "⚙️ Configurando variáveis de ambiente..."
az webapp config appsettings set \
    --name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --settings \
        FLASK_ENV=production \
        SECRET_KEY="shooting-sports-azure-secret-key-2024" \
        SCM_DO_BUILD_DURING_DEPLOYMENT=true \
        ENABLE_ORYX_BUILD=true \
        WEBSITES_ENABLE_APP_SERVICE_STORAGE=true

# Configurar startup command
echo "🚀 Configurando comando de inicialização..."
az webapp config set \
    --name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --startup-file "startup.py"

# Deploy do código
echo "📤 Fazendo deploy do código..."
CURRENT_DIR=$(pwd)
az webapp deployment source config-zip \
    --name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --src "$CURRENT_DIR/shooting-sports-azure.zip"

# Obter URL da aplicação
APP_URL=$(az webapp show --name "$WEB_APP_NAME" --resource-group "$RESOURCE_GROUP_NAME" --query "defaultHostName" -o tsv)
FULL_URL="https://$APP_URL"

echo ""
echo "🎉 Deploy concluído com sucesso!"
echo "🌐 URL da aplicação: $FULL_URL"
echo "👤 Credenciais de acesso:"
echo "   - Demo: demo / demo123"
echo "   - Admin: admin / admin123"
echo ""
echo "📊 Para monitorar a aplicação:"
echo "   az webapp log tail --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP_NAME"
echo ""

# Perguntar se deseja abrir no navegador
read -p "Deseja abrir a aplicação no navegador? (y/n): " OPEN_BROWSER
if [ "$OPEN_BROWSER" = "y" ] || [ "$OPEN_BROWSER" = "Y" ]; then
    if command -v xdg-open &> /dev/null; then
        xdg-open "$FULL_URL"
    elif command -v open &> /dev/null; then
        open "$FULL_URL"
    else
        echo "Abra manualmente: $FULL_URL"
    fi
fi

