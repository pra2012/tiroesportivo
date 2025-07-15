#!/bin/bash

# Script para Configurar Azure DNS Zone
# Tiro Esportivo Brasileiro - TIROESPORTIVOBRASILEIRO.COM.BR

set -e

# Parâmetros padrão
RESOURCE_GROUP_NAME=${1:-"tiroesportivo"}
DOMAIN_NAME=${2:-"tiroesportivobrasileiro.com.br"}
LOCATION=${3:-"East US"}

# Função para exibir ajuda
show_help() {
    echo "🌐 Configuração Azure DNS Zone"
    echo ""
    echo "Uso: $0 [resource-group] [domain-name] [location]"
    echo ""
    echo "Parâmetros (todos opcionais):"
    echo "  resource-group    Nome do Resource Group (padrão: tiroesportivo)"
    echo "  domain-name      Nome do domínio (padrão: tiroesportivobrasileiro.com.br)"
    echo "  location         Região do Azure (padrão: East US)"
    echo ""
    echo "Exemplo:"
    echo "  $0"
    echo "  $0 meu-rg meudominio.com.br"
    echo ""
    exit 1
}

# Verificar se é pedido de ajuda
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
fi

echo "🌐 Configurando Azure DNS Zone para $DOMAIN_NAME"
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

# Criar Resource Group se não existir
echo "📦 Verificando/Criando Resource Group: $RESOURCE_GROUP_NAME"
RG_EXISTS=$(az group exists --name "$RESOURCE_GROUP_NAME")
if [ "$RG_EXISTS" = "false" ]; then
    az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION"
    echo "✅ Resource Group criado"
else
    echo "✅ Resource Group já existe"
fi

# Criar DNS Zone
echo "🌐 Criando DNS Zone para $DOMAIN_NAME..."
az network dns zone create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$DOMAIN_NAME"

echo "✅ DNS Zone criada com sucesso!"

# Obter Name Servers
echo "📋 Obtendo Name Servers..."
NAME_SERVERS=$(az network dns zone show \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$DOMAIN_NAME" \
    --query "nameServers" -o tsv)

echo ""
echo "🎯 IMPORTANTE: Configure os seguintes Name Servers no seu registrador de domínio:"
echo ""
for ns in $NAME_SERVERS; do
    echo "   $ns"
done
echo ""

# Criar registros DNS básicos
echo "📝 Criando registros DNS básicos..."

# Registro A para root domain (será atualizado depois com IP da Web App)
echo "   Criando registro A temporário..."
az network dns record-set a create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --zone-name "$DOMAIN_NAME" \
    --name "@" \
    --ttl 3600

# Registro CNAME para www
echo "   Criando registro CNAME para www..."
az network dns record-set cname create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --zone-name "$DOMAIN_NAME" \
    --name "www" \
    --ttl 3600

az network dns record-set cname set-record \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --zone-name "$DOMAIN_NAME" \
    --record-set-name "www" \
    --cname "$DOMAIN_NAME"

# Registros MX básicos (opcional)
echo "   Criando registros MX básicos..."
az network dns record-set mx create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --zone-name "$DOMAIN_NAME" \
    --name "@" \
    --ttl 3600

az network dns record-set mx add-record \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --zone-name "$DOMAIN_NAME" \
    --record-set-name "@" \
    --exchange "mail.$DOMAIN_NAME" \
    --preference 10

# Registro TXT para verificação
echo "   Criando registro TXT para verificação..."
az network dns record-set txt create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --zone-name "$DOMAIN_NAME" \
    --name "@" \
    --ttl 3600

az network dns record-set txt add-record \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --zone-name "$DOMAIN_NAME" \
    --record-set-name "@" \
    --value "v=spf1 -all"

echo "✅ Registros DNS básicos criados!"

# Mostrar resumo
echo ""
echo "📊 Resumo da Configuração:"
echo "   Resource Group: $RESOURCE_GROUP_NAME"
echo "   DNS Zone: $DOMAIN_NAME"
echo "   Location: $LOCATION"
echo ""

# Verificar zona DNS
echo "🔍 Verificando configuração da zona DNS..."
az network dns zone show \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$DOMAIN_NAME" \
    --query "{name:name,resourceGroup:resourceGroup,nameServers:nameServers}" \
    --output table

echo ""
echo "🎉 Azure DNS Zone configurada com sucesso!"
echo ""
echo "📋 Próximos passos:"
echo "   1. Configure os Name Servers no seu registrador de domínio"
echo "   2. Aguarde a propagação DNS (até 48 horas)"
echo "   3. Execute o script de deploy da Web App"
echo ""

# Salvar informações em arquivo
cat > dns-zone-info.json << EOF
{
  "ResourceGroup": "$RESOURCE_GROUP_NAME",
  "DomainName": "$DOMAIN_NAME",
  "NameServers": [
$(echo "$NAME_SERVERS" | sed 's/^/    "/' | sed 's/$/"/' | sed '$!s/$/,/')
  ],
  "CreatedAt": "$(date '+%Y-%m-%d %H:%M:%S')"
}
EOF

echo "💾 Informações salvas em: dns-zone-info.json"

echo ""
echo "🔧 Para verificar a propagação DNS:"
echo "   nslookup $DOMAIN_NAME"
echo "   dig $DOMAIN_NAME NS"

