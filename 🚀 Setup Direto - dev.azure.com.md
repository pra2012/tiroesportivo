# 🚀 Setup Direto - dev.azure.com
## TIROESPORTIVOBRASILEIRO.COM.BR

**Subscription ID**: `130706ec-b9d5-4554-8be1-ef855c2cf41a`  
**Resource Group**: `tiroesportivo`

---

## ⚡ Setup Rápido (5 minutos)

### **1. Executar Script de Setup**

#### **Windows PowerShell**
```powershell
.\setup-azure-devops.ps1 -OrganizationName "SUA-ORG-AQUI"
```

#### **Linux/macOS Bash**
```bash
./setup-azure-devops.sh SUA-ORG-AQUI
```

### **2. Acessar dev.azure.com**
```
https://dev.azure.com/SUA-ORG-AQUI/TiroEsportivoBrasileiro
```

### **3. Configurar Service Connection**
1. **Acesse**: Project Settings → Service connections
2. **Clique**: New service connection → Azure Resource Manager
3. **Escolha**: Service principal (manual)
4. **Configure**:
   - **Subscription ID**: `130706ec-b9d5-4554-8be1-ef855c2cf41a`
   - **Subscription Name**: (será preenchido automaticamente)
   - **Service Principal ID**: (do arquivo gerado)
   - **Service Principal Key**: (do arquivo gerado)
   - **Tenant ID**: (do arquivo gerado)
5. **Nome**: `Azure-Connection`
6. **Salvar**

---

## 📁 Estrutura de Arquivos para Upload

### **Arquivos Principais**
```
TiroEsportivoBrasileiro/
├── azure-pipelines.yml          # Pipeline principal
├── infrastructure-pipeline.yml  # Pipeline de infraestrutura
├── src/                         # Backend Flask
├── frontend/                    # Frontend React
├── requirements.txt             # Dependências Python
├── startup.py                   # Script de inicialização
├── web.config                   # Configuração IIS
└── README.md                    # Documentação
```

### **Upload no Azure DevOps**
1. **Acesse**: Repos → Files
2. **Upload**: Todos os arquivos do projeto
3. **Commit**: "Initial setup - TIROESPORTIVOBRASILEIRO.COM.BR"

---

## ⚙️ Configurar Pipelines

### **Pipeline Principal**
1. **Acesse**: Pipelines → New pipeline
2. **Selecione**: Azure Repos Git
3. **Escolha**: TiroEsportivoBrasileiro
4. **Configure**: Existing Azure Pipelines YAML file
5. **Caminho**: `/azure-pipelines.yml`
6. **Save and run**

### **Pipeline de Infraestrutura**
1. **Acesse**: Pipelines → New pipeline
2. **Selecione**: Azure Repos Git
3. **Escolha**: TiroEsportivoBrasileiro
4. **Configure**: Existing Azure Pipelines YAML file
5. **Caminho**: `/infrastructure-pipeline.yml`
6. **Save and run**

---

## 🌍 Environments

### **Criar Environments**
1. **Acesse**: Pipelines → Environments
2. **Criar**:
   - `development`
   - `production` 
   - `infrastructure`

---

## 📊 Variáveis de Pipeline

### **Library → Variable groups**
Criar grupo: `TiroEsportivo-Variables`

```yaml
resourceGroupName: tiroesportivo
webAppName: tiroesportivobrasileiro
domainName: tiroesportivobrasileiro.com.br
location: East US
azureSubscription: Azure-Connection
subscriptionId: 130706ec-b9d5-4554-8be1-ef855c2cf41a
```

---

## 🔧 Configurações Específicas

### **Branch Policies**
1. **Acesse**: Project Settings → Repositories
2. **Branch**: main
3. **Policies**:
   - ✅ Require a minimum number of reviewers (1)
   - ✅ Check for linked work items
   - ✅ Check for comment resolution
   - ✅ Limit merge types (Squash merge only)

### **Security**
1. **Acesse**: Project Settings → Permissions
2. **Configure**: Build Service permissions
3. **Grant**: Contributor access to Resource Group

---

## 🚀 Primeiro Deploy

### **1. Execute Pipeline de Infraestrutura**
- Cria Resource Group `tiroesportivo`
- Cria DNS Zone `tiroesportivobrasileiro.com.br`
- Cria Web Apps de desenvolvimento e produção

### **2. Configure DNS no Registrador**
Após pipeline de infraestrutura, configure no registrador do domínio:
```
Name Servers: (serão fornecidos pelo pipeline)
ns1-XX.azure-dns.com
ns2-XX.azure-dns.net
ns3-XX.azure-dns.org
ns4-XX.azure-dns.info
```

### **3. Execute Pipeline Principal**
- Build da aplicação
- Deploy para desenvolvimento
- Deploy para produção (branch main)

---

## 📋 Checklist de Verificação

### **✅ Pré-Deploy**
- [ ] Service Connection configurado
- [ ] Pipelines criados
- [ ] Environments criados
- [ ] Variáveis configuradas
- [ ] Branch policies ativadas

### **✅ Pós-Deploy**
- [ ] Infraestrutura criada no Azure
- [ ] DNS configurado no registrador
- [ ] Aplicação acessível em desenvolvimento
- [ ] Aplicação acessível em produção
- [ ] SSL funcionando
- [ ] Monitoramento ativo

---

## 🌐 URLs Finais

### **Desenvolvimento**
```
https://tiroesportivobrasileiro-dev.azurewebsites.net
```

### **Produção**
```
https://tiroesportivobrasileiro.com.br
```

### **Azure DevOps**
```
https://dev.azure.com/SUA-ORG-AQUI/TiroEsportivoBrasileiro
```

---

## 👤 Credenciais de Acesso

### **Aplicação**
- **Demo**: `demo` / `demo123`
- **Admin**: `admin` / `admin123`

---

## 🆘 Suporte Rápido

### **Logs da Aplicação**
```bash
az webapp log tail --name tiroesportivobrasileiro --resource-group tiroesportivo
```

### **Status dos Recursos**
```bash
az resource list --resource-group tiroesportivo --output table
```

### **Restart da Aplicação**
```bash
az webapp restart --name tiroesportivobrasileiro --resource-group tiroesportivo
```

---

## 🎯 Comandos de Exemplo

### **Setup Completo**
```powershell
# Windows
.\setup-azure-devops.ps1 -OrganizationName "minha-empresa"

# Resultado: Projeto criado em
# https://dev.azure.com/minha-empresa/TiroEsportivoBrasileiro
```

```bash
# Linux/macOS
./setup-azure-devops.sh minha-empresa

# Resultado: Projeto criado em
# https://dev.azure.com/minha-empresa/TiroEsportivoBrasileiro
```

---

**🚀 Com estes arquivos, você tem tudo pronto para usar diretamente no dev.azure.com com a Subscription ID 130706ec-b9d5-4554-8be1-ef855c2cf41a configurada!**

