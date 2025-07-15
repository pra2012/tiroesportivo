#!/bin/bash

# =============================================================================
# TIRO ESPORTIVO BRASILEIRO - SETUP AZURE CLOUD SHELL
# =============================================================================
# Script otimizado para Azure Cloud Shell
# Subscription ID: 130706ec-b9d5-4554-8be1-ef855c2cf41a
# Resource Group: tiroesportivo
# Dominio: tiroesportivobrasileiro.com.br
# Organizacao DevOps: Paulo
# =============================================================================

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuracoes
SUBSCRIPTION_ID="130706ec-b9d5-4554-8be1-ef855c2cf41a"
RESOURCE_GROUP="tiroesportivo"
LOCATION="East US"
DOMAIN_NAME="tiroesportivobrasileiro.com.br"
WEB_APP_NAME="tiroesportivobrasileiro"
WEB_APP_DEV_NAME="tiroesportivobrasileiro-dev"
APP_SERVICE_PLAN="tiroesportivo-plan"
DNS_ZONE_NAME="tiroesportivobrasileiro.com.br"
DEVOPS_ORG="Paulo"

# Funcao para log
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

# Banner
echo -e "${BLUE}"
echo "=============================================="
echo "  TIRO ESPORTIVO BRASILEIRO - CLOUD SHELL"
echo "=============================================="
echo "  Dominio: tiroesportivobrasileiro.com.br"
echo "  Organizacao DevOps: Paulo"
echo "  Azure DevOps + Azure DNS + Web App"
echo "=============================================="
echo -e "${NC}"

# Verificar se esta no Cloud Shell
if [ -z "$AZURE_HTTP_USER_AGENT" ]; then
    warning "Este script foi otimizado para Azure Cloud Shell"
    warning "Algumas funcionalidades podem nao funcionar em outros ambientes"
fi

# 1. Configurar Azure CLI
log "Configurando Azure CLI..."
az account set --subscription "$SUBSCRIPTION_ID"
az configure --defaults group="$RESOURCE_GROUP" location="$LOCATION"

# Verificar subscription
CURRENT_SUB=$(az account show --query id -o tsv)
if [ "$CURRENT_SUB" != "$SUBSCRIPTION_ID" ]; then
    error "Subscription incorreta. Esperado: $SUBSCRIPTION_ID, Atual: $CURRENT_SUB"
fi

log "Subscription configurada: $SUBSCRIPTION_ID"

# 2. Criar Resource Group
log "Criando Resource Group..."
if az group show --name "$RESOURCE_GROUP" &>/dev/null; then
    info "Resource Group '$RESOURCE_GROUP' ja existe"
else
    az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
    log "Resource Group '$RESOURCE_GROUP' criado"
fi

# 3. Criar DNS Zone
log "Criando DNS Zone..."
if az network dns zone show --name "$DNS_ZONE_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
    info "DNS Zone '$DNS_ZONE_NAME' ja existe"
else
    az network dns zone create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$DNS_ZONE_NAME"
    log "DNS Zone '$DNS_ZONE_NAME' criada"
fi

# Obter Name Servers
NAME_SERVERS=$(az network dns zone show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DNS_ZONE_NAME" \
    --query nameServers \
    --output tsv)

echo -e "${YELLOW}"
echo "=============================================="
echo "  CONFIGURACAO DNS NECESSARIA"
echo "=============================================="
echo "Configure estes Name Servers no seu registrador:"
echo "$NAME_SERVERS" | sed 's/^/  - /'
echo "=============================================="
echo -e "${NC}"

# 4. Criar App Service Plan
log "Criando App Service Plan..."
if az appservice plan show --name "$APP_SERVICE_PLAN" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
    info "App Service Plan '$APP_SERVICE_PLAN' ja existe"
else
    az appservice plan create \
        --name "$APP_SERVICE_PLAN" \
        --resource-group "$RESOURCE_GROUP" \
        --sku S1 \
        --is-linux
    log "App Service Plan '$APP_SERVICE_PLAN' criado"
fi

# 5. Criar Web Apps
log "Criando Web Apps..."

# Web App Producao
if az webapp show --name "$WEB_APP_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
    info "Web App '$WEB_APP_NAME' ja existe"
else
    az webapp create \
        --resource-group "$RESOURCE_GROUP" \
        --plan "$APP_SERVICE_PLAN" \
        --name "$WEB_APP_NAME" \
        --runtime "PYTHON|3.11" \
        --startup-file "startup.py"
    log "Web App '$WEB_APP_NAME' criado"
fi

# Web App Desenvolvimento
if az webapp show --name "$WEB_APP_DEV_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
    info "Web App '$WEB_APP_DEV_NAME' ja existe"
else
    az webapp create \
        --resource-group "$RESOURCE_GROUP" \
        --plan "$APP_SERVICE_PLAN" \
        --name "$WEB_APP_DEV_NAME" \
        --runtime "PYTHON|3.11" \
        --startup-file "startup.py"
    log "Web App '$WEB_APP_DEV_NAME' criado"
fi

# 6. Configurar Custom Domain (Producao)
log "Configurando dominio personalizado..."
if az webapp config hostname list --webapp-name "$WEB_APP_NAME" --resource-group "$RESOURCE_GROUP" --query "[?name=='$DOMAIN_NAME']" -o tsv | grep -q "$DOMAIN_NAME"; then
    info "Dominio '$DOMAIN_NAME' ja configurado"
else
    # Criar registro CNAME
    az network dns record-set cname create \
        --resource-group "$RESOURCE_GROUP" \
        --zone-name "$DNS_ZONE_NAME" \
        --name "@" \
        --ttl 300 || true
    
    az network dns record-set cname set-record \
        --resource-group "$RESOURCE_GROUP" \
        --zone-name "$DNS_ZONE_NAME" \
        --record-set-name "@" \
        --cname "$WEB_APP_NAME.azurewebsites.net" || true
    
    # Aguardar propagacao DNS
    info "Aguardando propagacao DNS (30 segundos)..."
    sleep 30
    
    # Adicionar dominio personalizado
    az webapp config hostname add \
        --webapp-name "$WEB_APP_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --hostname "$DOMAIN_NAME" || warning "Falha ao adicionar dominio. Configure manualmente apos propagacao DNS."
    
    log "Dominio personalizado configurado"
fi

# 7. Configurar SSL
log "Configurando SSL..."
az webapp config ssl bind \
    --certificate-type SNI \
    --name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --ssl-type SNI || warning "SSL sera configurado automaticamente apos propagacao DNS"

# 8. Configurar Application Insights
log "Configurando Application Insights..."
INSIGHTS_NAME="tiroesportivo-insights"
if az monitor app-insights component show --app "$INSIGHTS_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
    info "Application Insights '$INSIGHTS_NAME' ja existe"
else
    az monitor app-insights component create \
        --app "$INSIGHTS_NAME" \
        --location "$LOCATION" \
        --resource-group "$RESOURCE_GROUP" \
        --application-type web
    log "Application Insights '$INSIGHTS_NAME' criado"
fi

# Obter Instrumentation Key
INSTRUMENTATION_KEY=$(az monitor app-insights component show \
    --app "$INSIGHTS_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query instrumentationKey \
    --output tsv)

# Configurar nos Web Apps
az webapp config appsettings set \
    --name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --settings APPINSIGHTS_INSTRUMENTATIONKEY="$INSTRUMENTATION_KEY"

az webapp config appsettings set \
    --name "$WEB_APP_DEV_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --settings APPINSIGHTS_INSTRUMENTATIONKEY="$INSTRUMENTATION_KEY"

# 9. Criar Service Principal para Azure DevOps
log "Criando Service Principal..."
SP_NAME="tiroesportivo-devops-sp"

# Verificar se ja existe
if az ad sp list --display-name "$SP_NAME" --query "[0].appId" -o tsv | grep -q "."; then
    info "Service Principal '$SP_NAME' ja existe"
    SP_APP_ID=$(az ad sp list --display-name "$SP_NAME" --query "[0].appId" -o tsv)
else
    # Criar novo Service Principal
    SP_CREDENTIALS=$(az ad sp create-for-rbac \
        --name "$SP_NAME" \
        --role contributor \
        --scopes "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP")
    
    SP_APP_ID=$(echo "$SP_CREDENTIALS" | jq -r '.appId')
    SP_PASSWORD=$(echo "$SP_CREDENTIALS" | jq -r '.password')
    SP_TENANT=$(echo "$SP_CREDENTIALS" | jq -r '.tenant')
    
    log "Service Principal criado"
    
    echo -e "${YELLOW}"
    echo "=============================================="
    echo "  CREDENCIAIS SERVICE PRINCIPAL"
    echo "=============================================="
    echo "App ID: $SP_APP_ID"
    echo "Password: $SP_PASSWORD"
    echo "Tenant: $SP_TENANT"
    echo "Subscription: $SUBSCRIPTION_ID"
    echo "=============================================="
    echo "SALVE ESTAS CREDENCIAIS PARA AZURE DEVOPS!"
    echo "=============================================="
    echo -e "${NC}"
fi

# 10. Resumo Final
echo -e "${GREEN}"
echo "=============================================="
echo "  SETUP CONCLUIDO COM SUCESSO!"
echo "=============================================="
echo "Resource Group: $RESOURCE_GROUP"
echo "DNS Zone: $DNS_ZONE_NAME"
echo "Web App Prod: $WEB_APP_NAME"
echo "Web App Dev: $WEB_APP_DEV_NAME"
echo "Domain: https://$DOMAIN_NAME"
echo "DevOps Org: $DEVOPS_ORG"
echo "=============================================="
echo -e "${NC}"

echo -e "${BLUE}"
echo "PROXIMOS PASSOS:"
echo "1. Configure os Name Servers no seu registrador"
echo "2. Execute: ./upload-project.sh"
echo "3. Execute: ./configure-pipelines.sh (org: $DEVOPS_ORG)"
echo "4. Acesse: https://$DOMAIN_NAME"
echo -e "${NC}"

log "Setup Azure Cloud Shell concluido!"
