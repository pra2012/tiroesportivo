# 🎯 Guia de Deploy - Shooting Sports no Azure Web App

## 📋 Visão Geral

Este guia fornece instruções completas para fazer deploy da aplicação **Shooting Sports** no Microsoft Azure Web App. A aplicação é um sistema completo de controle de tiro esportivo com autenticação, gestão de arsenal, ranking e sistema de níveis.

## 🏗️ Arquitetura da Aplicação

- **Frontend**: React + Vite (SPA)
- **Backend**: Flask + SQLAlchemy
- **Banco de Dados**: SQLite
- **Autenticação**: JWT
- **Deploy**: Azure Web App (Python 3.11)

## 📦 Pré-requisitos

### 1. Azure CLI
```bash
# Windows
winget install Microsoft.AzureCLI

# macOS
brew install azure-cli

# Linux
curl -sL https://aka.ms/InstallAzureCLI | sudo bash
```

### 2. Conta Azure
- Conta Azure ativa
- Permissões para criar recursos
- Subscription válida

### 3. PowerShell (Windows) ou Bash (Linux/macOS)

## 🚀 Métodos de Deploy

### Método 1: Deploy Automatizado (Recomendado)

#### Windows PowerShell:
```powershell
# Navegar para o diretório de deployment
cd azure-deployment

# Executar script de deploy
.\deploy-azure.ps1 -ResourceGroupName "shooting-sports-rg" -WebAppName "shooting-sports-app"
```

#### Parâmetros do Script:
- `ResourceGroupName`: Nome do Resource Group (obrigatório)
- `WebAppName`: Nome da Web App (obrigatório)
- `Location`: Região do Azure (opcional, padrão: "East US")
- `AppServicePlan`: Nome do App Service Plan (opcional)

### Método 2: Deploy Manual via Azure CLI

#### 1. Login no Azure
```bash
az login
```

#### 2. Criar Resource Group
```bash
az group create --name shooting-sports-rg --location "East US"
```

#### 3. Criar App Service Plan
```bash
az appservice plan create \
  --name shooting-sports-plan \
  --resource-group shooting-sports-rg \
  --location "East US" \
  --sku B1 \
  --is-linux
```

#### 4. Criar Web App
```bash
az webapp create \
  --name shooting-sports-app \
  --resource-group shooting-sports-rg \
  --plan shooting-sports-plan \
  --runtime "PYTHON:3.11"
```

#### 5. Configurar Variáveis de Ambiente
```bash
az webapp config appsettings set \
  --name shooting-sports-app \
  --resource-group shooting-sports-rg \
  --settings \
    FLASK_ENV=production \
    SECRET_KEY="shooting-sports-azure-secret-key-2024" \
    SCM_DO_BUILD_DURING_DEPLOYMENT=true \
    ENABLE_ORYX_BUILD=true \
    WEBSITES_ENABLE_APP_SERVICE_STORAGE=true
```

#### 6. Configurar Startup Command
```bash
az webapp config set \
  --name shooting-sports-app \
  --resource-group shooting-sports-rg \
  --startup-file "startup.py"
```

#### 7. Deploy do Código
```bash
az webapp deployment source config-zip \
  --name shooting-sports-app \
  --resource-group shooting-sports-rg \
  --src shooting-sports-azure.zip
```

### Método 3: Deploy via Portal Azure

#### 1. Acessar Portal Azure
- Acesse [portal.azure.com](https://portal.azure.com)
- Faça login com sua conta

#### 2. Criar Web App
1. Clique em "Create a resource"
2. Procure por "Web App"
3. Clique em "Create"

#### 3. Configurar Web App
- **Subscription**: Selecione sua subscription
- **Resource Group**: Crie novo "shooting-sports-rg"
- **Name**: "shooting-sports-app" (deve ser único)
- **Publish**: Code
- **Runtime stack**: Python 3.11
- **Operating System**: Linux
- **Region**: East US
- **App Service Plan**: Criar novo (B1 Basic)

#### 4. Deploy do Código
1. Vá para a Web App criada
2. No menu lateral, clique em "Deployment Center"
3. Selecione "ZIP Deploy"
4. Faça upload do arquivo `shooting-sports-azure.zip`
5. Clique em "Deploy"

#### 5. Configurar Startup Command
1. No menu lateral, clique em "Configuration"
2. Na aba "General settings"
3. Em "Startup Command", digite: `startup.py`
4. Clique em "Save"

## ⚙️ Configurações Importantes

### Variáveis de Ambiente
```
FLASK_ENV=production
SECRET_KEY=shooting-sports-azure-secret-key-2024
SCM_DO_BUILD_DURING_DEPLOYMENT=true
ENABLE_ORYX_BUILD=true
WEBSITES_ENABLE_APP_SERVICE_STORAGE=true
```

### Arquivos de Configuração

#### web.config
Configuração para IIS no Azure, incluindo:
- Redirecionamento para Python
- Configurações de arquivos estáticos
- Regras de reescrita para SPA

#### startup.py
Arquivo de inicialização que:
- Configura logging para Azure
- Inicializa banco de dados
- Popula dados iniciais se necessário

#### requirements.txt
Dependências Python otimizadas para Azure

## 🔐 Credenciais de Acesso

Após o deploy, use estas credenciais para acessar a aplicação:

### Usuário Demonstração
- **Usuário**: `demo`
- **Senha**: `demo123`

### Usuário Administrador
- **Usuário**: `admin`
- **Senha**: `admin123`

## 📊 Monitoramento e Logs

### Visualizar Logs em Tempo Real
```bash
az webapp log tail --name shooting-sports-app --resource-group shooting-sports-rg
```

### Baixar Logs
```bash
az webapp log download --name shooting-sports-app --resource-group shooting-sports-rg
```

### Portal Azure
1. Acesse sua Web App no Portal Azure
2. No menu lateral, clique em "Log stream"
3. Visualize logs em tempo real

## 🔧 Solução de Problemas

### Problema: Aplicação não inicia
**Solução**: Verificar logs de startup
```bash
az webapp log tail --name shooting-sports-app --resource-group shooting-sports-rg
```

### Problema: Erro 500 Internal Server Error
**Possíveis causas**:
- Banco de dados não inicializado
- Dependências não instaladas
- Configurações incorretas

**Solução**: Verificar logs e redeployar

### Problema: Frontend não carrega
**Possíveis causas**:
- Arquivos estáticos não copiados
- Configuração de reescrita incorreta

**Solução**: Verificar se pasta `static` contém os arquivos do build

### Problema: API não responde
**Possíveis causas**:
- CORS não configurado
- Rotas não registradas

**Solução**: Verificar configuração do Flask

## 🔄 Atualizações

### Para atualizar a aplicação:

1. **Fazer novo build do frontend**:
```bash
cd shooting-sports-frontend
npm run build
```

2. **Copiar arquivos atualizados**:
```bash
cp -r dist/* ../azure-deployment/static/
```

3. **Criar novo ZIP**:
```bash
cd azure-deployment
zip -r shooting-sports-azure.zip . -x "*.git*" "node_modules/*" "__pycache__/*" "*.pyc"
```

4. **Fazer redeploy**:
```bash
az webapp deployment source config-zip \
  --name shooting-sports-app \
  --resource-group shooting-sports-rg \
  --src shooting-sports-azure.zip
```

## 💰 Custos Estimados

### App Service Plan B1 (Basic)
- **Preço**: ~$13.14 USD/mês
- **Recursos**: 1.75 GB RAM, 10 GB Storage
- **Adequado para**: Desenvolvimento e testes

### Para Produção (Recomendado: S1 Standard)
- **Preço**: ~$56.94 USD/mês
- **Recursos**: 1.75 GB RAM, 50 GB Storage
- **Recursos adicionais**: Custom domains, SSL certificates

## 📞 Suporte

### Recursos Úteis
- [Documentação Azure Web Apps](https://docs.microsoft.com/azure/app-service/)
- [Troubleshooting Python on Azure](https://docs.microsoft.com/azure/app-service/configure-language-python)
- [Azure CLI Reference](https://docs.microsoft.com/cli/azure/)

### Comandos Úteis
```bash
# Verificar status da aplicação
az webapp show --name shooting-sports-app --resource-group shooting-sports-rg

# Reiniciar aplicação
az webapp restart --name shooting-sports-app --resource-group shooting-sports-rg

# Verificar configurações
az webapp config show --name shooting-sports-app --resource-group shooting-sports-rg

# Listar aplicações
az webapp list --resource-group shooting-sports-rg
```

## ✅ Checklist de Deploy

- [ ] Azure CLI instalado e configurado
- [ ] Conta Azure com permissões adequadas
- [ ] Resource Group criado
- [ ] App Service Plan criado
- [ ] Web App criada
- [ ] Variáveis de ambiente configuradas
- [ ] Startup command configurado
- [ ] Código deployado via ZIP
- [ ] Aplicação acessível via URL
- [ ] Login funcionando com credenciais de teste
- [ ] Todas as funcionalidades testadas

---

## 🎉 Conclusão

Após seguir este guia, sua aplicação **Shooting Sports** estará rodando no Azure Web App, pronta para uso em produção. A aplicação oferece um sistema completo de controle de tiro esportivo com interface moderna e funcionalidades avançadas.

**URL da aplicação**: `https://[nome-da-webapp].azurewebsites.net`

Para suporte adicional ou dúvidas, consulte a documentação oficial do Azure ou entre em contato com a equipe de desenvolvimento.

