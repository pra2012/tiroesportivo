# Guia de Instalação Rápida - Shooting Sports

## Pré-requisitos
- Python 3.11 ou superior
- Node.js 20 ou superior
- Git (opcional)

## Instalação em 5 Passos

### 1. Preparar Backend
```bash
cd shooting-sports-app
python -m venv venv
source venv/bin/activate  # Linux/Mac ou venv\Scripts\activate no Windows
pip install -r requirements.txt
```

### 2. Configurar Banco de Dados
```bash
python populate_db.py
```
✅ Isso criará o banco SQLite e populará com dados iniciais

### 3. Iniciar Backend
```bash
python src/main.py
```
✅ Backend rodando em http://localhost:5000

### 4. Preparar Frontend (nova janela do terminal)
```bash
cd shooting-sports-frontend
npm install
```

### 5. Iniciar Frontend
```bash
npm run dev -- --host
```
✅ Frontend rodando em http://localhost:5173

## Acesso à Aplicação
Abra seu navegador e acesse: **http://localhost:5173**

## Dados de Teste Inclusos
A aplicação já vem com:
- ✅ 14 armas cadastradas
- ✅ 9 competições configuradas
- ✅ 20 sessões de treinamento de exemplo
- ✅ Sistema de 4 níveis
- ✅ Estatísticas e rankings

## Problemas Comuns

### Backend não inicia
- Verifique se o Python 3.11+ está instalado
- Certifique-se de que o ambiente virtual está ativado
- Execute `pip install -r requirements.txt` novamente

### Frontend não inicia
- Verifique se o Node.js 20+ está instalado
- Execute `npm install` novamente
- Tente usar `yarn` ao invés de `npm`

### Dados não aparecem
- Certifique-se de que o backend está rodando na porta 5000
- Execute `python populate_db.py` novamente
- Verifique se não há erros no console do navegador

## Comandos Úteis

### Resetar banco de dados
```bash
cd shooting-sports-app
source venv/bin/activate
python populate_db.py
```

### Verificar logs do backend
O backend mostra logs no terminal onde foi iniciado

### Verificar logs do frontend
Abra as ferramentas de desenvolvedor do navegador (F12)

## Próximos Passos
1. Explore todas as seções da aplicação
2. Adicione suas próprias armas e sessões
3. Acompanhe seu progresso nos níveis
4. Analise suas estatísticas de desempenho

## Suporte
Em caso de problemas, verifique:
1. Se todas as dependências foram instaladas
2. Se as portas 5000 e 5173 estão livres
3. Se o firewall não está bloqueando as conexões
4. Os logs de erro nos terminais

