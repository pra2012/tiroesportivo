# 🚀 Quick Start - Shooting Sports no Azure Web App

## ⚡ Deploy em 5 Minutos

### 1. Pré-requisitos
```bash
# Instalar Azure CLI
winget install Microsoft.AzureCLI  # Windows
brew install azure-cli            # macOS
```

### 2. Login no Azure
```bash
az login
```

### 3. Deploy Automatizado
```powershell
# Windows PowerShell
cd azure-deployment
.\deploy-azure.ps1 -ResourceGroupName "shooting-sports-rg" -WebAppName "shooting-sports-app"
```

```bash
# Linux/macOS
cd azure-deployment
chmod +x deploy-azure.sh
./deploy-azure.sh shooting-sports-rg shooting-sports-app
```

### 4. Acessar Aplicação
- **URL**: `https://shooting-sports-app.azurewebsites.net`
- **Demo**: demo / demo123
- **Admin**: admin / admin123

## 📦 Arquivos Incluídos

- `shooting-sports-azure.zip` - Pacote completo para deploy
- `deploy-azure.ps1` - Script automatizado de deploy
- `web.config` - Configuração IIS para Azure
- `startup.py` - Arquivo de inicialização
- `requirements.txt` - Dependências Python

## 🔧 Deploy Manual Rápido

### Via Portal Azure:
1. Criar Web App (Python 3.11, Linux)
2. Upload do arquivo `shooting-sports-azure.zip`
3. Configurar Startup Command: `startup.py`

### Via Azure CLI:
```bash
# Criar recursos
az group create --name shooting-sports-rg --location "East US"
az appservice plan create --name shooting-sports-plan --resource-group shooting-sports-rg --sku B1 --is-linux
az webapp create --name shooting-sports-app --resource-group shooting-sports-rg --plan shooting-sports-plan --runtime "PYTHON:3.11"

# Deploy
az webapp deployment source config-zip --name shooting-sports-app --resource-group shooting-sports-rg --src shooting-sports-azure.zip
```

## 💡 Dicas Importantes

- **Nome da Web App deve ser único globalmente**
- **Use B1 Basic para testes, S1 Standard para produção**
- **Logs disponíveis em tempo real via Azure CLI**
- **Aplicação inclui dados de demonstração pré-carregados**

## 📞 Suporte Rápido

```bash
# Ver logs
az webapp log tail --name shooting-sports-app --resource-group shooting-sports-rg

# Reiniciar app
az webapp restart --name shooting-sports-app --resource-group shooting-sports-rg

# Status da app
az webapp show --name shooting-sports-app --resource-group shooting-sports-rg --query "state"
```

---
**✅ Pronto! Sua aplicação Shooting Sports está rodando no Azure!**

