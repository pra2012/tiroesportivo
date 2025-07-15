@echo off
REM Script de Inicialização - Shooting Sports (Windows)
REM Este script inicia automaticamente o backend e frontend

echo 🎯 Shooting Sports - Inicializando Aplicação
echo ============================================

REM Verificar se estamos no diretório correto
if not exist "shooting-sports-app" (
    echo ❌ Erro: Execute este script no diretório que contém as pastas shooting-sports-app e shooting-sports-frontend
    pause
    exit /b 1
)

if not exist "shooting-sports-frontend" (
    echo ❌ Erro: Execute este script no diretório que contém as pastas shooting-sports-app e shooting-sports-frontend
    pause
    exit /b 1
)

echo 🚀 Iniciando Backend (Flask)...
cd shooting-sports-app

REM Verificar se o ambiente virtual existe
if not exist "venv" (
    echo 📦 Criando ambiente virtual...
    python -m venv venv
)

REM Ativar ambiente virtual
call venv\Scripts\activate

REM Instalar dependências se necessário
if not exist "requirements.txt" (
    echo ❌ Erro: Arquivo requirements.txt não encontrado
    pause
    exit /b 1
)

echo 📦 Instalando dependências do backend...
pip install -r requirements.txt

REM Verificar se o banco existe, se não, criar
if not exist "instance\database.db" (
    echo 🗄️  Criando banco de dados...
    python populate_db.py
)

REM Iniciar backend
echo ▶️  Iniciando servidor Flask...
start "Backend Flask" cmd /k "python src/main.py"

REM Aguardar backend inicializar
timeout /t 5 /nobreak > nul

echo ✅ Backend iniciado com sucesso

REM Voltar ao diretório raiz
cd ..

REM Iniciar Frontend
echo 🚀 Iniciando Frontend (React)...
cd shooting-sports-frontend

REM Verificar se node_modules existe
if not exist "node_modules" (
    echo 📦 Instalando dependências do frontend...
    npm install
)

REM Iniciar frontend
echo ▶️  Iniciando servidor Vite...
start "Frontend React" cmd /k "npm run dev -- --host"

REM Aguardar frontend inicializar
timeout /t 8 /nobreak > nul

echo ✅ Frontend iniciado com sucesso

REM Voltar ao diretório raiz
cd ..

echo.
echo 🎉 Aplicação iniciada com sucesso!
echo ==================================
echo 🌐 Frontend: http://localhost:5173
echo 🔧 Backend:  http://localhost:5000
echo.
echo 💡 Duas janelas de terminal foram abertas:
echo    - Uma para o Backend (Flask)
echo    - Uma para o Frontend (React)
echo.
echo ⚠️  Para parar a aplicação, feche as duas janelas de terminal
echo    ou pressione Ctrl+C em cada uma delas
echo.
echo 🌐 Abrindo navegador...

REM Aguardar um pouco mais e abrir o navegador
timeout /t 3 /nobreak > nul
start http://localhost:5173

echo.
echo ✅ Aplicação pronta para uso!
echo 📝 Pressione qualquer tecla para fechar esta janela...
pause > nul

