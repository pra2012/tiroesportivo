#!/bin/bash

# Configure Pipelines - Tiro Esportivo Brasileiro
# TIROESPORTIVOBRASILEIRO.COM.BR
# Script para configurar pipelines via Azure Cloud Shell

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configurações
ORGANIZATION_NAME=${1}
PROJECT_NAME="TiroEsportivoBrasileiro"
SUBSCRIPTION_ID="130706ec-b9d5-4554-8be1-ef855c2cf41a"
RESOURCE_GROUP_NAME="tiroesportivo"

# Função para log
log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Verificar parâmetros
if [[ -z "$ORGANIZATION_NAME" ]]; then
    error "Nome da organização é obrigatório"
    echo "Uso: $0 <organization-name>"
    exit 1
fi

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║           ⚙️ CONFIGURE PIPELINES                            ║"
echo "║              Azure Cloud Shell                              ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

log "🚀 Configurando pipelines para: $ORGANIZATION_NAME/$PROJECT_NAME"

# Configurar Azure DevOps
az devops configure --defaults organization="https://dev.azure.com/$ORGANIZATION_NAME" project="$PROJECT_NAME"

# Verificar se Service Connection existe
log "🔗 Verificando Service Connection..."
SERVICE_CONNECTION_EXISTS=$(az devops service-endpoint list --query "[?name=='Azure-Connection'].name" -o tsv)

if [[ -z "$SERVICE_CONNECTION_EXISTS" ]]; then
    log "⚠️ Service Connection 'Azure-Connection' não encontrado"
    echo -e "${YELLOW}Configure manualmente no Azure DevOps:${NC}"
    echo "1. Acesse: https://dev.azure.com/$ORGANIZATION_NAME/$PROJECT_NAME/_settings/adminservices"
    echo "2. New service connection → Azure Resource Manager"
    echo "3. Service principal (manual)"
    echo "4. Use as credenciais salvas em: ~/tiroesportivo-credentials.json"
    echo ""
    read -p "Pressione Enter após configurar o Service Connection..."
else
    info "✅ Service Connection 'Azure-Connection' encontrado"
fi

# Criar pipeline de infraestrutura
log "🏗️ Criando pipeline de infraestrutura..."
INFRA_PIPELINE_ID=$(az pipelines create \
    --name "Infrastructure-Pipeline" \
    --description "Pipeline de infraestrutura para TIROESPORTIVOBRASILEIRO.COM.BR" \
    --repository "https://dev.azure.com/$ORGANIZATION_NAME/$PROJECT_NAME/_git/$PROJECT_NAME" \
    --branch main \
    --yml-path "infrastructure-pipeline.yml" \
    --query "id" -o tsv 2>/dev/null || echo "")

if [[ -n "$INFRA_PIPELINE_ID" ]]; then
    info "✅ Pipeline de infraestrutura criado: ID $INFRA_PIPELINE_ID"
else
    info "⚠️ Pipeline de infraestrutura já existe ou erro na criação"
fi

# Criar pipeline principal
log "🚀 Criando pipeline principal..."
MAIN_PIPELINE_ID=$(az pipelines create \
    --name "Main-Pipeline" \
    --description "Pipeline principal CI/CD para TIROESPORTIVOBRASILEIRO.COM.BR" \
    --repository "https://dev.azure.com/$ORGANIZATION_NAME/$PROJECT_NAME/_git/$PROJECT_NAME" \
    --branch main \
    --yml-path "azure-pipelines.yml" \
    --query "id" -o tsv 2>/dev/null || echo "")

if [[ -n "$MAIN_PIPELINE_ID" ]]; then
    info "✅ Pipeline principal criado: ID $MAIN_PIPELINE_ID"
else
    info "⚠️ Pipeline principal já existe ou erro na criação"
fi

# Configurar branch policies
log "🔒 Configurando branch policies..."

# Política de build validation
if [[ -n "$MAIN_PIPELINE_ID" ]]; then
    POLICY_JSON=$(cat <<EOF
{
    "isEnabled": true,
    "isBlocking": true,
    "type": {
        "id": "0609b952-1397-4640-95ec-e00a01b2c241"
    },
    "settings": {
        "buildDefinitionId": $MAIN_PIPELINE_ID,
        "queueOnSourceUpdateOnly": true,
        "manualQueueOnly": false,
        "displayName": "Build Validation",
        "validDuration": 720
    }
}
EOF
)
    
    echo "$POLICY_JSON" | az repos policy build create \
        --branch main \
        --repository-id "$PROJECT_NAME" \
        --blocking true \
        --enabled true \
        --build-definition-id "$MAIN_PIPELINE_ID" \
        --display-name "Build Validation" \
        --manual-queue-only false \
        --queue-on-source-update-only true \
        --valid-duration 720 &> /dev/null || true
    
    info "✅ Branch policy configurada"
fi

# Configurar variáveis de pipeline
log "📊 Configurando variáveis de pipeline..."

# Variáveis para pipeline de infraestrutura
if [[ -n "$INFRA_PIPELINE_ID" ]]; then
    declare -A infra_variables=(
        ["subscriptionId"]="$SUBSCRIPTION_ID"
        ["resourceGroupName"]="$RESOURCE_GROUP_NAME"
        ["location"]="East US"
        ["domainName"]="tiroesportivobrasileiro.com.br"
        ["azureSubscription"]="Azure-Connection"
    )
    
    for var_name in "${!infra_variables[@]}"; do
        var_value="${infra_variables[$var_name]}"
        az pipelines variable create \
            --pipeline-id "$INFRA_PIPELINE_ID" \
            --name "$var_name" \
            --value "$var_value" &> /dev/null || true
    done
    
    info "✅ Variáveis do pipeline de infraestrutura configuradas"
fi

# Variáveis para pipeline principal
if [[ -n "$MAIN_PIPELINE_ID" ]]; then
    declare -A main_variables=(
        ["subscriptionId"]="$SUBSCRIPTION_ID"
        ["resourceGroupName"]="$RESOURCE_GROUP_NAME"
        ["webAppName"]="tiroesportivobrasileiro"
        ["domainName"]="tiroesportivobrasileiro.com.br"
        ["azureSubscription"]="Azure-Connection"
    )
    
    for var_name in "${!main_variables[@]}"; do
        var_value="${main_variables[$var_name]}"
        az pipelines variable create \
            --pipeline-id "$MAIN_PIPELINE_ID" \
            --name "$var_name" \
            --value "$var_value" &> /dev/null || true
    done
    
    info "✅ Variáveis do pipeline principal configuradas"
fi

# Executar pipeline de infraestrutura
log "🏗️ Executando pipeline de infraestrutura..."
if [[ -n "$INFRA_PIPELINE_ID" ]]; then
    INFRA_RUN_ID=$(az pipelines run \
        --id "$INFRA_PIPELINE_ID" \
        --branch main \
        --query "id" -o tsv)
    
    if [[ -n "$INFRA_RUN_ID" ]]; then
        info "✅ Pipeline de infraestrutura iniciado: Run ID $INFRA_RUN_ID"
        echo -e "${YELLOW}🔗 Acompanhe em:${NC} https://dev.azure.com/$ORGANIZATION_NAME/$PROJECT_NAME/_build/results?buildId=$INFRA_RUN_ID"
        
        # Aguardar conclusão (opcional)
        echo ""
        read -p "Aguardar conclusão do pipeline de infraestrutura? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log "⏳ Aguardando conclusão do pipeline de infraestrutura..."
            
            while true; do
                STATUS=$(az pipelines runs show --id "$INFRA_RUN_ID" --query "status" -o tsv)
                RESULT=$(az pipelines runs show --id "$INFRA_RUN_ID" --query "result" -o tsv)
                
                if [[ "$STATUS" == "completed" ]]; then
                    if [[ "$RESULT" == "succeeded" ]]; then
                        info "✅ Pipeline de infraestrutura concluído com sucesso!"
                        break
                    else
                        error "❌ Pipeline de infraestrutura falhou: $RESULT"
                        exit 1
                    fi
                fi
                
                echo -n "."
                sleep 10
            done
        fi
    fi
fi

# Mostrar Name Servers DNS
log "🌐 Obtendo Name Servers DNS..."
NAME_SERVERS=$(az network dns zone show \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "tiroesportivobrasileiro.com.br" \
    --query "nameServers" \
    --output table 2>/dev/null || echo "DNS Zone não encontrada")

if [[ "$NAME_SERVERS" != "DNS Zone não encontrada" ]]; then
    echo ""
    echo -e "${PURPLE}📋 Name Servers DNS:${NC}"
    echo "$NAME_SERVERS"
    echo ""
    echo -e "${YELLOW}⚠️ Configure estes Name Servers no registrador do domínio!${NC}"
fi

# Resumo final
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                  ⚙️ PIPELINES CONFIGURADOS!                 ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}📋 Resumo:${NC}"
echo -e "${BLUE}Organization:${NC} $ORGANIZATION_NAME"
echo -e "${BLUE}Project:${NC} $PROJECT_NAME"
echo -e "${BLUE}Subscription:${NC} $SUBSCRIPTION_ID"
echo -e "${BLUE}Resource Group:${NC} $RESOURCE_GROUP_NAME"
echo ""
echo -e "${CYAN}🚀 Pipelines:${NC}"
if [[ -n "$INFRA_PIPELINE_ID" ]]; then
    echo -e "${BLUE}Infraestrutura:${NC} https://dev.azure.com/$ORGANIZATION_NAME/$PROJECT_NAME/_build?definitionId=$INFRA_PIPELINE_ID"
fi
if [[ -n "$MAIN_PIPELINE_ID" ]]; then
    echo -e "${BLUE}Principal:${NC} https://dev.azure.com/$ORGANIZATION_NAME/$PROJECT_NAME/_build?definitionId=$MAIN_PIPELINE_ID"
fi
echo ""
echo -e "${CYAN}📋 Próximos passos:${NC}"
echo -e "${YELLOW}1.${NC} Configure DNS no registrador (Name Servers acima)"
echo -e "${YELLOW}2.${NC} Execute pipeline principal para deploy da aplicação"
echo -e "${YELLOW}3.${NC} Acesse: https://tiroesportivobrasileiro.com.br"
echo ""
echo -e "${GREEN}🎯 TIROESPORTIVOBRASILEIRO.COM.BR configurado!${NC}"

