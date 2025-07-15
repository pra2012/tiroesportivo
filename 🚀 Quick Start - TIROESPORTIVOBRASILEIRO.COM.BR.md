# 🚀 Quick Start - TIROESPORTIVOBRASILEIRO.COM.BR

## ⚡ Deploy em 10 Minutos

### 1. Pré-requisitos Rápidos
```bash
# Instalar Azure CLI
winget install Microsoft.AzureCLI  # Windows
brew install azure-cli            # macOS

# Login
az login
```

### 2. Configurar DNS (PRIMEIRO!)
**No seu provedor de DNS, configure:**
```
Tipo: CNAME
Nome: @
Valor: [será fornecido pelo script]

Tipo: TXT  
Nome: asuid
Valor: [será fornecido pelo script]
```

### 3. Deploy Automatizado
```powershell
# Windows PowerShell
cd azure-custom-domain
.\deploy-custom-domain.ps1
```

```bash
# Linux/macOS
cd azure-custom-domain
./deploy-custom-domain.sh
```

### 4. Aguardar e Configurar
1. **Script fornecerá os valores DNS** → Configure no seu provedor
2. **Aguarde propagação DNS** (15min - 4h)
3. **Continue o script** quando DNS estiver propagado
4. **SSL será configurado automaticamente**

---

## 🎯 Resultado Final

### URLs:
- **Principal**: https://tiroesportivobrasileiro.com.br
- **Temporária**: https://tiroesportivobrasileiro.azurewebsites.net

### Credenciais:
- **Demo**: demo / demo123
- **Admin**: admin / admin123

---

## 🔧 Comandos Úteis

### Verificar DNS:
```bash
nslookup tiroesportivobrasileiro.com.br
```

### Verificar SSL:
```bash
curl -I https://tiroesportivobrasileiro.com.br
```

### Ver Logs:
```bash
az webapp log tail --name tiroesportivobrasileiro --resource-group tiroesportivo-rg
```

### Reiniciar App:
```bash
az webapp restart --name tiroesportivobrasileiro --resource-group tiroesportivo-rg
```

---

## 🚨 Problemas Comuns

### DNS não resolve:
- Aguarde até 48h para propagação
- Verifique registros no provedor DNS

### SSL não funciona:
- Aguarde DNS propagar primeiro
- Execute novamente a configuração SSL

### App não carrega:
- Verifique logs com comando acima
- Reinicie a aplicação

---

## 📞 Suporte Rápido

### Ferramentas de Verificação:
- [DNS Checker](https://dnschecker.org/)
- [SSL Labs](https://www.ssllabs.com/ssltest/)
- [Azure Portal](https://portal.azure.com)

### Comandos de Emergência:
```bash
# Status da app
az webapp show --name tiroesportivobrasileiro --resource-group tiroesportivo-rg --query "state"

# Recriar certificado SSL
az webapp config ssl create --resource-group tiroesportivo-rg --name tiroesportivobrasileiro --hostname tiroesportivobrasileiro.com.br
```

---

**✅ Pronto! Sua aplicação Tiro Esportivo Brasileiro está no ar em TIROESPORTIVOBRASILEIRO.COM.BR!**

