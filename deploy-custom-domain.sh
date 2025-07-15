#!/bin/bash

# Script de Deploy para Azure Web App com Domínio Personalizado
# Tiro Esportivo Brasileiro - TIROESPORTIVOBRASILEIRO.COM.BR

set -e

# Parâmetros padrão
RESOURCE_GROUP_NAME=${1:-"tiroesportivo-rg"}
WEB_APP_NAME=${2:-"tiroesportivobrasileiro"}
LOCATION=${3:-"East US"}
APP_SERVICE_PLAN=${4:-"tiroesportivo-plan"}
CUSTOM_DOMAIN=${5:-"tiroesportivobrasileiro.com.br"}
SKU=${6:-"S1"}

# Função para exibir ajuda
show_help() {
    echo "🎯 Deploy - Tiro Esportivo Brasileiro"
    echo "🌐 Domínio Personalizado: TIROESPORTIVOBRASILEIRO.COM.BR"
    echo ""
    echo "Uso: $0 [resource-group] [web-app-name] [location] [app-service-plan] [custom-domain] [sku]"
    echo ""
    echo "Parâmetros (todos opcionais):"
    echo "  resource-group    Nome do Resource Group (padrão: tiroesportivo-rg)"
    echo "  web-app-name     Nome da Web App (padrão: tiroesportivobrasileiro)"
    echo "  location         Região do Azure (padrão: East US)"
    echo "  app-service-plan Nome do App Service Plan (padrão: tiroesportivo-plan)"
    echo "  custom-domain    Domínio personalizado (padrão: tiroesportivobrasileiro.com.br)"
    echo "  sku              SKU do App Service Plan (padrão: S1)"
    echo ""
    echo "Exemplo:"
    echo "  $0"
    echo "  $0 meu-rg minha-app"
    echo ""
    exit 1
}

# Verificar se é pedido de ajuda
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
fi

echo "🎯 Deploy - Tiro Esportivo Brasileiro"
echo "🌐 Domínio: $CUSTOM_DOMAIN"
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

# Criar App Service Plan (S1 para suportar domínio personalizado)
echo "🏗️ Criando App Service Plan: $APP_SERVICE_PLAN (SKU: $SKU)"
az appservice plan create \
    --name "$APP_SERVICE_PLAN" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --location "$LOCATION" \
    --sku "$SKU" \
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
        SECRET_KEY="tiroesportivobrasileiro-azure-secret-key-2024" \
        CUSTOM_DOMAIN="$CUSTOM_DOMAIN" \
        FORCE_HTTPS=true \
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
    --src "$CURRENT_DIR/tiroesportivobrasileiro.zip"

# Aguardar deploy
echo "⏳ Aguardando conclusão do deploy..."
sleep 30

# Obter URL temporária
TEMP_URL=$(az webapp show --name "$WEB_APP_NAME" --resource-group "$RESOURCE_GROUP_NAME" --query "defaultHostName" -o tsv)
TEMP_FULL_URL="https://$TEMP_URL"

echo ""
echo "✅ Deploy inicial concluído!"
echo "🌐 URL temporária: $TEMP_FULL_URL"

# Configurar domínio personalizado
echo ""
echo "🔧 Configurando domínio personalizado..."

# Obter ID de verificação de domínio
VERIFICATION_ID=$(az webapp show \
    --name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --query "customDomainVerificationId" -o tsv)

echo "📋 ID de Verificação de Domínio: $VERIFICATION_ID"
echo ""
echo "⚠️  IMPORTANTE: Configure os seguintes registros DNS:"
echo "   Tipo: TXT"
echo "   Nome: asuid"
echo "   Valor: $VERIFICATION_ID"
echo ""
echo "   Tipo: CNAME"
echo "   Nome: @"
echo "   Valor: $TEMP_URL"
echo ""

# Perguntar se DNS foi configurado
read -p "DNS foi configurado? Aguarde a propagação e digite 'y' para continuar (y/n): " DNS_CONFIGURED

if [ "$DNS_CONFIGURED" = "y" ] || [ "$DNS_CONFIGURED" = "Y" ]; then
    echo "🌐 Adicionando domínio personalizado..."
    
    # Adicionar domínio personalizado
    if az webapp config hostname add \
        --webapp-name "$WEB_APP_NAME" \
        --resource-group "$RESOURCE_GROUP_NAME" \
        --hostname "$CUSTOM_DOMAIN"; then
        
        echo "✅ Domínio personalizado adicionado!"
        
        # Configurar SSL
        echo "🔒 Configurando certificado SSL..."
        
        # Aguardar um pouco para o domínio ser reconhecido
        sleep 30
        
        # Criar certificado gerenciado
        if az webapp config ssl create \
            --resource-group "$RESOURCE_GROUP_NAME" \
            --name "$WEB_APP_NAME" \
            --hostname "$CUSTOM_DOMAIN"; then
            
            # Obter thumbprint do certificado
            THUMBPRINT=$(az webapp config ssl list \
                --resource-group "$RESOURCE_GROUP_NAME" \
                --query "[?subjectName=='$CUSTOM_DOMAIN'].thumbprint" \
                --output tsv)
            
            if [ -n "$THUMBPRINT" ]; then
                # Vincular certificado
                az webapp config ssl bind \
                    --resource-group "$RESOURCE_GROUP_NAME" \
                    --name "$WEB_APP_NAME" \
                    --certificate-thumbprint "$THUMBPRINT" \
                    --ssl-type SNI
                
                echo "✅ SSL configurado com sucesso!"
            else
                echo "⚠️  Certificado SSL não pôde ser criado automaticamente."
                echo "   Configure manualmente no Portal Azure."
            fi
        else
            echo "⚠️  Erro ao criar certificado SSL."
            echo "   Configure manualmente no Portal Azure."
        fi
        
    else
        echo "⚠️  Erro ao configurar domínio personalizado."
        echo "   Verifique a configuração DNS e tente novamente."
        echo "   Ou configure manualmente no Portal Azure."
    fi
fi

# URLs finais
CUSTOM_URL="https://$CUSTOM_DOMAIN"

echo ""
echo "🎉 Deploy concluído com sucesso!"
echo "🌐 URL principal: $CUSTOM_URL"
echo "🌐 URL temporária: $TEMP_FULL_URL"
echo ""
echo "👤 Credenciais de acesso:"
echo "   - Demo: demo / demo123"
echo "   - Admin: admin / admin123"
echo ""
echo "📊 Para monitorar a aplicação:"
echo "   az webapp log tail --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP_NAME"
echo ""
echo "🔧 Para configurar SSL manualmente:"
echo "   1. Acesse portal.azure.com"
echo "   2. Vá para sua Web App > TLS/SSL settings"
echo "   3. Crie um certificado gerenciado"
echo "   4. Vincule ao domínio $CUSTOM_DOMAIN"
echo ""

# Abrir aplicação no navegador
read -p "Deseja abrir a aplicação no navegador? (y/n): " OPEN_BROWSER
if [ "$OPEN_BROWSER" = "y" ] || [ "$OPEN_BROWSER" = "Y" ]; then
    if [ "$DNS_CONFIGURED" = "y" ] || [ "$DNS_CONFIGURED" = "Y" ]; then
        URL_TO_OPEN="$CUSTOM_URL"
    else
        URL_TO_OPEN="$TEMP_FULL_URL"
    fi
    
    if command -v xdg-open &> /dev/null; then
        xdg-open "$URL_TO_OPEN"
    elif command -v open &> /dev/null; then
        open "$URL_TO_OPEN"
    else
        echo "Abra manualmente: $URL_TO_OPEN"
    fi
fi

