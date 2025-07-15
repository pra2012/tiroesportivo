# 🌐 Configuração DNS para TIROESPORTIVOBRASILEIRO.COM.BR

## 📋 Registros DNS Necessários

### 1. Registro CNAME (Recomendado)
```
Tipo: CNAME
Nome: @
Valor: [nome-da-webapp].azurewebsites.net
TTL: 3600
```

### 2. Registro A (Alternativo)
```
Tipo: A
Nome: @
Valor: [IP do Azure Web App]
TTL: 3600
```

### 3. Registro CNAME para WWW
```
Tipo: CNAME
Nome: www
Valor: tiroesportivobrasileiro.com.br
TTL: 3600
```

### 4. Registro TXT para Verificação
```
Tipo: TXT
Nome: asuid
Valor: [Custom Domain Verification ID do Azure]
TTL: 3600
```

## 🔧 Configuração no Provedor DNS

### Registro.br (se registrado no Brasil)
1. Acesse o painel do Registro.br
2. Vá em "DNS" > "Zona DNS"
3. Adicione os registros acima
4. Aguarde propagação (até 48h)

### Cloudflare
1. Acesse o painel do Cloudflare
2. Vá em "DNS" > "Records"
3. Adicione os registros DNS
4. Configure SSL/TLS como "Full (strict)"
5. Ative "Always Use HTTPS"

### GoDaddy
1. Acesse o painel do GoDaddy
2. Vá em "DNS" > "Manage Zones"
3. Adicione os registros DNS
4. Aguarde propagação

### Outros Provedores
- Localize a seção de gerenciamento DNS
- Adicione os registros conforme especificado
- Aguarde a propagação DNS

## ✅ Verificação da Configuração

### Comandos para Verificar DNS
```bash
# Verificar registro A
nslookup tiroesportivobrasileiro.com.br

# Verificar registro CNAME
nslookup www.tiroesportivobrasileiro.com.br

# Verificar registro TXT
nslookup -type=TXT asuid.tiroesportivobrasileiro.com.br

# Verificar propagação global
dig @8.8.8.8 tiroesportivobrasileiro.com.br
```

### Ferramentas Online
- [DNS Checker](https://dnschecker.org/)
- [What's My DNS](https://www.whatsmydns.net/)
- [DNS Propagation Checker](https://www.dnswatch.info/)

## ⏱️ Tempo de Propagação
- **Mínimo**: 15 minutos
- **Típico**: 2-4 horas
- **Máximo**: 48 horas

## 🔒 Configurações de Segurança DNS

### DNSSEC (Recomendado)
Se seu provedor suportar, ative DNSSEC para maior segurança.

### CAA Records (Opcional)
```
Tipo: CAA
Nome: @
Valor: 0 issue "letsencrypt.org"
TTL: 3600
```

## 📞 Suporte
- **Registro.br**: https://registro.br/
- **Cloudflare**: https://support.cloudflare.com/
- **GoDaddy**: https://br.godaddy.com/help

