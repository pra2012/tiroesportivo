# 🎯 Tiro Esportivo Brasileiro

## Sistema de Controle de Tiro Esportivo
**Domínio**: [tiroesportivobrasileiro.com.br](https://tiroesportivobrasileiro.com.br)

---

## 📋 Sobre o Projeto

O **Tiro Esportivo Brasileiro** é um sistema completo de controle e gestão para praticantes de tiro esportivo, oferecendo funcionalidades avançadas para:

- 🔐 **Autenticação e Controle de Usuários**
- 🔫 **Gestão de Arsenal de Armas**
- 🏆 **Sistema de Ranking e Competições**
- 📊 **Controle de Sessões de Treinamento**
- 📈 **Sistema de Níveis de Progressão**
- 📱 **Interface Responsiva e Moderna**

---

## 🏗️ Arquitetura Técnica

### Frontend
- **Framework**: React 18 + Vite
- **Styling**: Tailwind CSS + shadcn/ui
- **Icons**: Lucide React
- **Charts**: Recharts
- **Build**: Otimizado para produção

### Backend
- **Framework**: Flask + SQLAlchemy
- **Autenticação**: JWT (JSON Web Tokens)
- **Banco de Dados**: SQLite
- **API**: RESTful com CORS configurado

### Deploy
- **Plataforma**: Microsoft Azure Web App
- **Runtime**: Python 3.11 (Linux)
- **SSL**: Certificado gerenciado pelo Azure
- **Domínio**: tiroesportivobrasileiro.com.br

---

## 🚀 Deploy Rápido

### Pré-requisitos
- Azure CLI instalado
- Conta Azure ativa
- Domínio registrado com acesso ao DNS

### Comando Único
```bash
# Windows
.\deploy-custom-domain.ps1

# Linux/macOS
./deploy-custom-domain.sh
```

---

## 🌐 URLs e Acesso

### URLs da Aplicação
- **Principal**: https://tiroesportivobrasileiro.com.br
- **Temporária**: https://tiroesportivobrasileiro.azurewebsites.net
- **API Health**: https://tiroesportivobrasileiro.com.br/api/health

### Credenciais de Demonstração
```
Usuário Demo:
- Login: demo
- Senha: demo123

Usuário Admin:
- Login: admin  
- Senha: admin123
```

---

## 📊 Funcionalidades Principais

### 🔐 Sistema de Autenticação
- Login seguro com JWT
- Controle de sessões
- Diferentes níveis de acesso (Demo/Admin)
- Proteção de rotas

### 🔫 Gestão de Arsenal
- Cadastro completo de armas
- Informações detalhadas (calibre, proprietário, modelo)
- Filtros e busca avançada
- Interface intuitiva para gestão

### 🏆 Sistema de Ranking
- Acompanhamento de competições
- Histórico de pontuações
- Gráficos de performance
- Comparação de resultados

### 📈 Controle de Treinamento
- Registro de sessões de treino
- Estatísticas de tiros e acertos
- Histórico detalhado
- Análise de progresso

### 🎯 Sistema de Níveis
- Progressão baseada em performance
- Níveis de I a III
- Mensagens motivacionais
- Dicas para evolução

---

## 🔧 Configuração Técnica

### Variáveis de Ambiente
```bash
FLASK_ENV=production
SECRET_KEY=tiroesportivobrasileiro-azure-secret-key-2024
CUSTOM_DOMAIN=tiroesportivobrasileiro.com.br
FORCE_HTTPS=true
```

### Estrutura de Arquivos
```
azure-custom-domain/
├── src/
│   ├── main.py              # Aplicação Flask principal
│   ├── models/              # Modelos de dados
│   └── routes/              # Rotas da API
├── static/                  # Frontend React (build)
├── startup.py               # Inicialização Azure
├── web.config              # Configuração IIS
├── requirements.txt        # Dependências Python
└── tiroesportivobrasileiro.zip  # Pacote de deploy
```

### Endpoints da API
```
GET  /api/health            # Status da aplicação
POST /api/auth/login        # Autenticação
GET  /api/weapons           # Lista de armas
GET  /api/competitions      # Competições
GET  /api/levels            # Níveis de usuário
GET  /api/training          # Sessões de treino
```

---

## 🔒 Segurança

### Implementações de Segurança
- **HTTPS Obrigatório**: Redirecionamento automático
- **Headers de Segurança**: CSP, HSTS, X-Frame-Options
- **Autenticação JWT**: Tokens seguros com expiração
- **CORS Configurado**: Apenas origens autorizadas
- **Validação de Entrada**: Sanitização de dados
- **SSL Grade A**: Certificado gerenciado pelo Azure

### Configurações DNS de Segurança
```
CAA Record: 0 issue "letsencrypt.org"
DNSSEC: Habilitado (se suportado)
```

---

## 📊 Monitoramento

### Logs da Aplicação
```bash
# Logs em tempo real
az webapp log tail --name tiroesportivobrasileiro --resource-group tiroesportivo-rg

# Download de logs
az webapp log download --name tiroesportivobrasileiro --resource-group tiroesportivo-rg
```

### Métricas de Performance
- CPU e Memória via Azure Monitor
- Tempo de resposta da API
- Disponibilidade do serviço
- Certificado SSL (renovação automática)

---

## 🔄 Manutenção

### Atualizações
```bash
# Novo deploy
az webapp deployment source config-zip \
  --name tiroesportivobrasileiro \
  --resource-group tiroesportivo-rg \
  --src tiroesportivobrasileiro-v2.zip
```

### Backup
```bash
# Backup do banco de dados
az webapp deployment source download \
  --name tiroesportivobrasileiro \
  --resource-group tiroesportivo-rg
```

### Escalonamento
```bash
# Upgrade para P1V2 (mais recursos)
az appservice plan update \
  --name tiroesportivo-plan \
  --resource-group tiroesportivo-rg \
  --sku P1V2
```

---

## 📞 Suporte

### Documentação
- [Guia Completo de Deploy](./TIROESPORTIVOBRASILEIRO_DEPLOYMENT_GUIDE.md)
- [Quick Start](./TIROESPORTIVOBRASILEIRO_QUICK_START.md)
- [Configuração DNS](./dns-configuration.md)
- [Configuração SSL](./ssl-configuration.md)

### Recursos Úteis
- [Azure Portal](https://portal.azure.com)
- [Azure CLI Docs](https://docs.microsoft.com/cli/azure/)
- [DNS Checker](https://dnschecker.org/)
- [SSL Labs Test](https://www.ssllabs.com/ssltest/)

### Comandos de Diagnóstico
```bash
# Status da aplicação
az webapp show --name tiroesportivobrasileiro --resource-group tiroesportivo-rg --query "state"

# Verificar SSL
az webapp config ssl list --resource-group tiroesportivo-rg

# Verificar domínios
az webapp config hostname list --webapp-name tiroesportivobrasileiro --resource-group tiroesportivo-rg
```

---

## 📈 Roadmap

### Próximas Funcionalidades
- [ ] Integração com redes sociais
- [ ] Sistema de notificações
- [ ] Relatórios avançados em PDF
- [ ] App mobile (React Native)
- [ ] Integração com equipamentos IoT
- [ ] Sistema de backup automático

### Melhorias Técnicas
- [ ] Migração para PostgreSQL
- [ ] Implementação de Redis (cache)
- [ ] CI/CD com GitHub Actions
- [ ] Testes automatizados
- [ ] Monitoramento com Application Insights

---

## 👥 Equipe

**Desenvolvido por**: Equipe Tiro Esportivo Brasileiro  
**Contato**: contato@tiroesportivobrasileiro.com.br  
**Versão**: 1.0.0  
**Última Atualização**: Janeiro 2024  

---

## 📄 Licença

Este projeto é propriedade da **Tiro Esportivo Brasileiro** e está protegido por direitos autorais.

---

**🎯 Acesse agora**: [tiroesportivobrasileiro.com.br](https://tiroesportivobrasileiro.com.br)

