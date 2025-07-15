# 🚀 Deploy Rápido - TIROESPORTIVOBRASILEIRO.COM.BR
## Resource Group: **tiroesportivo**

### ⚡ Deploy em 2 Comandos

#### **1. Configurar DNS Zone:**
```powershell
# Windows
.\create-dns-zone.ps1
```
```bash
# Linux/macOS
./create-dns-zone.sh
```

#### **2. Deploy Completo:**
```powershell
# Windows
.\deploy-with-azure-dns.ps1
```
```bash
# Linux/macOS
./deploy-with-azure-dns.sh
```

---

## 📋 Recursos Criados

### **Resource Group**: `tiroesportivo`
- **Localização**: East US
- **Recursos**: DNS Zone + Web App + SSL

### **DNS Zone**: `tiroesportivobrasileiro.com.br`
- **Name Servers**: 4 servidores Azure DNS
- **Registros**: A, CNAME, TXT, MX automáticos

### **Web App**: `tiroesportivobrasileiro`
- **Runtime**: Python 3.11 (Linux)
- **Plan**: S1 Standard (~$57/mês)
- **SSL**: Certificado gerenciado

---

## 🎯 URLs Finais

- **Principal**: https://tiroesportivobrasileiro.com.br
- **WWW**: https://www.tiroesportivobrasileiro.com.br
- **Temporária**: https://tiroesportivobrasileiro.azurewebsites.net

---

## 👤 Credenciais

- **Demo**: demo / demo123
- **Admin**: admin / admin123

---

## 🔧 Comandos Úteis

### **Logs:**
```bash
az webapp log tail --name tiroesportivobrasileiro --resource-group tiroesportivo
```

### **Status:**
```bash
az webapp show --name tiroesportivobrasileiro --resource-group tiroesportivo --query "state"
```

### **DNS:**
```bash
az network dns zone show --resource-group tiroesportivo --name tiroesportivobrasileiro.com.br
```

### **SSL:**
```bash
az webapp config ssl list --resource-group tiroesportivo
```

---

## 💰 Custo Total: ~$60/mês

- **Azure DNS**: ~$3/mês
- **Web App S1**: ~$57/mês

---

## ✅ Vantagens Azure DNS

- **Integração Nativa**: Tudo no Azure
- **Deploy Automatizado**: Scripts integrados
- **Alta Disponibilidade**: 100% SLA
- **SSL Automático**: Certificados gerenciados
- **Monitoramento**: Logs centralizados

---

**🌐 Acesse**: https://tiroesportivobrasileiro.com.br

**Resource Group**: `tiroesportivo` - Nome simples e direto!

