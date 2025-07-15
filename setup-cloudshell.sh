#!/bin/bash

# Azure Cloud Shell Setup - Tiro Esportivo Brasileiro
# TIROESPORTIVOBRASILEIRO.COM.BR
# Otimizado para Azure Cloud Shell com ferramentas pré-instaladas

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configurações fixas para Cloud Shell
SUBSCRIPTION_ID="130706ec-b9d5-4554-8be1-ef855c2cf41a"
RESOURCE_GROUP_NAME="tiroesportivo"
PROJECT_NAME="TiroEsportivoBrasileiro"
LOCATION="East US"

# Parâmetros
ORGANIZATION_NAME=${1}

# Função para exibir banner
show_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║           🎯 TIRO ESPORTIVO BRASILEIRO                       ║"
    echo "║              Azure Cloud Shell Setup                        ║"
    echo "║                                                              ║"
    echo "║           TIROESPORTIVOBRASILEIRO.COM.BR                     ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Função para exibir ajuda
show_help() {
    echo ""
    echo -e "${YELLOW}🚀 Azure Cloud Shell Setup - Tiro Esportivo Brasileiro${NC}"
    echo ""
    echo -e "${BLUE}Uso:${NC} $0 <organization-name>"
    echo ""
    echo -e "${BLUE}Parâmetros:${NC}"
    echo "  organization-name    Nome da organização Azure DevOps (obrigatório)"
    echo ""
    echo -e "${BLUE}Configurações automáticas:${NC}"
    echo "  Subscription ID: $SUBSCRIPTION_ID"
    echo "  Resource Group:  $RESOURCE_GROUP_NAME"
    echo "  Project Name:    $PROJECT_NAME"
    echo "  Location:        $LOCATION"
    echo ""
    echo -e "${BLUE}Exemplo:${NC}"
    echo "  $0 minha-empresa"
    echo ""
    echo -e "${BLUE}Resultado:${NC}"
    echo "  https://dev.azure.com/minha-empresa/TiroEsportivoBrasileiro"
    echo ""
}

# Função para log com timestamp
log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"
}

# Função para log de erro
error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Função para log de warning
warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Função para log de info
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Verificar parâmetros
if [[ -z "$ORGANIZATION_NAME" ]]; then
    error "Nome da organização é obrigatório"
    show_help
    exit 1
fi

# Mostrar banner
show_banner

log "🚀 Iniciando setup para organização: $ORGANIZATION_NAME"
log "📋 Configurações:"
echo "   • Organization: $ORGANIZATION_NAME"
echo "   • Project: $PROJECT_NAME"
echo "   • Subscription: $SUBSCRIPTION_ID"
echo "   • Resource Group: $RESOURCE_GROUP_NAME"
echo "   • Location: $LOCATION"
echo ""

# Verificar se estamos no Cloud Shell
if [[ -z "$AZURE_HTTP_USER_AGENT" ]]; then
    warning "Este script foi otimizado para Azure Cloud Shell"
    warning "Algumas funcionalidades podem não funcionar em outros ambientes"
fi

# Verificar ferramentas (já instaladas no Cloud Shell)
log "🔧 Verificando ferramentas do Cloud Shell..."

# Azure CLI (sempre disponível no Cloud Shell)
if command -v az &> /dev/null; then
    AZ_VERSION=$(az version --query '"azure-cli"' -o tsv)
    info "✅ Azure CLI: $AZ_VERSION"
else
    error "Azure CLI não encontrado"
    exit 1
fi

# Git (sempre disponível no Cloud Shell)
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version | cut -d' ' -f3)
    info "✅ Git: $GIT_VERSION"
else
    error "Git não encontrado"
    exit 1
fi

# jq (sempre disponível no Cloud Shell)
if command -v jq &> /dev/null; then
    JQ_VERSION=$(jq --version)
    info "✅ jq: $JQ_VERSION"
else
    error "jq não encontrado"
    exit 1
fi

# Verificar autenticação (automática no Cloud Shell)
log "🔐 Verificando autenticação Azure..."
CURRENT_USER=$(az account show --query "user.name" -o tsv 2>/dev/null || echo "")
if [[ -n "$CURRENT_USER" ]]; then
    info "✅ Autenticado como: $CURRENT_USER"
else
    error "Não autenticado no Azure"
    exit 1
fi

# Configurar subscription
log "⚙️ Configurando subscription..."
az account set --subscription "$SUBSCRIPTION_ID"
CURRENT_SUBSCRIPTION=$(az account show --query "name" -o tsv)
info "✅ Subscription ativa: $CURRENT_SUBSCRIPTION"

# Instalar extensão Azure DevOps (se não estiver instalada)
log "📦 Verificando extensão Azure DevOps..."
if ! az extension list --query "[?name=='azure-devops'].name" -o tsv | grep -q "azure-devops"; then
    log "Instalando extensão Azure DevOps..."
    az extension add --name azure-devops --yes
    info "✅ Extensão Azure DevOps instalada"
else
    info "✅ Extensão Azure DevOps já instalada"
fi

# Configurar organização padrão do Azure DevOps
log "🏢 Configurando Azure DevOps..."
az devops configure --defaults organization="https://dev.azure.com/$ORGANIZATION_NAME" project="$PROJECT_NAME"
info "✅ Organização configurada: https://dev.azure.com/$ORGANIZATION_NAME"

# Verificar se o projeto existe
log "🔍 Verificando projeto Azure DevOps..."
if az devops project show --project "$PROJECT_NAME" --query "name" -o tsv &> /dev/null; then
    info "✅ Projeto já existe: $PROJECT_NAME"
else
    log "Criando projeto Azure DevOps..."
    az devops project create \
        --name "$PROJECT_NAME" \
        --description "Sistema de controle de tiro esportivo - TIROESPORTIVOBRASILEIRO.COM.BR" \
        --visibility private \
        --process Agile
    info "✅ Projeto criado: $PROJECT_NAME"
fi

# Criar Service Principal
log "🔑 Criando Service Principal..."
SP_NAME="TiroEsportivo-CloudShell-$(date +%Y%m%d-%H%M)"
SP_CREDENTIALS=$(az ad sp create-for-rbac \
    --name "$SP_NAME" \
    --role contributor \
    --scopes "/subscriptions/$SUBSCRIPTION_ID" \
    --sdk-auth)

if [[ -n "$SP_CREDENTIALS" ]]; then
    info "✅ Service Principal criado: $SP_NAME"
    
    # Extrair informações do JSON
    CLIENT_ID=$(echo "$SP_CREDENTIALS" | jq -r '.clientId')
    CLIENT_SECRET=$(echo "$SP_CREDENTIALS" | jq -r '.clientSecret')
    TENANT_ID=$(echo "$SP_CREDENTIALS" | jq -r '.tenantId')
    
    # Salvar credenciais em arquivo no Cloud Shell storage
    CREDENTIALS_FILE="$HOME/tiroesportivo-credentials.json"
    echo "$SP_CREDENTIALS" > "$CREDENTIALS_FILE"
    
    echo ""
    echo -e "${PURPLE}📋 Credenciais do Service Principal:${NC}"
    echo -e "${CYAN}Client ID:${NC} $CLIENT_ID"
    echo -e "${CYAN}Client Secret:${NC} $CLIENT_SECRET"
    echo -e "${CYAN}Tenant ID:${NC} $TENANT_ID"
    echo -e "${CYAN}Subscription ID:${NC} $SUBSCRIPTION_ID"
    echo ""
    echo -e "${YELLOW}💾 Credenciais salvas em: $CREDENTIALS_FILE${NC}"
    echo -e "${YELLOW}🔒 Mantenha essas credenciais seguras!${NC}"
    echo ""
fi

# Criar repositório Git
log "📁 Configurando repositório Git..."
if az repos show --repository "$PROJECT_NAME" --query "name" -o tsv &> /dev/null; then
    info "✅ Repositório já existe: $PROJECT_NAME"
else
    log "Criando repositório Git..."
    az repos create --name "$PROJECT_NAME" --project "$PROJECT_NAME"
    info "✅ Repositório criado: $PROJECT_NAME"
fi

# Criar variáveis de pipeline
log "📊 Configurando variáveis de pipeline..."
declare -A variables=(
    ["subscriptionId"]="$SUBSCRIPTION_ID"
    ["resourceGroupName"]="$RESOURCE_GROUP_NAME"
    ["webAppName"]="tiroesportivobrasileiro"
    ["domainName"]="tiroesportivobrasileiro.com.br"
    ["location"]="$LOCATION"
    ["azureSubscription"]="Azure-Connection"
)

for var_name in "${!variables[@]}"; do
    var_value="${variables[$var_name]}"
    if az pipelines variable create --name "$var_name" --value "$var_value" --project "$PROJECT_NAME" &> /dev/null; then
        info "✅ Variável criada: $var_name"
    else
        warning "⚠️ Variável já existe: $var_name"
    fi
done

# Criar environments
log "🌍 Criando environments..."
environments=("development" "production" "infrastructure")
for env in "${environments[@]}"; do
    ENV_JSON=$(cat <<EOF
{
    "name": "$env",
    "description": "Environment for $env - TIROESPORTIVOBRASILEIRO.COM.BR"
}
EOF
)
    
    if echo "$ENV_JSON" | az devops invoke \
        --area distributedtask \
        --resource environments \
        --route-parameters project="$PROJECT_NAME" \
        --http-method POST \
        --in-file /dev/stdin &> /dev/null; then
        info "✅ Environment criado: $env"
    else
        warning "⚠️ Environment já existe: $env"
    fi
done

# Criar diretório de trabalho no Cloud Shell
WORK_DIR="$HOME/tiroesportivo"
log "📂 Criando diretório de trabalho..."
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Clonar repositório
log "📥 Clonando repositório..."
REPO_URL="https://dev.azure.com/$ORGANIZATION_NAME/$PROJECT_NAME/_git/$PROJECT_NAME"
if [[ -d "$PROJECT_NAME" ]]; then
    warning "Diretório já existe, removendo..."
    rm -rf "$PROJECT_NAME"
fi

git clone "$REPO_URL" || {
    warning "Repositório vazio, criando estrutura inicial..."
    mkdir -p "$PROJECT_NAME"
    cd "$PROJECT_NAME"
    git init
    git remote add origin "$REPO_URL"
}

cd "$PROJECT_NAME" 2>/dev/null || cd "$PROJECT_NAME"

# Criar estrutura inicial do projeto
log "🏗️ Criando estrutura do projeto..."

# README.md
cat > README.md << 'EOF'
# 🎯 Tiro Esportivo Brasileiro

Sistema completo de controle de tiro esportivo com CI/CD automatizado.

## TIROESPORTIVOBRASILEIRO.COM.BR

### 🚀 Desenvolvido com Azure DevOps + Cloud Shell

- **Subscription ID**: 130706ec-b9d5-4554-8be1-ef855c2cf41a
- **Resource Group**: tiroesportivo
- **Domínio**: tiroesportivobrasileiro.com.br

### 👤 Credenciais de Acesso
- **Demo**: demo / demo123
- **Admin**: admin / admin123

### 🌐 URLs
- **Produção**: https://tiroesportivobrasileiro.com.br
- **Desenvolvimento**: https://tiroesportivobrasileiro-dev.azurewebsites.net
EOF

# .gitignore
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Virtual Environment
venv/
env/
ENV/

# Flask
instance/
.webassets-cache
*.db
*.sqlite
*.sqlite3

# Environment Variables
.env
.env.local

# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*

# Frontend Build
frontend/dist/
frontend/build/

# Logs
logs
*.log

# Azure
.azure/
*.publishsettings

# Local development
.DS_Store
Thumbs.db
*.tmp
*.temp

# Secrets
secrets.json
service-principal-credentials.json
EOF

# Commit inicial
if [[ -n "$(git status --porcelain)" ]]; then
    log "📝 Fazendo commit inicial..."
    git add .
    git commit -m "feat: setup inicial via Azure Cloud Shell

- Projeto configurado via Cloud Shell
- Subscription: 130706ec-b9d5-4554-8be1-ef855c2cf41a
- Resource Group: tiroesportivo
- Domínio: tiroesportivobrasileiro.com.br"
    
    git push -u origin main || git push -u origin master
    info "✅ Commit inicial realizado"
fi

# Mostrar resumo final
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    🎉 SETUP CONCLUÍDO!                      ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}📋 Resumo da Configuração:${NC}"
echo -e "${BLUE}Organization:${NC} $ORGANIZATION_NAME"
echo -e "${BLUE}Project:${NC} $PROJECT_NAME"
echo -e "${BLUE}Subscription:${NC} $SUBSCRIPTION_ID"
echo -e "${BLUE}Resource Group:${NC} $RESOURCE_GROUP_NAME"
echo ""
echo -e "${CYAN}🌐 URLs Importantes:${NC}"
echo -e "${BLUE}Azure DevOps:${NC} https://dev.azure.com/$ORGANIZATION_NAME/$PROJECT_NAME"
echo -e "${BLUE}Repositório:${NC} https://dev.azure.com/$ORGANIZATION_NAME/$PROJECT_NAME/_git/$PROJECT_NAME"
echo -e "${BLUE}Pipelines:${NC} https://dev.azure.com/$ORGANIZATION_NAME/$PROJECT_NAME/_build"
echo ""
echo -e "${CYAN}📂 Diretório de Trabalho:${NC}"
echo -e "${BLUE}Local:${NC} $WORK_DIR/$PROJECT_NAME"
echo -e "${BLUE}Credenciais:${NC} $CREDENTIALS_FILE"
echo ""
echo -e "${CYAN}📋 Próximos Passos:${NC}"
echo -e "${YELLOW}1.${NC} Configure Service Connection no Azure DevOps"
echo -e "${YELLOW}2.${NC} Faça upload dos arquivos do projeto"
echo -e "${YELLOW}3.${NC} Configure os pipelines"
echo -e "${YELLOW}4.${NC} Execute o pipeline de infraestrutura"
echo -e "${YELLOW}5.${NC} Configure DNS no registrador"
echo ""
echo -e "${GREEN}✅ Tudo pronto para TIROESPORTIVOBRASILEIRO.COM.BR!${NC}"
echo ""

# Instruções para Service Connection
echo -e "${PURPLE}🔗 Configuração do Service Connection:${NC}"
echo ""
echo -e "${YELLOW}1. Acesse:${NC} https://dev.azure.com/$ORGANIZATION_NAME/$PROJECT_NAME/_settings/adminservices"
echo -e "${YELLOW}2. Clique:${NC} New service connection → Azure Resource Manager"
echo -e "${YELLOW}3. Escolha:${NC} Service principal (manual)"
echo -e "${YELLOW}4. Configure:${NC}"
echo "   • Subscription ID: $SUBSCRIPTION_ID"
echo "   • Subscription Name: $CURRENT_SUBSCRIPTION"
echo "   • Service Principal ID: $CLIENT_ID"
echo "   • Service Principal Key: $CLIENT_SECRET"
echo "   • Tenant ID: $TENANT_ID"
echo -e "${YELLOW}5. Nome:${NC} Azure-Connection"
echo -e "${YELLOW}6. Marque:${NC} Grant access permission to all pipelines"
echo ""
echo -e "${RED}⚠️ IMPORTANTE:${NC} Guarde as credenciais em local seguro!"
echo -e "${RED}⚠️ Arquivo:${NC} $CREDENTIALS_FILE"
echo ""

