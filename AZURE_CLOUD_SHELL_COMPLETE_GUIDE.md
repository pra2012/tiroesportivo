# 🌐 Guia Completo - Azure Cloud Shell
## TIROESPORTIVOBRASILEIRO.COM.BR

**Subscription ID**: `130706ec-b9d5-4554-8be1-ef855c2cf41a`  
**Resource Group**: `tiroesportivo`  
**Domínio**: `tiroesportivobrasileiro.com.br`

---

## 🚀 Vantagens do Azure Cloud Shell

### ✅ **Pré-configurado**
- **Azure CLI** já instalado e autenticado
- **Git, Node.js, Python** pré-instalados
- **Extensões Azure DevOps** disponíveis
- **Storage persistente** para arquivos

### ✅ **Sem Setup Local**
- **Sem instalações** necessárias
- **Acesso via browser** de qualquer lugar
- **Ambiente consistente** sempre atualizado
- **Credenciais automáticas** do Azure

### ✅ **Integração Nativa**
- **Subscription** já configurada
- **Permissões** automáticas
- **Ferramentas** otimizadas para Azure
- **Performance** otimizada

---

## ⚡ Setup Completo em 3 Comandos

### **1. Acesse Azure Cloud Shell**
```
https://shell.azure.com
```
*Ou clique no ícone Cloud Shell no portal Azure*

### **2. Execute Setup Inicial**
```bash
# Download dos scripts
curl -sSL https://raw.githubusercontent.com/tiroesportivo/scripts/main/setup-cloudshell.sh -o setup-cloudshell.sh
chmod +x setup-cloudshell.sh

# Execute (substitua SUA-ORG pelo nome da sua organização)
./setup-cloudshell.sh SUA-ORG
```

### **3. Upload do Projeto**
```bash
# Download e execute
curl -sSL https://raw.githubusercontent.com/tiroesportivo/scripts/main/upload-project.sh -o upload-project.sh
chmod +x upload-project.sh

./upload-project.sh SUA-ORG
```

### **4. Configure Pipelines**
```bash
# Download e execute
curl -sSL https://raw.githubusercontent.com/tiroesportivo/scripts/main/configure-pipelines.sh -o configure-pipelines.sh
chmod +x configure-pipelines.sh

./configure-pipelines.sh SUA-ORG
```

---

## 📋 Processo Detalhado

### **Passo 1: Preparação do Ambiente**

#### **1.1 Acesso ao Cloud Shell**
1. Acesse [shell.azure.com](https://shell.azure.com)
2. Escolha **Bash** como shell
3. Aguarde inicialização (primeira vez pode demorar)
4. Verifique se está na subscription correta:
   ```bash
   az account show --query "id" -o tsv
   # Deve retornar: 130706ec-b9d5-4554-8be1-ef855c2cf41a
   ```

#### **1.2 Configurar Subscription (se necessário)**
```bash
# Se não estiver na subscription correta
az account set --subscription "130706ec-b9d5-4554-8be1-ef855c2cf41a"
```

#### **1.3 Verificar Ferramentas**
```bash
# Verificar versões
az --version
git --version
python3 --version
node --version
```

### **Passo 2: Setup do Projeto Azure DevOps**

#### **2.1 Executar Script de Setup**
```bash
# Fazer download do script
curl -sSL https://example.com/setup-cloudshell.sh -o setup-cloudshell.sh
chmod +x setup-cloudshell.sh

# Executar (substitua 'minha-empresa' pela sua organização)
./setup-cloudshell.sh minha-empresa
```

#### **2.2 O que o Script Faz**
- ✅ Instala extensão Azure DevOps
- ✅ Cria projeto "TiroEsportivoBrasileiro"
- ✅ Cria Service Principal
- ✅ Configura variáveis de pipeline
- ✅ Cria environments (dev, prod, infra)
- ✅ Inicializa repositório Git
- ✅ Salva credenciais em `~/tiroesportivo-credentials.json`

#### **2.3 Resultado Esperado**
```
✅ Projeto criado: https://dev.azure.com/minha-empresa/TiroEsportivoBrasileiro
✅ Service Principal criado
✅ Credenciais salvas em: ~/tiroesportivo-credentials.json
```

### **Passo 3: Upload dos Arquivos do Projeto**

#### **3.1 Executar Script de Upload**
```bash
# Fazer download do script
curl -sSL https://example.com/upload-project.sh -o upload-project.sh
chmod +x upload-project.sh

# Executar
./upload-project.sh minha-empresa
```

#### **3.2 Estrutura Criada**
```
TiroEsportivoBrasileiro/
├── azure-pipelines.yml          # Pipeline principal CI/CD
├── infrastructure-pipeline.yml  # Pipeline de infraestrutura
├── src/
│   └── main.py                  # Backend Flask
├── frontend/
│   ├── src/
│   │   ├── App.jsx             # Frontend React
│   │   └── main.jsx
│   ├── public/
│   │   └── index.html
│   ├── package.json
│   └── vite.config.js
├── tests/
│   └── test_main.py            # Testes automatizados
├── requirements.txt            # Dependências Python
├── startup.py                  # Script de inicialização
├── web.config                  # Configuração IIS
├── pytest.ini                 # Configuração de testes
├── .gitignore
└── README.md
```

### **Passo 4: Configurar Service Connection**

#### **4.1 Acessar Azure DevOps**
```
https://dev.azure.com/SUA-ORG/TiroEsportivoBrasileiro/_settings/adminservices
```

#### **4.2 Criar Service Connection**
1. **Clique**: "New service connection"
2. **Selecione**: "Azure Resource Manager"
3. **Escolha**: "Service principal (manual)"
4. **Preencha**:
   ```
   Subscription ID: 130706ec-b9d5-4554-8be1-ef855c2cf41a
   Subscription Name: (será preenchido automaticamente)
   Service Principal ID: (do arquivo ~/tiroesportivo-credentials.json)
   Service Principal Key: (do arquivo ~/tiroesportivo-credentials.json)
   Tenant ID: (do arquivo ~/tiroesportivo-credentials.json)
   ```
5. **Nome**: `Azure-Connection`
6. **Marque**: "Grant access permission to all pipelines"
7. **Clique**: "Verify and save"

#### **4.3 Verificar Credenciais**
```bash
# Ver credenciais salvas
cat ~/tiroesportivo-credentials.json | jq '.'
```

### **Passo 5: Configurar Pipelines**

#### **5.1 Executar Script de Configuração**
```bash
# Fazer download do script
curl -sSL https://example.com/configure-pipelines.sh -o configure-pipelines.sh
chmod +x configure-pipelines.sh

# Executar
./configure-pipelines.sh minha-empresa
```

#### **5.2 O que o Script Faz**
- ✅ Cria pipeline de infraestrutura
- ✅ Cria pipeline principal CI/CD
- ✅ Configura branch policies
- ✅ Configura variáveis de pipeline
- ✅ Executa pipeline de infraestrutura
- ✅ Mostra Name Servers DNS

#### **5.3 Pipelines Criados**
```
Infrastructure-Pipeline: Cria recursos Azure
Main-Pipeline: CI/CD da aplicação
```

### **Passo 6: Configurar DNS**

#### **6.1 Obter Name Servers**
```bash
# Obter Name Servers após pipeline de infraestrutura
az network dns zone show \
  --resource-group tiroesportivo \
  --name tiroesportivobrasileiro.com.br \
  --query "nameServers" \
  --output table
```

#### **6.2 Configurar no Registrador**
No painel do seu registrador de domínio, configure os Name Servers:
```
ns1-XX.azure-dns.com
ns2-XX.azure-dns.net
ns3-XX.azure-dns.org
ns4-XX.azure-dns.info
```

#### **6.3 Verificar Propagação**
```bash
# Verificar propagação DNS (pode demorar até 48h)
nslookup tiroesportivobrasileiro.com.br
dig tiroesportivobrasileiro.com.br
```

### **Passo 7: Deploy da Aplicação**

#### **7.1 Executar Pipeline Principal**
```bash
# Via Azure CLI
az pipelines run --name "Main-Pipeline"

# Ou acesse via browser
# https://dev.azure.com/SUA-ORG/TiroEsportivoBrasileiro/_build
```

#### **7.2 Acompanhar Deploy**
```bash
# Listar execuções
az pipelines runs list --pipeline-name "Main-Pipeline" --top 5

# Ver detalhes de uma execução
az pipelines runs show --id RUN_ID
```

---

## 🔧 Comandos Úteis do Cloud Shell

### **Gerenciamento de Arquivos**
```bash
# Navegar para diretório do projeto
cd ~/tiroesportivo/TiroEsportivoBrasileiro

# Editar arquivos
code arquivo.py          # VS Code integrado
nano arquivo.py          # Editor nano
vim arquivo.py           # Editor vim

# Upload de arquivos locais
# Use o botão "Upload/Download files" no Cloud Shell
```

### **Git Operations**
```bash
# Status do repositório
git status

# Fazer commit
git add .
git commit -m "feat: nova funcionalidade"
git push origin main

# Criar branch
git checkout -b feature/nova-funcionalidade
git push -u origin feature/nova-funcionalidade
```

### **Azure CLI - Recursos**
```bash
# Listar recursos do Resource Group
az resource list --resource-group tiroesportivo --output table

# Status das Web Apps
az webapp list --resource-group tiroesportivo --output table

# Logs da aplicação
az webapp log tail --name tiroesportivobrasileiro --resource-group tiroesportivo

# Restart da aplicação
az webapp restart --name tiroesportivobrasileiro --resource-group tiroesportivo
```

### **Azure DevOps CLI**
```bash
# Listar projetos
az devops project list

# Listar pipelines
az pipelines list

# Executar pipeline
az pipelines run --name "Pipeline-Name"

# Ver execuções recentes
az pipelines runs list --top 10

# Ver variáveis de pipeline
az pipelines variable list --pipeline-name "Pipeline-Name"
```

### **Monitoramento**
```bash
# Health check da aplicação
curl https://tiroesportivobrasileiro.com.br/api/health

# Informações da aplicação
curl https://tiroesportivobrasileiro.com.br/api/info

# Teste de conectividade
ping tiroesportivobrasileiro.com.br
```

---

## 🛠️ Troubleshooting

### **Problema: Service Connection Falha**
```bash
# Verificar Service Principal
az ad sp list --display-name "TiroEsportivo-CloudShell-*"

# Verificar permissões
az role assignment list --assignee CLIENT_ID --scope "/subscriptions/130706ec-b9d5-4554-8be1-ef855c2cf41a"

# Recriar Service Principal se necessário
az ad sp create-for-rbac --name "TiroEsportivo-New" --role contributor --scopes "/subscriptions/130706ec-b9d5-4554-8be1-ef855c2cf41a"
```

### **Problema: Pipeline Falha**
```bash
# Ver logs detalhados
az pipelines runs show --id RUN_ID --query "logs" -o table

# Verificar variáveis
az pipelines variable list --pipeline-name "Pipeline-Name"

# Verificar Service Connection
az devops service-endpoint list --query "[?name=='Azure-Connection']"
```

### **Problema: DNS Não Resolve**
```bash
# Verificar Name Servers
az network dns zone show --resource-group tiroesportivo --name tiroesportivobrasileiro.com.br --query "nameServers"

# Verificar registros DNS
az network dns record-set list --resource-group tiroesportivo --zone-name tiroesportivobrasileiro.com.br

# Testar resolução
nslookup tiroesportivobrasileiro.com.br 8.8.8.8
```

### **Problema: Aplicação Não Carrega**
```bash
# Verificar status da Web App
az webapp show --name tiroesportivobrasileiro --resource-group tiroesportivo --query "state"

# Ver logs de aplicação
az webapp log tail --name tiroesportivobrasileiro --resource-group tiroesportivo

# Verificar configurações
az webapp config show --name tiroesportivobrasileiro --resource-group tiroesportivo

# Restart se necessário
az webapp restart --name tiroesportivobrasileiro --resource-group tiroesportivo
```

---

## 📊 Monitoramento e Manutenção

### **Health Checks Automáticos**
```bash
# Script de monitoramento
cat > ~/monitor.sh << 'EOF'
#!/bin/bash
echo "=== HEALTH CHECK - $(date) ==="
curl -s https://tiroesportivobrasileiro.com.br/api/health | jq '.'
echo ""
curl -s https://tiroesportivobrasileiro-dev.azurewebsites.net/api/health | jq '.'
EOF

chmod +x ~/monitor.sh
./monitor.sh
```

### **Backup de Configurações**
```bash
# Backup das credenciais
cp ~/tiroesportivo-credentials.json ~/backup-credentials-$(date +%Y%m%d).json

# Backup do código
cd ~/tiroesportivo/TiroEsportivoBrasileiro
git archive --format=zip --output=~/backup-code-$(date +%Y%m%d).zip HEAD
```

### **Atualizações**
```bash
# Atualizar extensões Azure CLI
az extension update --name azure-devops

# Verificar atualizações do projeto
cd ~/tiroesportivo/TiroEsportivoBrasileiro
git pull origin main
```

---

## 🎯 URLs Importantes

### **Aplicação**
- **Produção**: https://tiroesportivobrasileiro.com.br
- **Desenvolvimento**: https://tiroesportivobrasileiro-dev.azurewebsites.net

### **Azure DevOps**
- **Projeto**: https://dev.azure.com/SUA-ORG/TiroEsportivoBrasileiro
- **Pipelines**: https://dev.azure.com/SUA-ORG/TiroEsportivoBrasileiro/_build
- **Repositório**: https://dev.azure.com/SUA-ORG/TiroEsportivoBrasileiro/_git/TiroEsportivoBrasileiro

### **Azure Portal**
- **Resource Group**: https://portal.azure.com/#@/resource/subscriptions/130706ec-b9d5-4554-8be1-ef855c2cf41a/resourceGroups/tiroesportivo
- **Web Apps**: https://portal.azure.com/#@/resource/subscriptions/130706ec-b9d5-4554-8be1-ef855c2cf41a/resourceGroups/tiroesportivo/providers/Microsoft.Web/sites/tiroesportivobrasileiro
- **DNS Zone**: https://portal.azure.com/#@/resource/subscriptions/130706ec-b9d5-4554-8be1-ef855c2cf41a/resourceGroups/tiroesportivo/providers/Microsoft.Network/dnszones/tiroesportivobrasileiro.com.br

---

## 👤 Credenciais de Acesso

### **Aplicação**
- **Demo**: `demo` / `demo123`
- **Admin**: `admin` / `admin123`

### **Azure**
- **Subscription**: `130706ec-b9d5-4554-8be1-ef855c2cf41a`
- **Service Principal**: Salvo em `~/tiroesportivo-credentials.json`

---

## 🚀 Resumo do Fluxo Completo

```bash
# 1. Acesse Cloud Shell
https://shell.azure.com

# 2. Setup inicial (substitua SUA-ORG)
curl -sSL https://example.com/setup-cloudshell.sh -o setup-cloudshell.sh
chmod +x setup-cloudshell.sh
./setup-cloudshell.sh SUA-ORG

# 3. Upload do projeto
curl -sSL https://example.com/upload-project.sh -o upload-project.sh
chmod +x upload-project.sh
./upload-project.sh SUA-ORG

# 4. Configure Service Connection manualmente no Azure DevOps
# https://dev.azure.com/SUA-ORG/TiroEsportivoBrasileiro/_settings/adminservices

# 5. Configure pipelines
curl -sSL https://example.com/configure-pipelines.sh -o configure-pipelines.sh
chmod +x configure-pipelines.sh
./configure-pipelines.sh SUA-ORG

# 6. Configure DNS no registrador com os Name Servers fornecidos

# 7. Acesse sua aplicação
https://tiroesportivobrasileiro.com.br
```

---

## 🎉 Resultado Final

### ✅ **Infraestrutura Criada**
- Resource Group: `tiroesportivo`
- DNS Zone: `tiroesportivobrasileiro.com.br`
- Web App Produção: `tiroesportivobrasileiro`
- Web App Desenvolvimento: `tiroesportivobrasileiro-dev`
- App Service Plan: `tiroesportivo-plan`
- Application Insights: `tiroesportivo-insights`

### ✅ **CI/CD Configurado**
- Pipeline de infraestrutura automatizado
- Pipeline principal com CI/CD completo
- Deploy automático por branch
- Testes automatizados
- Health checks

### ✅ **Domínio Personalizado**
- SSL automático
- DNS gerenciado pelo Azure
- Redirecionamento HTTPS
- Certificados gerenciados

### ✅ **Monitoramento**
- Application Insights configurado
- Health checks automáticos
- Logs centralizados
- Métricas de performance

**🌐 Com Azure Cloud Shell, você tem uma solução enterprise-grade para TIROESPORTIVOBRASILEIRO.COM.BR sem necessidade de configuração local!**

