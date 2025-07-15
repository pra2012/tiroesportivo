#!/bin/bash

# Script de Inicialização - Shooting Sports
# Este script inicia automaticamente o backend e frontend

echo "🎯 Shooting Sports - Inicializando Aplicação"
echo "============================================"

# Verificar se estamos no diretório correto
if [ ! -d "shooting-sports-app" ] || [ ! -d "shooting-sports-frontend" ]; then
    echo "❌ Erro: Execute este script no diretório que contém as pastas shooting-sports-app e shooting-sports-frontend"
    exit 1
fi

# Função para verificar se uma porta está em uso
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Verificar portas
echo "🔍 Verificando portas..."
if check_port 5000; then
    echo "⚠️  Porta 5000 já está em uso. Parando processo..."
    pkill -f "python src/main.py" 2>/dev/null || true
    sleep 2
fi

if check_port 5173; then
    echo "⚠️  Porta 5173 já está em uso. Parando processo..."
    pkill -f "vite" 2>/dev/null || true
    sleep 2
fi

# Iniciar Backend
echo "🚀 Iniciando Backend (Flask)..."
cd shooting-sports-app

# Verificar se o ambiente virtual existe
if [ ! -d "venv" ]; then
    echo "📦 Criando ambiente virtual..."
    python3 -m venv venv
fi

# Ativar ambiente virtual
source venv/bin/activate

# Instalar dependências se necessário
if [ ! -f "venv/pyvenv.cfg" ] || [ ! -f "requirements.txt" ]; then
    echo "📦 Instalando dependências do backend..."
    pip install -r requirements.txt
fi

# Verificar se o banco existe, se não, criar
if [ ! -f "instance/database.db" ]; then
    echo "🗄️  Criando banco de dados..."
    python populate_db.py
fi

# Iniciar backend em background
echo "▶️  Iniciando servidor Flask..."
python src/main.py &
BACKEND_PID=$!

# Aguardar backend inicializar
sleep 5

# Verificar se backend iniciou corretamente
if ! check_port 5000; then
    echo "❌ Erro: Backend não conseguiu iniciar na porta 5000"
    kill $BACKEND_PID 2>/dev/null || true
    exit 1
fi

echo "✅ Backend iniciado com sucesso (PID: $BACKEND_PID)"

# Voltar ao diretório raiz
cd ..

# Iniciar Frontend
echo "🚀 Iniciando Frontend (React)..."
cd shooting-sports-frontend

# Verificar se node_modules existe
if [ ! -d "node_modules" ]; then
    echo "📦 Instalando dependências do frontend..."
    npm install
fi

# Iniciar frontend em background
echo "▶️  Iniciando servidor Vite..."
npm run dev -- --host &
FRONTEND_PID=$!

# Aguardar frontend inicializar
sleep 8

# Verificar se frontend iniciou corretamente
if ! check_port 5173; then
    echo "❌ Erro: Frontend não conseguiu iniciar na porta 5173"
    kill $BACKEND_PID $FRONTEND_PID 2>/dev/null || true
    exit 1
fi

echo "✅ Frontend iniciado com sucesso (PID: $FRONTEND_PID)"

# Voltar ao diretório raiz
cd ..

echo ""
echo "🎉 Aplicação iniciada com sucesso!"
echo "=================================="
echo "🌐 Frontend: http://localhost:5173"
echo "🔧 Backend:  http://localhost:5000"
echo ""
echo "📝 PIDs dos processos:"
echo "   Backend (Flask): $BACKEND_PID"
echo "   Frontend (Vite): $FRONTEND_PID"
echo ""
echo "⚠️  Para parar a aplicação, execute:"
echo "   kill $BACKEND_PID $FRONTEND_PID"
echo "   ou pressione Ctrl+C neste terminal"
echo ""

# Função para limpar processos ao sair
cleanup() {
    echo ""
    echo "🛑 Parando aplicação..."
    kill $BACKEND_PID $FRONTEND_PID 2>/dev/null || true
    echo "✅ Aplicação parada com sucesso!"
    exit 0
}

# Capturar sinais de interrupção
trap cleanup SIGINT SIGTERM

# Aguardar até que o usuário pare o script
echo "💡 Pressione Ctrl+C para parar a aplicação"
echo "🔄 Aguardando..."

# Loop infinito para manter o script rodando
while true; do
    # Verificar se os processos ainda estão rodando
    if ! kill -0 $BACKEND_PID 2>/dev/null; then
        echo "❌ Backend parou inesperadamente!"
        kill $FRONTEND_PID 2>/dev/null || true
        exit 1
    fi
    
    if ! kill -0 $FRONTEND_PID 2>/dev/null; then
        echo "❌ Frontend parou inesperadamente!"
        kill $BACKEND_PID 2>/dev/null || true
        exit 1
    fi
    
    sleep 5
done

