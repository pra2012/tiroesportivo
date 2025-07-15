#!/bin/bash

# Script de Deploy Completo com Azure DNS
# Tiro Esportivo Brasileiro - TIROESPORTIVOBRASILEIRO.COM.BR

set -e

# Parâmetros padrão
RESOURCE_GROUP_NAME=${1:-"tiroesportivo"}
WEB_APP_NAME=${2:-"tiroesportivobrasileiro"}
DOMAIN_NAME=${3:-"tiroesportivobrasileiro.com.br"}
LOCATION=${4:-"East US"}
APP_SERVICE_PLAN=${5:-"tiroesportivo-plan"}
SKU=${6:-"S1"}

# Função para exibir ajuda
show_help() {
    echo "🎯 Deploy Completo - Tiro Esportivo Brasileiro"
    echo "🌐 Azure DNS + Web App + SSL"
    echo ""
    echo "Uso: $0 [resource-group] [web-app-name] [domain-name] [location] [app-service-plan] [sku]"
    echo ""
    echo "Parâmetros (todos opcionais):"
    echo "  resource-group    Nome do Resource Group (padrão: tiroesportivo)"
    echo "  web-app-name     Nome da Web App (padrão: tiroesportivobrasileiro)"
    echo "  domain-name      Nome do domínio (padrão: tiroesportivobrasileiro.com.br)"
    echo "  location         Região do Azure (padrão: East US)"
    echo "  app-service-plan Nome do App Service Plan (padrão: tiroesportivo-plan)"
    echo "  sku              SKU do App Service Plan (padrão: S1)"
    echo ""
    echo "Exemplo:"
    echo "  $0"
    echo "  $0 meu-rg minha-app meudominio.com.br"
    echo ""
    exit 1
}

# Verificar se é pedido de ajuda
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
fi

echo "🎯 Deploy Completo - Tiro Esportivo Brasileiro"
echo "🌐 Domínio: $DOMAIN_NAME (Azure DNS)"
echo ""

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

# ========================================
# PARTE 1: CONFIGURAR AZURE DNS
# ========================================

echo ""
echo "🌐 PARTE 1: Configurando Azure DNS Zone..."

# Verificar se DNS Zone já existe
DNS_ZONE_EXISTS=$(az network dns zone show --resource-group "$RESOURCE_GROUP_NAME" --name "$DOMAIN_NAME" --query "name" -o tsv 2>/dev/null || echo "")
if [ -z "$DNS_ZONE_EXISTS" ]; then
    echo "   Criando DNS Zone para $DOMAIN_NAME..."
    az network dns zone create --resource-group "$RESOURCE_GROUP_NAME" --name "$DOMAIN_NAME"
    
    # Criar registros DNS básicos
    echo "   Criando registros DNS básicos..."
    
    # Registro CNAME para www
    az network dns record-set cname create --resource-group "$RESOURCE_GROUP_NAME" --zone-name "$DOMAIN_NAME" --name "www" --ttl 3600
    az network dns record-set cname set-record --resource-group "$RESOURCE_GROUP_NAME" --zone-name "$DOMAIN_NAME" --record-set-name "www" --cname "$DOMAIN_NAME"
    
    # Registro TXT para verificação
    az network dns record-set txt create --resource-group "$RESOURCE_GROUP_NAME" --zone-name "$DOMAIN_NAME" --name "@" --ttl 3600
    az network dns record-set txt add-record --resource-group "$RESOURCE_GROUP_NAME" --zone-name "$DOMAIN_NAME" --record-set-name "@" --value "v=spf1 -all"
    
    echo "✅ DNS Zone criada com sucesso!"
else
    echo "✅ DNS Zone já existe"
fi

# Obter Name Servers
NAME_SERVERS=$(az network dns zone show --resource-group "$RESOURCE_GROUP_NAME" --name "$DOMAIN_NAME" --query "nameServers" -o tsv)

echo ""
echo "📋 Name Servers do Azure DNS:"
for ns in $NAME_SERVERS; do
    echo "   $ns"
done

# ========================================
# PARTE 2: CRIAR WEB APP
# ========================================

echo ""
echo "🌐 PARTE 2: Criando Web App..."

# Criar App Service Plan
echo "   Criando App Service Plan: $APP_SERVICE_PLAN (SKU: $SKU)"
az appservice plan create \
    --name "$APP_SERVICE_PLAN" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --location "$LOCATION" \
    --sku "$SKU" \
    --is-linux

# Criar Web App
echo "   Criando Web App: $WEB_APP_NAME"
az webapp create \
    --name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --plan "$APP_SERVICE_PLAN" \
    --runtime "PYTHON:3.11"

# Configurar variáveis de ambiente
echo "   Configurando variáveis de ambiente..."
az webapp config appsettings set \
    --name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --settings \
        FLASK_ENV=production \
        SECRET_KEY="tiroesportivobrasileiro-azure-dns-secret-key-2024" \
        CUSTOM_DOMAIN="$DOMAIN_NAME" \
        AZURE_DNS_ENABLED=true \
        FORCE_HTTPS=true \
        SCM_DO_BUILD_DURING_DEPLOYMENT=true \
        ENABLE_ORYX_BUILD=true \
        WEBSITES_ENABLE_APP_SERVICE_STORAGE=true

# Configurar startup command
echo "   Configurando comando de inicialização..."
az webapp config set \
    --name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --startup-file "startup.py"

# Deploy do código
echo "   Fazendo deploy do código..."
CURRENT_DIR=$(pwd)
az webapp deployment source config-zip \
    --name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --src "$CURRENT_DIR/tiroesportivobrasileiro-azure-dns.zip"

# Aguardar deploy
echo "   Aguardando conclusão do deploy..."
sleep 30

# Obter URL temporária
TEMP_URL=$(az webapp show --name "$WEB_APP_NAME" --resource-group "$RESOURCE_GROUP_NAME" --query "defaultHostName" -o tsv)

echo "✅ Web App criada com sucesso!"
echo "   URL temporária: https://$TEMP_URL"

# ========================================
# PARTE 3: CONFIGURAR DNS RECORDS
# ========================================

echo ""
echo "🌐 PARTE 3: Configurando registros DNS..."

# Criar registro CNAME para root domain apontando para Web App
echo "   Criando registro CNAME para domínio raiz..."
CNAME_EXISTS=$(az network dns record-set cname show --resource-group "$RESOURCE_GROUP_NAME" --zone-name "$DOMAIN_NAME" --name "@" --query "name" -o tsv 2>/dev/null || echo "")
if [ -z "$CNAME_EXISTS" ]; then
    az network dns record-set cname create --resource-group "$RESOURCE_GROUP_NAME" --zone-name "$DOMAIN_NAME" --name "@" --ttl 3600
fi
az network dns record-set cname set-record --resource-group "$RESOURCE_GROUP_NAME" --zone-name "$DOMAIN_NAME" --record-set-name "@" --cname "$TEMP_URL"

# Criar registro TXT para verificação de domínio personalizado
echo "   Criando registro TXT para verificação..."
VERIFICATION_ID=$(az webapp show --name "$WEB_APP_NAME" --resource-group "$RESOURCE_GROUP_NAME" --query "customDomainVerificationId" -o tsv)

TXT_EXISTS=$(az network dns record-set txt show --resource-group "$RESOURCE_GROUP_NAME" --zone-name "$DOMAIN_NAME" --name "asuid" --query "name" -o tsv 2>/dev/null || echo "")
if [ -z "$TXT_EXISTS" ]; then
    az network dns record-set txt create --resource-group "$RESOURCE_GROUP_NAME" --zone-name "$DOMAIN_NAME" --name "asuid" --ttl 3600
fi
az network dns record-set txt add-record --resource-group "$RESOURCE_GROUP_NAME" --zone-name "$DOMAIN_NAME" --record-set-name "asuid" --value "$VERIFICATION_ID"

echo "✅ Registros DNS configurados!"

# ========================================
# PARTE 4: CONFIGURAR DOMÍNIO PERSONALIZADO
# ========================================

echo ""
echo "🌐 PARTE 4: Configurando domínio personalizado..."

# Aguardar propagação DNS
echo "   Aguardando propagação DNS (60 segundos)..."
sleep 60

# Adicionar domínio personalizado
echo "   Adicionando domínio personalizado..."
if az webapp config hostname add \
    --webapp-name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --hostname "$DOMAIN_NAME"; then
    
    echo "✅ Domínio personalizado adicionado!"
    
    # Adicionar www também
    if az webapp config hostname add \
        --webapp-name "$WEB_APP_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --hostname "www.$DOMAIN_NAME"; then
        echo "✅ Subdomínio www adicionado!"
    fi
    
else
    echo "⚠️  Erro ao adicionar domínio personalizado. Verifique a propagação DNS."
    echo "   Você pode configurar manualmente no Portal Azure após a propagação."
fi

# ========================================
# PARTE 5: CONFIGURAR SSL
# ========================================

echo ""
echo "🔒 PARTE 5: Configurando certificado SSL..."

# Aguardar um pouco mais para o domínio ser reconhecido
sleep 30

# Criar certificado gerenciado para domínio principal
echo "   Criando certificado SSL para $DOMAIN_NAME..."
if az webapp config ssl create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$WEB_APP_NAME" \
    --hostname "$DOMAIN_NAME"; then
    
    # Criar certificado para www
    echo "   Criando certificado SSL para www.$DOMAIN_NAME..."
    az webapp config ssl create \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --name "$WEB_APP_NAME" \
        --hostname "www.$DOMAIN_NAME" 2>/dev/null || true
    
    # Obter thumbprints dos certificados
    THUMBPRINT1=$(az webapp config ssl list --resource-group "$RESOURCE_GROUP_NAME" --query "[?subjectName=='$DOMAIN_NAME'].thumbprint" --output tsv)
    THUMBPRINT2=$(az webapp config ssl list --resource-group "$RESOURCE_GROUP_NAME" --query "[?subjectName=='www.$DOMAIN_NAME'].thumbprint" --output tsv)
    
    # Vincular certificados
    if [ -n "$THUMBPRINT1" ]; then
        echo "   Vinculando certificado SSL para $DOMAIN_NAME..."
        az webapp config ssl bind \
            --resource-group "$RESOURCE_GROUP_NAME" \
            --name "$WEB_APP_NAME" \
            --certificate-thumbprint "$THUMBPRINT1" \
            --ssl-type SNI
    fi
    
    if [ -n "$THUMBPRINT2" ]; then
        echo "   Vinculando certificado SSL para www.$DOMAIN_NAME..."
        az webapp config ssl bind \
            --resource-group "$RESOURCE_GROUP_NAME" \
            --name "$WEB_APP_NAME" \
            --certificate-thumbprint "$THUMBPRINT2" \
            --ssl-type SNI
    fi
    
    echo "✅ SSL configurado com sucesso!"
    
else
    echo "⚠️  Certificado SSL não pôde ser criado automaticamente."
    echo "   Configure manualmente no Portal Azure após a propagação DNS."
fi

# ========================================
# RESUMO FINAL
# ========================================

echo ""
echo "🎉 Deploy Completo Finalizado!"
echo ""

# URLs finais
CUSTOM_URL="https://$DOMAIN_NAME"
WWW_URL="https://www.$DOMAIN_NAME"
TEMP_FULL_URL="https://$TEMP_URL"

echo "🌐 URLs da aplicação:"
echo "   Principal: $CUSTOM_URL"
echo "   WWW: $WWW_URL"
echo "   Temporária: $TEMP_FULL_URL"
echo ""

echo "👤 Credenciais de acesso:"
echo "   - Demo: demo / demo123"
echo "   - Admin: admin / admin123"
echo ""

echo "🌐 Name Servers (configure no registrador):"
for ns in $NAME_SERVERS; do
    echo "   $ns"
done
echo ""

echo "📊 Recursos criados:"
echo "   - Resource Group: $RESOURCE_GROUP_NAME"
echo "   - DNS Zone: $DOMAIN_NAME"
echo "   - App Service Plan: $APP_SERVICE_PLAN"
echo "   - Web App: $WEB_APP_NAME"
echo "   - SSL Certificates: Gerenciados pelo Azure"
echo ""

echo "🔧 Comandos úteis:"
echo "   # Ver logs:"
echo "   az webapp log tail --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP_NAME"
echo ""
echo "   # Verificar DNS:"
echo "   nslookup $DOMAIN_NAME"
echo ""
echo "   # Verificar SSL:"
echo "   curl -I $CUSTOM_URL"
echo ""

# Salvar informações de deploy
cat > deploy-info.json << EOF
{
  "ResourceGroup": "$RESOURCE_GROUP_NAME",
  "WebAppName": "$WEB_APP_NAME",
  "DomainName": "$DOMAIN_NAME",
  "NameServers": [
$(echo "$NAME_SERVERS" | sed 's/^/    "/' | sed 's/$/"/' | sed '$!s/$/,/')
  ],
  "URLs": {
    "Primary": "$CUSTOM_URL",
    "WWW": "$WWW_URL",
    "Temporary": "$TEMP_FULL_URL"
  },
  "DeployedAt": "$(date '+%Y-%m-%d %H:%M:%S')"
}
EOF

echo "💾 Informações de deploy salvas em: deploy-info.json"

echo ""
echo "✅ Tiro Esportivo Brasileiro está no ar com Azure DNS!"

