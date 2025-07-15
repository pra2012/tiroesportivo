# ⚡ TIRO ESPORTIVO BRASILEIRO - QUICK START CLOUD SHELL

## 🎯 Deploy em 10 Minutos

### **Pré-requisitos (2 min)**
- ✅ Azure Cloud Shell ativo
- ✅ Subscription: `130706ec-b9d5-4554-8be1-ef855c2cf41a`
- ✅ Domínio: `tiroesportivobrasileiro.com.br`

### **Passo 1: Upload (1 min)**
```bash
# No Azure Cloud Shell
mkdir ~/tiroesportivo && cd ~/tiroesportivo
# Upload do arquivo tiroesportivo-cloudshell-complete.zip
unzip tiroesportivo-cloudshell-complete.zip
chmod +x cloud-shell/*.sh
```

### **Passo 2: Infraestrutura (3 min)**
```bash
./cloud-shell/setup-cloudshell.sh
```
**Resultado**: Resource Group, DNS Zone, Web Apps criados

### **Passo 3: DNS (1 min)**
Configure os Name Servers fornecidos no seu registrador de domínio.

### **Passo 4: Deploy (2 min)**
```bash
./cloud-shell/upload-project.sh
```
**Resultado**: Aplicação no ar!

### **Passo 5: DevOps (1 min)**
```bash
./cloud-shell/configure-pipelines.sh
```
**Resultado**: CI/CD configurado

## 🎉 Pronto!

- **URL**: https://tiroesportivobrasileiro.com.br
- **Login**: demo / demo123
- **Admin**: admin / admin123

## 📞 Suporte

Consulte `AZURE_CLOUD_SHELL_COMPLETE_GUIDE.md` para troubleshooting.

---

**⏱️ Total: ~10 minutos | 💰 Custo: ~$65/mês**

