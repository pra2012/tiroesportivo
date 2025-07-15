# 🚀 Guia Completo - Azure DevOps CI/CD
## TIROESPORTIVOBRASILEIRO.COM.BR

Sistema completo de CI/CD para implementação automatizada da aplicação Tiro Esportivo Brasileiro usando Azure DevOps.

---

## 📋 Índice

1. [Visão Geral](#-visão-geral)
2. [Pré-requisitos](#-pré-requisitos)
3. [Setup Inicial](#-setup-inicial)
4. [Configuração de Pipelines](#-configuração-de-pipelines)
5. [Workflow de Desenvolvimento](#-workflow-de-desenvolvimento)
6. [Ambientes](#-ambientes)
7. [Monitoramento](#-monitoramento)
8. [Troubleshooting](#-troubleshooting)
9. [Melhores Práticas](#-melhores-práticas)

---

## 🎯 Visão Geral

### **Arquitetura CI/CD**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Desenvolver   │    │   Azure DevOps  │    │     Azure       │
│                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │   Código    │─┼────┼→│  Pipeline   │─┼────┼→│  Web Apps   │ │
│ │   (Git)     │ │    │ │   (YAML)    │ │    │ │             │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
│                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │ Pull Request│ │    │ │ Environments│ │    │ │  DNS Zone   │ │
│ │             │ │    │ │             │ │    │ │             │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### **Fluxo de Deploy**
1. **Desenvolvimento** → Push para `develop` → Deploy automático para ambiente de desenvolvimento
2. **Produção** → Push para `main` → Deploy automático para produção com domínio personalizado
3. **Infraestrutura** → Mudanças em arquivos de infraestrutura → Deploy de recursos Azure

---

## 🔧 Pré-requisitos

### **Ferramentas Necessárias**
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (versão 2.30+)
- [Git](https://git-scm.com/downloads)
- [Node.js](https://nodejs.org/) (versão 20+)
- [Python](https://python.org/) (versão 3.11+)
- [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell) (Windows/Linux/macOS)

### **Contas e Permissões**
- **Azure Subscription** com permissões de Contributor
- **Azure DevOps Organization** com permissões de Project Administrator
- **Domínio** registrado (tiroesportivobrasileiro.com.br)

### **Recursos Azure**
- **Resource Group**: `tiroesportivo`
- **Subscription**: Ativa e configurada
- **Região**: East US (ou preferida)

---

## 🚀 Setup Inicial

### **1. Executar Script de Setup**

#### **Windows (PowerShell)**
```powershell
cd azure-devops/scripts
.\setup-azure-devops.ps1 -OrganizationName "sua-org" -SubscriptionId "12345678-1234-1234-1234-123456789012"
```

#### **Linux/macOS (Bash)**
```bash
cd azure-devops/scripts
./setup-azure-devops.sh sua-org TiroEsportivoBrasileiro 12345678-1234-1234-1234-123456789012
```

### **2. Configurar Service Connection**

1. **Acesse Azure DevOps**:
   ```
   https://dev.azure.com/sua-org/TiroEsportivoBrasileiro/_settings/adminservices
   ```

2. **Criar Nova Service Connection**:
   - Clique em "New service connection"
   - Selecione "Azure Resource Manager"
   - Escolha "Service principal (manual)"

3. **Configurar Credenciais**:
   - Use as credenciais do arquivo `service-principal-credentials.json`
   - Nome da conexão: `Azure-Connection`
   - Marque "Grant access permission to all pipelines"

4. **Verificar Conexão**:
   - Teste a conexão
   - Salve a configuração

### **3. Configurar Repositório Git**

```bash
# Clonar repositório
git clone https://dev.azure.com/sua-org/TiroEsportivoBrasileiro/_git/TiroEsportivoBrasileiro
cd TiroEsportivoBrasileiro

# Adicionar arquivos do projeto
cp -r /caminho/para/projeto/* .

# Commit inicial
git add .
git commit -m "feat: setup inicial do projeto"
git push origin main
```

---

## ⚙️ Configuração de Pipelines

### **1. Pipeline Principal** (`azure-pipelines.yml`)

#### **Configuração no Azure DevOps**:
1. Acesse **Pipelines** → **New pipeline**
2. Selecione **Azure Repos Git**
3. Escolha o repositório **TiroEsportivoBrasileiro**
4. Selecione **Existing Azure Pipelines YAML file**
5. Caminho: `/azure-pipelines.yml`
6. Salve e execute

#### **Triggers Configurados**:
```yaml
trigger:
  branches:
    include:
    - main
    - develop
  paths:
    exclude:
    - README.md
    - docs/*
```

#### **Stages do Pipeline**:
1. **Build** - Compila backend (Flask) e frontend (React)
2. **Deploy Dev** - Deploy para desenvolvimento (branch `develop`)
3. **Deploy Prod** - Deploy para produção (branch `main`)
4. **Post-Deploy** - Health checks e notificações

### **2. Pipeline de Infraestrutura** (`infrastructure-pipeline.yml`)

#### **Configuração**:
1. Acesse **Pipelines** → **New pipeline**
2. Selecione **Azure Repos Git**
3. Escolha o repositório **TiroEsportivoBrasileiro**
4. Selecione **Existing Azure Pipelines YAML file**
5. Caminho: `/infrastructure-pipeline.yml`
6. Salve e execute

#### **Recursos Criados**:
- **Resource Group**: `tiroesportivo`
- **DNS Zone**: `tiroesportivobrasileiro.com.br`
- **App Service Plan**: `tiroesportivo-plan` (S1)
- **Web App Prod**: `tiroesportivobrasileiro`
- **Web App Dev**: `tiroesportivobrasileiro-dev`
- **Application Insights**: `tiroesportivo-insights`

---

## 🔄 Workflow de Desenvolvimento

### **1. Desenvolvimento de Features**

```bash
# Criar branch de feature
git checkout develop
git pull origin develop
git checkout -b feature/nova-funcionalidade

# Desenvolver funcionalidade
# ... código ...

# Commit e push
git add .
git commit -m "feat: implementa nova funcionalidade"
git push origin feature/nova-funcionalidade
```

### **2. Pull Request**

1. **Criar PR** no Azure DevOps:
   - Source: `feature/nova-funcionalidade`
   - Target: `develop`
   - Use o template de PR

2. **Pipeline Automático**:
   - Build automático é executado
   - Testes são executados
   - Validações de qualidade

3. **Review e Aprovação**:
   - Revisão de código obrigatória
   - Aprovação necessária para merge

4. **Merge para Develop**:
   - Deploy automático para ambiente de desenvolvimento
   - URL: https://tiroesportivobrasileiro-dev.azurewebsites.net

### **3. Release para Produção**

```bash
# Merge develop para main
git checkout main
git pull origin main
git merge develop
git push origin main
```

- **Deploy Automático** para produção
- **Configuração de DNS** e SSL automática
- **URL Final**: https://tiroesportivobrasileiro.com.br

---

## 🌍 Ambientes

### **🔧 Desenvolvimento**
```yaml
Environment: development
URL: https://tiroesportivobrasileiro-dev.azurewebsites.net
Branch: develop
Deploy: Automático
Configuração:
  FLASK_ENV: development
  AZURE_DNS_ENABLED: false
  CUSTOM_DOMAIN: tiroesportivobrasileiro-dev.azurewebsites.net
```

### **🚀 Produção**
```yaml
Environment: production
URL: https://tiroesportivobrasileiro.com.br
Branch: main
Deploy: Automático
Configuração:
  FLASK_ENV: production
  AZURE_DNS_ENABLED: true
  CUSTOM_DOMAIN: tiroesportivobrasileiro.com.br
  FORCE_HTTPS: true
```

### **🏗️ Infraestrutura**
```yaml
Environment: infrastructure
Trigger: Mudanças em arquivos de infraestrutura
Deploy: Manual ou automático
Recursos: DNS Zone, Web Apps, App Service Plan
```

---

## 📊 Monitoramento

### **Application Insights**
- **Logs**: Monitoramento em tempo real
- **Métricas**: Performance e utilização
- **Alertas**: CPU > 80%, HTTP 5xx > 10

### **Health Checks**
```bash
# Endpoint de saúde
curl https://tiroesportivobrasileiro.com.br/api/health

# Resposta esperada
{
  "status": "healthy",
  "timestamp": "2024-01-01T12:00:00Z",
  "version": "1.0.0"
}
```

### **Logs da Aplicação**
```bash
# Produção
az webapp log tail --name tiroesportivobrasileiro --resource-group tiroesportivo

# Desenvolvimento
az webapp log tail --name tiroesportivobrasileiro-dev --resource-group tiroesportivo
```

---

## 🔧 Troubleshooting

### **Problemas Comuns**

#### **1. Pipeline Falha no Build**
```bash
# Verificar logs do pipeline
# Acessar Azure DevOps → Pipelines → Build específico → Logs

# Problemas comuns:
- Dependências Python não instaladas
- Testes falhando
- Problemas de sintaxe
```

#### **2. Deploy Falha**
```bash
# Verificar Service Connection
# Azure DevOps → Project Settings → Service connections → Azure-Connection

# Verificar permissões
az role assignment list --assignee <service-principal-id> --scope /subscriptions/<subscription-id>
```

#### **3. Aplicação Não Responde**
```bash
# Verificar status da Web App
az webapp show --name tiroesportivobrasileiro --resource-group tiroesportivo --query "state"

# Restart da aplicação
az webapp restart --name tiroesportivobrasileiro --resource-group tiroesportivo

# Verificar logs
az webapp log tail --name tiroesportivobrasileiro --resource-group tiroesportivo
```

#### **4. DNS Não Resolve**
```bash
# Verificar Name Servers
az network dns zone show --resource-group tiroesportivo --name tiroesportivobrasileiro.com.br --query "nameServers"

# Testar resolução DNS
nslookup tiroesportivobrasileiro.com.br
dig tiroesportivobrasileiro.com.br
```

### **Comandos de Diagnóstico**

```bash
# Status geral dos recursos
az resource list --resource-group tiroesportivo --output table

# Verificar Web App
az webapp list --resource-group tiroesportivo --output table

# Verificar DNS Zone
az network dns zone list --resource-group tiroesportivo --output table

# Verificar registros DNS
az network dns record-set list --resource-group tiroesportivo --zone-name tiroesportivobrasileiro.com.br --output table
```

---

## 🏆 Melhores Práticas

### **1. Desenvolvimento**
- **Branches**: Use feature branches para desenvolvimento
- **Commits**: Mensagens claras e descritivas
- **Testes**: Sempre adicione testes para novas funcionalidades
- **Code Review**: Revisão obrigatória antes do merge

### **2. Pipelines**
- **Paralelização**: Execute builds em paralelo quando possível
- **Cache**: Use cache para dependências
- **Artifacts**: Mantenha artifacts por tempo limitado
- **Secrets**: Use Azure Key Vault para secrets

### **3. Segurança**
- **Service Principal**: Rotacione credenciais regularmente
- **Permissions**: Princípio do menor privilégio
- **Secrets**: Nunca commite secrets no código
- **SSL**: Sempre use HTTPS em produção

### **4. Monitoramento**
- **Alertas**: Configure alertas para métricas críticas
- **Logs**: Mantenha logs estruturados
- **Health Checks**: Implemente endpoints de saúde
- **Backup**: Configure backup automático

---

## 📚 Recursos Adicionais

### **Documentação**
- [Azure DevOps Documentation](https://docs.microsoft.com/en-us/azure/devops/)
- [Azure App Service Documentation](https://docs.microsoft.com/en-us/azure/app-service/)
- [Azure DNS Documentation](https://docs.microsoft.com/en-us/azure/dns/)

### **Templates e Exemplos**
- [Azure DevOps YAML Schema](https://docs.microsoft.com/en-us/azure/devops/pipelines/yaml-schema)
- [Pipeline Templates](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/templates)

### **Ferramentas**
- [Azure DevOps CLI](https://docs.microsoft.com/en-us/azure/devops/cli/)
- [Azure Resource Manager Tools](https://marketplace.visualstudio.com/items?itemName=msazurermtools.azurerm-vscode-tools)

---

## 🎯 Conclusão

Com esta configuração de Azure DevOps, você tem:

✅ **CI/CD Completo** - Deploy automático para desenvolvimento e produção  
✅ **Infraestrutura como Código** - Recursos Azure gerenciados via pipeline  
✅ **Domínio Personalizado** - TIROESPORTIVOBRASILEIRO.COM.BR com SSL  
✅ **Monitoramento** - Application Insights e alertas configurados  
✅ **Segurança** - Service Principal e permissões adequadas  
✅ **Qualidade** - Code review obrigatório e testes automatizados  

**🌐 Acesse**: https://tiroesportivobrasileiro.com.br  
**👤 Credenciais**: demo/demo123 | admin/admin123

---

**🚀 Desenvolvido com Azure DevOps para máxima eficiência e confiabilidade!**

