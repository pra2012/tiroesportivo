# 🌐 Guia Completo - Azure DNS + TIROESPORTIVOBRASILEIRO.COM.BR

## Deploy Integrado: Azure DNS + Web App + SSL

Este guia fornece instruções completas para fazer deploy da aplicação **Tiro Esportivo Brasileiro** usando **Azure DNS** como provedor de DNS para o domínio **TIROESPORTIVOBRASILEIRO.COM.BR**.

---

## 🎯 Vantagens do Azure DNS

### ✅ **Benefícios**
- **Integração Nativa**: Gerenciamento completo dentro do Azure
- **Alta Disponibilidade**: 100% SLA para resolução DNS
- **Segurança**: DNSSEC suportado
- **Performance**: Rede global de servidores DNS
- **Automação**: Scripts integrados para deploy completo
- **Custo**: $0.50 por zona DNS + $0.40 por milhão de consultas

### 🔧 **Recursos Incluídos**
- DNS Zone automática
- Registros DNS configurados automaticamente
- Certificado SSL gerenciado
- Domínio personalizado integrado
- Monitoramento e logs centralizados

---

## 🚀 Deploy em 2 Comandos

### **Método Ultra-Rápido:**

#### 1. Configurar DNS Zone:
```powershell
# Windows
.\create-dns-zone.ps1
```
```bash
# Linux/macOS
./create-dns-zone.sh
```

#### 2. Deploy Completo:
```powershell
# Windows
.\deploy-with-azure-dns.ps1
```
```bash
# Linux/macOS
./deploy-with-azure-dns.sh
```

### **Resultado:**
- ✅ DNS Zone criada no Azure
- ✅ Web App deployada
- ✅ Domínio personalizado configurado
- ✅ SSL ativo
- ✅ Aplicação no ar em https://tiroesportivobrasileiro.com.br

---

## 📋 Pré-requisitos

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
- Subscription ativa
- Permissões para criar recursos
- Créditos para S1 Standard (~$57/mês)

### 3. Domínio Registrado
- **tiroesportivobrasileiro.com.br** registrado
- Acesso ao painel do registrador para alterar Name Servers

---

## 🌐 Processo Detalhado

### **ETAPA 1: Configurar Azure DNS Zone**

#### Executar Script:
```bash
./create-dns-zone.sh
```

#### O que acontece:
1. **Cria DNS Zone** no Azure para `tiroesportivobrasileiro.com.br`
2. **Gera Name Servers** do Azure DNS
3. **Cria registros básicos** (CNAME, TXT, MX)
4. **Salva informações** em `dns-zone-info.json`

#### Name Servers Gerados (exemplo):
```
ns1-01.azure-dns.com
ns2-01.azure-dns.net
ns3-01.azure-dns.org
ns4-01.azure-dns.info
```

#### **IMPORTANTE**: Configure estes Name Servers no seu registrador de domínio!

### **ETAPA 2: Aguardar Propagação DNS**
- **Tempo**: 15 minutos a 48 horas
- **Verificar**: `nslookup tiroesportivobrasileiro.com.br`
- **Ferramentas**: [DNS Checker](https://dnschecker.org/)

### **ETAPA 3: Deploy Completo**

#### Executar Script:
```bash
./deploy-with-azure-dns.sh
```

#### O que acontece:
1. **Verifica/Cria DNS Zone** (se não existir)
2. **Cria Web App** com Python 3.11
3. **Configura registros DNS** automaticamente
4. **Adiciona domínio personalizado** à Web App
5. **Cria certificado SSL** gerenciado
6. **Vincula SSL** ao domínio
7. **Testa conectividade** e SSL

---

## 🔧 Configuração Manual (Alternativa)

### 1. Criar DNS Zone
```bash
# Criar Resource Group
az group create --name "tiroesportivo" --location "East US"

# Criar DNS Zone
az network dns zone create \
  --resource-group "tiroesportivo" \
  --name "tiroesportivobrasileiro.com.br"

# Obter Name Servers
az network dns zone show \
  --resource-group "tiroesportivo" \
  --name "tiroesportivobrasileiro.com.br" \
  --query "nameServers"
```

### 2. Configurar Registros DNS
```bash
# Registro CNAME para www
az network dns record-set cname create \
  --resource-group "tiroesportivo" \
  --zone-name "tiroesportivobrasileiro.com.br" \
  --name "www" \
  --ttl 3600

az network dns record-set cname set-record \
  --resource-group "tiroesportivo" \
  --zone-name "tiroesportivobrasileiro.com.br" \
  --record-set-name "www" \
  --cname "tiroesportivobrasileiro.com.br"
```

### 3. Criar Web App
```bash
# App Service Plan
az appservice plan create \
  --name "tiroesportivo-plan" \
  --resource-group "tiroesportivo" \
  --sku S1 \
  --is-linux

# Web App
az webapp create \
  --name "tiroesportivobrasileiro" \
  --resource-group "tiroesportivo" \
  --plan "tiroesportivo-plan" \
  --runtime "PYTHON:3.11"
```

### 4. Configurar Domínio e SSL
```bash
# Adicionar domínio personalizado
az webapp config hostname add \
  --webapp-name "tiroesportivobrasileiro" \
  --resource-group "tiroesportivo" \
  --hostname "tiroesportivobrasileiro.com.br"

# Criar certificado SSL
az webapp config ssl create \
  --resource-group "tiroesportivo" \
  --name "tiroesportivobrasileiro" \
  --hostname "tiroesportivobrasileiro.com.br"
```

---

## 📊 Recursos Criados

### **Azure DNS Zone**
```
Nome: tiroesportivobrasileiro.com.br
Tipo: Zona DNS pública
Registros: A, CNAME, TXT, MX
Name Servers: 4 servidores Azure DNS
Resource Group: tiroesportivo
```

### **Web App**
```
Nome: tiroesportivobrasileiro
Runtime: Python 3.11 (Linux)
Plan: S1 Standard
SSL: Certificado gerenciado
```

### **Registros DNS Automáticos**
```
@ (root)     CNAME → tiroesportivobrasileiro.azurewebsites.net
www          CNAME → tiroesportivobrasileiro.com.br
asuid        TXT   → [verification-id]
@            TXT   → v=spf1 -all
@            MX    → mail.tiroesportivobrasileiro.com.br (10)
```

---

## 🔒 Configurações de Segurança

### **SSL/TLS**
- **Certificado**: Gerenciado pelo Azure
- **Renovação**: Automática (30 dias antes do vencimento)
- **Grade SSL**: A+ (SSL Labs)
- **Protocolos**: TLS 1.2, TLS 1.3

### **Headers de Segurança**
```
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Content-Security-Policy: default-src 'self'
```

### **DNSSEC (Opcional)**
```bash
# Habilitar DNSSEC
az network dns zone update \
  --resource-group "tiroesportivo-rg" \
  --name "tiroesportivobrasileiro.com.br" \
  --enable-dnssec
```

---

## 📈 Monitoramento e Logs

### **Logs da Web App**
```bash
# Logs em tempo real
az webapp log tail \
  --name "tiroesportivobrasileiro" \
  --resource-group "tiroesportivo"

# Download de logs
az webapp log download \
  --name "tiroesportivobrasileiro" \
  --resource-group "tiroesportivo"
```

### **Métricas DNS**
```bash
# Consultas DNS
az monitor metrics list \
  --resource "/subscriptions/{subscription}/resourceGroups/tiroesportivo/providers/Microsoft.Network/dnszones/tiroesportivobrasileiro.com.br" \
  --metric "QueryVolume"
```

### **Application Insights**
```bash
# Criar Application Insights
az monitor app-insights component create \
  --app "tiroesportivo-insights" \
  --location "East US" \
  --resource-group "tiroesportivo"

# Conectar à Web App
az webapp config appsettings set \
  --name "tiroesportivobrasileiro" \
  --resource-group "tiroesportivo" \
  --settings APPINSIGHTS_INSTRUMENTATIONKEY="[key]"
```

---

## 🔄 Manutenção e Atualizações

### **Atualizar Aplicação**
```bash
# Novo deploy
az webapp deployment source config-zip \
  --name "tiroesportivobrasileiro" \
  --resource-group "tiroesportivo-rg" \
  --src "tiroesportivobrasileiro-v2.zip"
```

### **Gerenciar Registros DNS**
```bash
# Adicionar novo registro A
az network dns record-set a add-record \
  --resource-group "tiroesportivo-rg" \
  --zone-name "tiroesportivobrasileiro.com.br" \
  --record-set-name "api" \
  --ipv4-address "1.2.3.4"

# Listar todos os registros
az network dns record-set list \
  --resource-group "tiroesportivo-rg" \
  --zone-name "tiroesportivobrasileiro.com.br"
```

### **Backup e Restore**
```bash
# Exportar zona DNS
az network dns zone export \
  --resource-group "tiroesportivo-rg" \
  --name "tiroesportivobrasileiro.com.br" \
  --file-name "backup-dns.txt"

# Importar zona DNS
az network dns zone import \
  --resource-group "tiroesportivo-rg" \
  --name "tiroesportivobrasileiro.com.br" \
  --file-name "backup-dns.txt"
```

---

## 💰 Custos Detalhados

### **Azure DNS**
- **Zona DNS**: $0.50/mês por zona
- **Consultas**: $0.40 por milhão de consultas
- **Estimativa mensal**: ~$2-5 (dependendo do tráfego)

### **Web App S1 Standard**
- **Custo**: $56.94/mês
- **Recursos**: 1.75 GB RAM, 50 GB Storage
- **SSL**: Incluído (certificado gerenciado)

### **Total Estimado**: ~$60/mês

### **Comparação com Provedores DNS Externos**
- **Cloudflare**: Gratuito (básico) + $57 Web App = $57/mês
- **Route 53**: ~$1/mês + $57 Web App = $58/mês
- **Azure DNS**: ~$3/mês + $57 Web App = $60/mês

**Vantagem Azure DNS**: Integração nativa e automação completa

---

## 🚨 Solução de Problemas

### **Problema: DNS não resolve**
```bash
# Verificar Name Servers
nslookup -type=NS tiroesportivobrasileiro.com.br

# Verificar propagação
dig @8.8.8.8 tiroesportivobrasileiro.com.br

# Verificar zona Azure
az network dns zone show \
  --resource-group "tiroesportivo-rg" \
  --name "tiroesportivobrasileiro.com.br"
```

### **Problema: SSL não funciona**
```bash
# Verificar certificado
az webapp config ssl list \
  --resource-group "tiroesportivo-rg"

# Recriar certificado
az webapp config ssl create \
  --resource-group "tiroesportivo-rg" \
  --name "tiroesportivobrasileiro" \
  --hostname "tiroesportivobrasileiro.com.br"
```

### **Problema: Aplicação não carrega**
```bash
# Verificar status
az webapp show \
  --name "tiroesportivobrasileiro" \
  --resource-group "tiroesportivo-rg" \
  --query "state"

# Reiniciar aplicação
az webapp restart \
  --name "tiroesportivobrasileiro" \
  --resource-group "tiroesportivo-rg"
```

---

## 🎯 URLs e Credenciais

### **URLs da Aplicação**
- **Principal**: https://tiroesportivobrasileiro.com.br
- **WWW**: https://www.tiroesportivobrasileiro.com.br
- **Temporária**: https://tiroesportivobrasileiro.azurewebsites.net

### **Credenciais de Acesso**
- **Demo**: demo / demo123
- **Admin**: admin / admin123

### **Endpoints da API**
- **Health**: https://tiroesportivobrasileiro.com.br/api/health
- **Auth**: https://tiroesportivobrasileiro.com.br/api/auth/login
- **Arsenal**: https://tiroesportivobrasileiro.com.br/api/weapons

---

## 📞 Suporte e Recursos

### **Documentação Oficial**
- [Azure DNS](https://docs.microsoft.com/azure/dns/)
- [Azure Web Apps](https://docs.microsoft.com/azure/app-service/)
- [SSL Certificates](https://docs.microsoft.com/azure/app-service/configure-ssl-certificate)

### **Ferramentas Úteis**
- [Azure Portal](https://portal.azure.com)
- [DNS Checker](https://dnschecker.org/)
- [SSL Labs Test](https://www.ssllabs.com/ssltest/)
- [Azure CLI Docs](https://docs.microsoft.com/cli/azure/)

### **Scripts de Referência**
```bash
# Status completo
az network dns zone show --resource-group "tiroesportivo-rg" --name "tiroesportivobrasileiro.com.br"
az webapp show --name "tiroesportivobrasileiro" --resource-group "tiroesportivo-rg"

# Logs e monitoramento
az webapp log tail --name "tiroesportivobrasileiro" --resource-group "tiroesportivo-rg"
az monitor metrics list --resource "[web-app-resource-id]" --metric "CpuPercentage"

# Backup e manutenção
az network dns zone export --resource-group "tiroesportivo-rg" --name "tiroesportivobrasileiro.com.br" --file-name "backup.txt"
az webapp deployment source config-zip --name "tiroesportivobrasileiro" --resource-group "tiroesportivo-rg" --src "update.zip"
```

---

## ✅ Checklist de Deploy

### **Pré-Deploy**
- [ ] Azure CLI instalado e configurado
- [ ] Conta Azure com créditos suficientes
- [ ] Domínio registrado com acesso ao painel

### **DNS Zone**
- [ ] DNS Zone criada no Azure
- [ ] Name Servers obtidos
- [ ] Name Servers configurados no registrador
- [ ] Propagação DNS verificada

### **Web App**
- [ ] Resource Group criado
- [ ] App Service Plan S1 criado
- [ ] Web App criada e deployada
- [ ] Aplicação funcionando na URL temporária

### **Integração**
- [ ] Registros DNS automáticos criados
- [ ] Domínio personalizado adicionado
- [ ] Certificado SSL criado e vinculado
- [ ] HTTPS funcionando corretamente

### **Verificação Final**
- [ ] https://tiroesportivobrasileiro.com.br acessível
- [ ] https://www.tiroesportivobrasileiro.com.br redireciona
- [ ] Login funcionando (demo/demo123)
- [ ] Todas as funcionalidades testadas
- [ ] SSL Grade A+ no SSL Labs

---

## 🎉 Conclusão

Com o **Azure DNS** como provedor, você tem:

✅ **Gerenciamento Unificado**: Tudo no Azure  
✅ **Deploy Automatizado**: Scripts integrados  
✅ **Alta Disponibilidade**: 100% SLA  
✅ **Segurança Avançada**: DNSSEC e SSL automático  
✅ **Monitoramento Integrado**: Logs e métricas centralizados  

**🌐 Acesse**: https://tiroesportivobrasileiro.com.br

Sua aplicação **Tiro Esportivo Brasileiro** está rodando com a infraestrutura mais robusta e integrada do Azure!

