# 🎯 Tiro Esportivo Brasileiro - Azure DevOps

## TIROESPORTIVOBRASILEIRO.COM.BR

Sistema completo de controle de tiro esportivo com CI/CD automatizado via Azure DevOps.

---

## 🚀 Quick Start

### **1. Clone do Repositório**
```bash
git clone https://dev.azure.com/tiroesportivo/TiroEsportivoBrasileiro/_git/TiroEsportivoBrasileiro
cd TiroEsportivoBrasileiro
```

### **2. Configuração Local**
```bash
# Backend
python -m venv venv
source venv/bin/activate  # Linux/macOS
# ou
venv\Scripts\activate     # Windows

pip install -r requirements.txt
python populate_db.py

# Frontend
cd frontend
npm install
npm run dev
```

### **3. Deploy Automático**
- **Push para `develop`** → Deploy automático para ambiente de desenvolvimento
- **Push para `main`** → Deploy automático para produção

---

## 📁 Estrutura do Projeto

```
TiroEsportivoBrasileiro/
├── 📁 src/                     # Backend Flask
│   ├── 📁 models/              # Modelos de dados
│   ├── 📁 routes/              # Rotas da API
│   └── main.py                 # Aplicação principal
├── 📁 frontend/                # Frontend React
│   ├── 📁 src/                 # Código fonte React
│   ├── 📁 public/              # Arquivos públicos
│   └── package.json            # Dependências Node.js
├── 📁 azure-devops/            # Configurações DevOps
│   ├── azure-pipelines.yml    # Pipeline principal
│   └── infrastructure-pipeline.yml # Pipeline de infraestrutura
├── 📁 docs/                    # Documentação
├── requirements.txt            # Dependências Python
├── startup.py                  # Script de inicialização Azure
└── web.config                  # Configuração IIS
```

---

## 🔄 Pipelines

### **Pipeline Principal** (`azure-pipelines.yml`)
- **Trigger**: Push para `main` ou `develop`
- **Stages**:
  1. **Build** - Compila backend e frontend
  2. **Deploy Dev** - Deploy para desenvolvimento (branch `develop`)
  3. **Deploy Prod** - Deploy para produção (branch `main`)
  4. **Post-Deploy** - Health checks e notificações

### **Pipeline de Infraestrutura** (`infrastructure-pipeline.yml`)
- **Trigger**: Mudanças em arquivos de infraestrutura
- **Stages**:
  1. **Validate** - Valida templates e configurações
  2. **Deploy** - Cria/atualiza recursos Azure
  3. **Validate** - Verifica recursos criados

---

## 🌐 Ambientes

### **🔧 Desenvolvimento**
- **URL**: https://tiroesportivobrasileiro-dev.azurewebsites.net
- **Branch**: `develop`
- **Deploy**: Automático via pipeline
- **Configuração**: Ambiente de testes

### **🚀 Produção**
- **URL**: https://tiroesportivobrasileiro.com.br
- **Branch**: `main`
- **Deploy**: Automático via pipeline
- **Configuração**: Ambiente de produção com SSL

---

## 📊 Recursos Azure

### **Resource Group**: `tiroesportivo`
- **DNS Zone**: `tiroesportivobrasileiro.com.br`
- **App Service Plan**: `tiroesportivo-plan` (S1)
- **Web App Prod**: `tiroesportivobrasileiro`
- **Web App Dev**: `tiroesportivobrasileiro-dev`
- **Application Insights**: `tiroesportivo-insights`

---

## 🔐 Configuração de Service Connection

### **1. Criar Service Principal**
```bash
az ad sp create-for-rbac --name "TiroEsportivo-DevOps" --role contributor --scopes /subscriptions/{subscription-id}
```

### **2. Configurar no Azure DevOps**
1. Acesse **Project Settings** → **Service connections**
2. Crie nova **Azure Resource Manager** connection
3. Use as credenciais do Service Principal
4. Nome: `Azure-Connection`

---

## 🔧 Variáveis de Pipeline

### **Variáveis Globais**
```yaml
resourceGroupName: 'tiroesportivo'
webAppName: 'tiroesportivobrasileiro'
domainName: 'tiroesportivobrasileiro.com.br'
azureSubscription: 'Azure-Connection'
```

### **Variáveis de Ambiente**
- `FLASK_ENV`: production/development
- `SECRET_KEY`: Chave secreta da aplicação
- `CUSTOM_DOMAIN`: Domínio personalizado
- `AZURE_DNS_ENABLED`: true/false

---

## 🚦 Workflow de Desenvolvimento

### **1. Feature Development**
```bash
git checkout develop
git checkout -b feature/nova-funcionalidade
# Desenvolver funcionalidade
git add .
git commit -m "feat: nova funcionalidade"
git push origin feature/nova-funcionalidade
```

### **2. Pull Request**
- Criar PR para `develop`
- Pipeline executa testes automaticamente
- Após aprovação, merge para `develop`
- Deploy automático para ambiente de desenvolvimento

### **3. Release para Produção**
```bash
git checkout main
git merge develop
git push origin main
```
- Deploy automático para produção
- Configuração de domínio personalizado e SSL

---

## 📈 Monitoramento

### **Application Insights**
- **Logs**: Monitoramento em tempo real
- **Métricas**: Performance e utilização
- **Alertas**: Notificações automáticas

### **Health Checks**
- **Endpoint**: `/api/health`
- **Verificação**: Automática após deploy
- **Alertas**: Falhas são notificadas

---

## 👤 Credenciais de Acesso

### **Usuários Demo**
- **Demo**: `demo` / `demo123`
- **Admin**: `admin` / `admin123`

---

## 🛠️ Comandos Úteis

### **Logs da Aplicação**
```bash
# Produção
az webapp log tail --name tiroesportivobrasileiro --resource-group tiroesportivo

# Desenvolvimento
az webapp log tail --name tiroesportivobrasileiro-dev --resource-group tiroesportivo
```

### **Status da Aplicação**
```bash
az webapp show --name tiroesportivobrasileiro --resource-group tiroesportivo --query "state"
```

### **Restart da Aplicação**
```bash
az webapp restart --name tiroesportivobrasileiro --resource-group tiroesportivo
```

---

## 📚 Documentação Adicional

- [Guia de Setup Azure DevOps](docs/azure-devops-setup.md)
- [Configuração de DNS](docs/dns-configuration.md)
- [Troubleshooting](docs/troubleshooting.md)
- [API Documentation](docs/api-documentation.md)

---

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 📞 Suporte

- **Email**: suporte@tiroesportivobrasileiro.com.br
- **Issues**: Use o sistema de issues do Azure DevOps
- **Wiki**: Documentação completa no Azure DevOps Wiki

---

**🎯 Desenvolvido com ❤️ para a comunidade de Tiro Esportivo Brasileiro**

