# Configuração de Deployment - Shooting Sports

## Estrutura de Arquivos para Entrega
```
shooting-sports/
├── shooting-sports-app/          # Backend Flask
│   ├── src/                      # Código fonte
│   ├── venv/                     # Ambiente virtual Python
│   ├── requirements.txt          # Dependências Python
│   ├── populate_db.py           # Script de população do banco
│   └── instance/                # Banco de dados SQLite
├── shooting-sports-frontend/     # Frontend React
│   ├── src/                     # Código fonte React
│   ├── public/                  # Arquivos públicos
│   ├── package.json             # Dependências Node.js
│   └── dist/                    # Build de produção (após build)
├── README.md                    # Documentação completa
├── INSTALACAO.md               # Guia de instalação rápida
├── start.sh                    # Script de inicialização (Linux/Mac)
├── start.bat                   # Script de inicialização (Windows)
└── DEPLOYMENT.md               # Este arquivo
```

## Opções de Deployment

### 1. Desenvolvimento Local
**Recomendado para**: Testes e desenvolvimento
**Instruções**: Seguir INSTALACAO.md

### 2. Servidor de Produção
**Recomendado para**: Uso em produção

#### Backend (Flask)
```bash
# Usar Gunicorn para produção
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 src.main:app
```

#### Frontend (React)
```bash
# Build para produção
npm run build
# Servir arquivos estáticos com nginx ou apache
```

### 3. Docker (Opcional)
Criar Dockerfile para containerização:

#### Backend Dockerfile
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "src.main:app"]
```

#### Frontend Dockerfile
```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
EXPOSE 5173
CMD ["npm", "run", "preview", "--", "--host"]
```

### 4. Cloud Deployment

#### Heroku
1. Criar Procfile para backend:
```
web: gunicorn -w 4 -b 0.0.0.0:$PORT src.main:app
```

2. Configurar variáveis de ambiente
3. Deploy via Git

#### Vercel (Frontend)
1. Conectar repositório
2. Configurar build command: `npm run build`
3. Deploy automático

#### Railway/Render
Similar ao Heroku, com configurações específicas da plataforma

## Configurações de Produção

### Backend
- Usar PostgreSQL ao invés de SQLite
- Configurar variáveis de ambiente
- Implementar logging adequado
- Configurar CORS para domínio específico

### Frontend
- Configurar URL da API de produção
- Otimizar build para produção
- Configurar CDN para assets
- Implementar cache adequado

### Segurança
- HTTPS obrigatório
- Configurar headers de segurança
- Implementar rate limiting
- Validação rigorosa de inputs

### Monitoramento
- Logs estruturados
- Métricas de performance
- Alertas para erros
- Backup automático do banco

## Checklist de Deployment

### Pré-deployment
- [ ] Testes unitários passando
- [ ] Testes de integração passando
- [ ] Build de produção funcionando
- [ ] Configurações de ambiente definidas
- [ ] Backup do banco criado

### Deployment
- [ ] Deploy do backend
- [ ] Deploy do frontend
- [ ] Configuração de DNS
- [ ] Certificado SSL configurado
- [ ] Monitoramento ativo

### Pós-deployment
- [ ] Testes de fumaça
- [ ] Verificação de performance
- [ ] Logs sendo coletados
- [ ] Backup funcionando
- [ ] Documentação atualizada

## Manutenção

### Backups
- Backup diário do banco de dados
- Backup semanal completo
- Teste de restore mensal

### Updates
- Updates de segurança prioritários
- Updates de dependências regulares
- Versionamento semântico

### Monitoramento
- Uptime monitoring
- Performance monitoring
- Error tracking
- User analytics (opcional)

## Troubleshooting

### Problemas Comuns
1. **Porta em uso**: Verificar processos rodando
2. **Dependências**: Reinstalar packages
3. **Banco corrompido**: Restaurar backup
4. **CORS errors**: Verificar configuração
5. **Build falha**: Verificar logs de build

### Logs Importantes
- Backend: Logs do Flask/Gunicorn
- Frontend: Console do navegador
- Servidor: Logs do sistema
- Banco: Logs do SQLite/PostgreSQL

## Contato e Suporte
Para questões técnicas ou problemas de deployment, consulte:
1. README.md - Documentação completa
2. INSTALACAO.md - Guia de instalação
3. Logs da aplicação
4. Issues do repositório (se aplicável)

