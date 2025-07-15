#!/bin/bash

# Upload Project - Tiro Esportivo Brasileiro
# TIROESPORTIVOBRASILEIRO.COM.BR
# Script para upload dos arquivos do projeto via Cloud Shell

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configurações
ORGANIZATION_NAME=${1}
PROJECT_NAME="TiroEsportivoBrasileiro"
WORK_DIR="$HOME/tiroesportivo"

# Função para log
log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Verificar parâmetros
if [[ -z "$ORGANIZATION_NAME" ]]; then
    error "Nome da organização é obrigatório"
    echo "Uso: $0 <organization-name>"
    exit 1
fi

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║           📁 UPLOAD PROJECT FILES                           ║"
echo "║              Tiro Esportivo Brasileiro                      ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

log "🚀 Iniciando upload para: $ORGANIZATION_NAME/$PROJECT_NAME"

# Navegar para diretório do projeto
cd "$WORK_DIR/$PROJECT_NAME" || {
    error "Diretório do projeto não encontrado: $WORK_DIR/$PROJECT_NAME"
    error "Execute primeiro: ./setup-cloudshell.sh $ORGANIZATION_NAME"
    exit 1
}

# Criar estrutura completa do projeto
log "🏗️ Criando estrutura completa do projeto..."

# Pipelines
mkdir -p .azure-pipelines
cat > azure-pipelines.yml << 'EOF'
# Azure DevOps Pipeline - Tiro Esportivo Brasileiro
# TIROESPORTIVOBRASILEIRO.COM.BR

trigger:
  branches:
    include:
    - main
    - develop
  paths:
    exclude:
    - README.md
    - docs/*

pr:
  branches:
    include:
    - main

variables:
  subscriptionId: '130706ec-b9d5-4554-8be1-ef855c2cf41a'
  resourceGroupName: 'tiroesportivo'
  webAppName: 'tiroesportivobrasileiro'
  domainName: 'tiroesportivobrasileiro.com.br'
  azureSubscription: 'Azure-Connection'
  pythonVersion: '3.11'
  nodeVersion: '20.x'

stages:
- stage: Build
  displayName: 'Build Application'
  jobs:
  - job: BuildBackend
    displayName: 'Build Backend (Flask)'
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    - task: UsePythonVersion@0
      inputs:
        versionSpec: '$(pythonVersion)'
      displayName: 'Use Python $(pythonVersion)'
    
    - script: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
      displayName: 'Install Python dependencies'
    
    - script: |
        python -m pytest tests/ --junitxml=test-results.xml --cov=src --cov-report=xml
      displayName: 'Run Python tests'
      continueOnError: true
    
    - task: PublishTestResults@2
      inputs:
        testResultsFiles: 'test-results.xml'
        testRunTitle: 'Python Tests'
      condition: always()
    
    - task: PublishCodeCoverageResults@1
      inputs:
        codeCoverageTool: 'Cobertura'
        summaryFileLocation: 'coverage.xml'
      condition: always()
    
    - task: ArchiveFiles@2
      inputs:
        rootFolderOrFile: '$(System.DefaultWorkingDirectory)'
        includeRootFolder: false
        archiveType: 'zip'
        archiveFile: '$(Build.ArtifactStagingDirectory)/backend.zip'
        replaceExistingArchive: true
    
    - task: PublishBuildArtifacts@1
      inputs:
        pathToPublish: '$(Build.ArtifactStagingDirectory)/backend.zip'
        artifactName: 'backend'

  - job: BuildFrontend
    displayName: 'Build Frontend (React)'
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    - task: NodeTool@0
      inputs:
        versionSpec: '$(nodeVersion)'
      displayName: 'Use Node.js $(nodeVersion)'
    
    - script: |
        cd frontend
        npm ci
        npm run build
      displayName: 'Build React app'
    
    - task: ArchiveFiles@2
      inputs:
        rootFolderOrFile: 'frontend/dist'
        includeRootFolder: false
        archiveType: 'zip'
        archiveFile: '$(Build.ArtifactStagingDirectory)/frontend.zip'
        replaceExistingArchive: true
    
    - task: PublishBuildArtifacts@1
      inputs:
        pathToPublish: '$(Build.ArtifactStagingDirectory)/frontend.zip'
        artifactName: 'frontend'

- stage: DeployDev
  displayName: 'Deploy to Development'
  dependsOn: Build
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/develop'))
  jobs:
  - deployment: DeployToDev
    displayName: 'Deploy to Development Environment'
    pool:
      vmImage: 'ubuntu-latest'
    environment: 'development'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureWebApp@1
            inputs:
              azureSubscription: '$(azureSubscription)'
              appType: 'webAppLinux'
              appName: '$(webAppName)-dev'
              package: '$(Pipeline.Workspace)/backend/backend.zip'
              runtimeStack: 'PYTHON|3.11'
              startUpCommand: 'startup.py'

- stage: DeployProd
  displayName: 'Deploy to Production'
  dependsOn: Build
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - deployment: DeployToProd
    displayName: 'Deploy to Production Environment'
    pool:
      vmImage: 'ubuntu-latest'
    environment: 'production'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureWebApp@1
            inputs:
              azureSubscription: '$(azureSubscription)'
              appType: 'webAppLinux'
              appName: '$(webAppName)'
              package: '$(Pipeline.Workspace)/backend/backend.zip'
              runtimeStack: 'PYTHON|3.11'
              startUpCommand: 'startup.py'
          
          - task: AzureCLI@2
            displayName: 'Configure Custom Domain'
            inputs:
              azureSubscription: '$(azureSubscription)'
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                # Configurar domínio personalizado
                az webapp config hostname add \
                  --webapp-name $(webAppName) \
                  --resource-group $(resourceGroupName) \
                  --hostname $(domainName)
                
                # Configurar SSL
                az webapp config ssl bind \
                  --certificate-thumbprint auto \
                  --ssl-type SNI \
                  --name $(webAppName) \
                  --resource-group $(resourceGroupName)

- stage: HealthCheck
  displayName: 'Health Check'
  dependsOn: 
  - DeployDev
  - DeployProd
  condition: always()
  jobs:
  - job: HealthCheck
    displayName: 'Verify Deployment'
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    - script: |
        # Health check para desenvolvimento
        if [[ "$(Build.SourceBranch)" == "refs/heads/develop" ]]; then
          curl -f https://$(webAppName)-dev.azurewebsites.net/api/health || exit 1
        fi
        
        # Health check para produção
        if [[ "$(Build.SourceBranch)" == "refs/heads/main" ]]; then
          curl -f https://$(domainName)/api/health || exit 1
        fi
      displayName: 'Health Check'
EOF

# Pipeline de infraestrutura
cat > infrastructure-pipeline.yml << 'EOF'
# Pipeline de Infraestrutura - Tiro Esportivo Brasileiro
# TIROESPORTIVOBRASILEIRO.COM.BR

trigger:
  branches:
    include:
    - main
  paths:
    include:
    - infrastructure/*
    - infrastructure-pipeline.yml

pr: none

variables:
  subscriptionId: '130706ec-b9d5-4554-8be1-ef855c2cf41a'
  resourceGroupName: 'tiroesportivo'
  location: 'East US'
  domainName: 'tiroesportivobrasileiro.com.br'
  azureSubscription: 'Azure-Connection'
  appServicePlan: 'tiroesportivo-plan'
  webAppName: 'tiroesportivobrasileiro'
  webAppNameDev: 'tiroesportivobrasileiro-dev'
  sku: 'S1'

stages:
- stage: ValidateInfrastructure
  displayName: 'Validate Infrastructure'
  jobs:
  - job: Validate
    displayName: 'Validate Resources'
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    - task: AzureCLI@2
      displayName: 'Validate Resource Group'
      inputs:
        azureSubscription: '$(azureSubscription)'
        scriptType: 'bash'
        scriptLocation: 'inlineScript'
        inlineScript: |
          echo "Validating Resource Group: $(resourceGroupName)"
          if ! az group show --name $(resourceGroupName) &> /dev/null; then
            echo "Resource Group will be created"
          else
            echo "Resource Group already exists"
          fi

- stage: DeployInfrastructure
  displayName: 'Deploy Infrastructure'
  dependsOn: ValidateInfrastructure
  jobs:
  - deployment: DeployInfra
    displayName: 'Deploy Azure Resources'
    pool:
      vmImage: 'ubuntu-latest'
    environment: 'infrastructure'
    strategy:
      runOnce:
        deploy:
          steps:
          - task: AzureCLI@2
            displayName: 'Create Resource Group'
            inputs:
              azureSubscription: '$(azureSubscription)'
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                az group create \
                  --name $(resourceGroupName) \
                  --location "$(location)"
          
          - task: AzureCLI@2
            displayName: 'Create DNS Zone'
            inputs:
              azureSubscription: '$(azureSubscription)'
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                # Criar DNS Zone
                az network dns zone create \
                  --resource-group $(resourceGroupName) \
                  --name $(domainName)
                
                # Obter Name Servers
                az network dns zone show \
                  --resource-group $(resourceGroupName) \
                  --name $(domainName) \
                  --query "nameServers" \
                  --output table
          
          - task: AzureCLI@2
            displayName: 'Create App Service Plan'
            inputs:
              azureSubscription: '$(azureSubscription)'
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                az appservice plan create \
                  --name $(appServicePlan) \
                  --resource-group $(resourceGroupName) \
                  --location "$(location)" \
                  --sku $(sku) \
                  --is-linux
          
          - task: AzureCLI@2
            displayName: 'Create Web Apps'
            inputs:
              azureSubscription: '$(azureSubscription)'
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                # Web App de Produção
                az webapp create \
                  --resource-group $(resourceGroupName) \
                  --plan $(appServicePlan) \
                  --name $(webAppName) \
                  --runtime "PYTHON:3.11" \
                  --startup-file startup.py
                
                # Web App de Desenvolvimento
                az webapp create \
                  --resource-group $(resourceGroupName) \
                  --plan $(appServicePlan) \
                  --name $(webAppNameDev) \
                  --runtime "PYTHON:3.11" \
                  --startup-file startup.py
          
          - task: AzureCLI@2
            displayName: 'Configure DNS Records'
            inputs:
              azureSubscription: '$(azureSubscription)'
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                # Obter IP do Web App
                WEBAPP_IP=$(az webapp show \
                  --name $(webAppName) \
                  --resource-group $(resourceGroupName) \
                  --query "defaultHostName" \
                  --output tsv)
                
                # Criar registro A para domínio raiz
                az network dns record-set a add-record \
                  --resource-group $(resourceGroupName) \
                  --zone-name $(domainName) \
                  --record-set-name "@" \
                  --ipv4-address $(dig +short $WEBAPP_IP | head -1) || true
                
                # Criar registro CNAME para www
                az network dns record-set cname set-record \
                  --resource-group $(resourceGroupName) \
                  --zone-name $(domainName) \
                  --record-set-name "www" \
                  --cname $(webAppName).azurewebsites.net || true
          
          - task: AzureCLI@2
            displayName: 'Create Application Insights'
            inputs:
              azureSubscription: '$(azureSubscription)'
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                az monitor app-insights component create \
                  --app tiroesportivo-insights \
                  --location "$(location)" \
                  --resource-group $(resourceGroupName) \
                  --application-type web

- stage: VerifyInfrastructure
  displayName: 'Verify Infrastructure'
  dependsOn: DeployInfrastructure
  jobs:
  - job: Verify
    displayName: 'Verify Deployed Resources'
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    - task: AzureCLI@2
      displayName: 'List Created Resources'
      inputs:
        azureSubscription: '$(azureSubscription)'
        scriptType: 'bash'
        scriptLocation: 'inlineScript'
        inlineScript: |
          echo "=== RECURSOS CRIADOS ==="
          az resource list \
            --resource-group $(resourceGroupName) \
            --output table
          
          echo ""
          echo "=== NAME SERVERS DNS ==="
          az network dns zone show \
            --resource-group $(resourceGroupName) \
            --name $(domainName) \
            --query "nameServers" \
            --output table
          
          echo ""
          echo "=== WEB APPS URLs ==="
          echo "Produção: https://$(webAppName).azurewebsites.net"
          echo "Desenvolvimento: https://$(webAppNameDev).azurewebsites.net"
          echo "Domínio: https://$(domainName)"
EOF

# Backend structure
mkdir -p src/{models,routes}
mkdir -p tests
mkdir -p instance

# requirements.txt
cat > requirements.txt << 'EOF'
Flask==3.0.0
Flask-SQLAlchemy==3.1.1
Flask-CORS==4.0.0
PyJWT==2.8.0
Werkzeug==3.0.1
python-dotenv==1.0.0
gunicorn==21.2.0
EOF

# startup.py
cat > startup.py << 'EOF'
#!/usr/bin/env python3
"""
Startup script para Azure Web App - Tiro Esportivo Brasileiro
TIROESPORTIVOBRASILEIRO.COM.BR
"""

import os
import sys
import logging
from src.main import app

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

if __name__ == "__main__":
    # Configurações para Azure Web App
    port = int(os.environ.get('PORT', 8000))
    host = os.environ.get('HOST', '0.0.0.0')
    
    logger.info(f"Iniciando aplicação em {host}:{port}")
    logger.info(f"Ambiente: {os.environ.get('FLASK_ENV', 'production')}")
    
    # Executar aplicação
    app.run(
        host=host,
        port=port,
        debug=False
    )
EOF

# web.config
cat > web.config << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <system.webServer>
    <handlers>
      <add name="PythonHandler" path="*" verb="*" modules="httpPlatformHandler" resourceType="Unspecified"/>
    </handlers>
    <httpPlatform processPath="python" arguments="startup.py" stdoutLogEnabled="true" stdoutLogFile="logs\python.log" startupTimeLimit="60" requestTimeout="00:04:00">
      <environmentVariables>
        <environmentVariable name="PYTHONPATH" value="." />
        <environmentVariable name="PORT" value="%HTTP_PLATFORM_PORT%" />
        <environmentVariable name="FLASK_ENV" value="production" />
        <environmentVariable name="CUSTOM_DOMAIN" value="tiroesportivobrasileiro.com.br" />
      </environmentVariables>
    </httpPlatform>
    <rewrite>
      <rules>
        <rule name="Force HTTPS" enabled="true">
          <match url="(.*)" ignoreCase="false" />
          <conditions>
            <add input="{HTTPS}" pattern="off" ignoreCase="true" />
            <add input="{HTTP_HOST}" pattern="tiroesportivobrasileiro\.com\.br$" ignoreCase="true" />
          </conditions>
          <action type="Redirect" url="https://{HTTP_HOST}/{R:1}" appendQueryString="true" redirectType="Permanent" />
        </rule>
      </rules>
    </rewrite>
  </system.webServer>
</configuration>
EOF

# Frontend structure
mkdir -p frontend/{src,public}

# package.json para frontend
cat > frontend/package.json << 'EOF'
{
  "name": "tiroesportivo-frontend",
  "version": "1.0.0",
  "description": "Frontend para Tiro Esportivo Brasileiro",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.0.0",
    "vite": "^4.4.0"
  }
}
EOF

# vite.config.js
cat > frontend/vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  build: {
    outDir: 'dist',
    assetsDir: 'assets'
  },
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:5000',
        changeOrigin: true
      }
    }
  }
})
EOF

# Main Flask app
cat > src/main.py << 'EOF'
import os
import sys
import logging
from flask import Flask, send_from_directory, jsonify
from flask_cors import CORS
from datetime import datetime

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Criar aplicação Flask
app = Flask(__name__, static_folder='../frontend/dist', static_url_path='')

# Configurar CORS
CORS(app, origins=['https://tiroesportivobrasileiro.com.br', 'https://tiroesportivobrasileiro-dev.azurewebsites.net'])

# Configurações
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'dev-secret-key-change-in-production')
app.config['CUSTOM_DOMAIN'] = os.environ.get('CUSTOM_DOMAIN', 'tiroesportivobrasileiro.com.br')

@app.route('/')
def index():
    """Servir frontend React"""
    return send_from_directory(app.static_folder, 'index.html')

@app.route('/api/health')
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'version': '1.0.0',
        'domain': app.config['CUSTOM_DOMAIN']
    })

@app.route('/api/info')
def app_info():
    """Informações da aplicação"""
    return jsonify({
        'name': 'Tiro Esportivo Brasileiro',
        'domain': 'TIROESPORTIVOBRASILEIRO.COM.BR',
        'version': '1.0.0',
        'environment': os.environ.get('FLASK_ENV', 'production'),
        'subscription': '130706ec-b9d5-4554-8be1-ef855c2cf41a',
        'resource_group': 'tiroesportivo'
    })

@app.errorhandler(404)
def not_found(error):
    """Redirecionar 404 para React Router"""
    return send_from_directory(app.static_folder, 'index.html')

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
EOF

# Frontend básico
cat > frontend/public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tiro Esportivo Brasileiro</title>
    <meta name="description" content="Sistema de controle de tiro esportivo - TIROESPORTIVOBRASILEIRO.COM.BR">
</head>
<body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
</body>
</html>
EOF

cat > frontend/src/main.jsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOF

cat > frontend/src/App.jsx << 'EOF'
import React, { useState, useEffect } from 'react'

function App() {
  const [info, setInfo] = useState(null)
  const [health, setHealth] = useState(null)

  useEffect(() => {
    // Buscar informações da aplicação
    fetch('/api/info')
      .then(res => res.json())
      .then(data => setInfo(data))
      .catch(err => console.error('Erro ao buscar info:', err))

    // Buscar status de saúde
    fetch('/api/health')
      .then(res => res.json())
      .then(data => setHealth(data))
      .catch(err => console.error('Erro ao buscar health:', err))
  }, [])

  return (
    <div style={{ 
      fontFamily: 'Arial, sans-serif', 
      maxWidth: '800px', 
      margin: '0 auto', 
      padding: '20px',
      backgroundColor: '#f5f5f5',
      minHeight: '100vh'
    }}>
      <header style={{ 
        textAlign: 'center', 
        marginBottom: '40px',
        backgroundColor: 'white',
        padding: '30px',
        borderRadius: '10px',
        boxShadow: '0 2px 10px rgba(0,0,0,0.1)'
      }}>
        <h1 style={{ 
          color: '#2c3e50', 
          fontSize: '2.5em',
          marginBottom: '10px'
        }}>
          🎯 Tiro Esportivo Brasileiro
        </h1>
        <p style={{ 
          color: '#7f8c8d', 
          fontSize: '1.2em',
          margin: '0'
        }}>
          TIROESPORTIVOBRASILEIRO.COM.BR
        </p>
      </header>

      <main>
        <div style={{ 
          display: 'grid', 
          gap: '20px',
          gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))'
        }}>
          {/* Card de Informações */}
          <div style={{ 
            backgroundColor: 'white',
            padding: '25px',
            borderRadius: '10px',
            boxShadow: '0 2px 10px rgba(0,0,0,0.1)'
          }}>
            <h2 style={{ color: '#2c3e50', marginBottom: '20px' }}>
              📋 Informações da Aplicação
            </h2>
            {info ? (
              <div style={{ lineHeight: '1.8' }}>
                <p><strong>Nome:</strong> {info.name}</p>
                <p><strong>Versão:</strong> {info.version}</p>
                <p><strong>Ambiente:</strong> {info.environment}</p>
                <p><strong>Subscription:</strong> {info.subscription}</p>
                <p><strong>Resource Group:</strong> {info.resource_group}</p>
              </div>
            ) : (
              <p>Carregando informações...</p>
            )}
          </div>

          {/* Card de Status */}
          <div style={{ 
            backgroundColor: 'white',
            padding: '25px',
            borderRadius: '10px',
            boxShadow: '0 2px 10px rgba(0,0,0,0.1)'
          }}>
            <h2 style={{ color: '#2c3e50', marginBottom: '20px' }}>
              ✅ Status da Aplicação
            </h2>
            {health ? (
              <div style={{ lineHeight: '1.8' }}>
                <p>
                  <strong>Status:</strong> 
                  <span style={{ 
                    color: health.status === 'healthy' ? '#27ae60' : '#e74c3c',
                    marginLeft: '10px'
                  }}>
                    {health.status === 'healthy' ? '🟢 Saudável' : '🔴 Problema'}
                  </span>
                </p>
                <p><strong>Última verificação:</strong> {new Date(health.timestamp).toLocaleString('pt-BR')}</p>
                <p><strong>Domínio:</strong> {health.domain}</p>
              </div>
            ) : (
              <p>Verificando status...</p>
            )}
          </div>
        </div>

        {/* Seção de Funcionalidades */}
        <div style={{ 
          backgroundColor: 'white',
          padding: '30px',
          borderRadius: '10px',
          boxShadow: '0 2px 10px rgba(0,0,0,0.1)',
          marginTop: '20px'
        }}>
          <h2 style={{ color: '#2c3e50', marginBottom: '25px' }}>
            🚀 Funcionalidades
          </h2>
          <div style={{ 
            display: 'grid', 
            gap: '15px',
            gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))'
          }}>
            <div style={{ padding: '15px', backgroundColor: '#ecf0f1', borderRadius: '8px' }}>
              <h3 style={{ color: '#2c3e50', margin: '0 0 10px 0' }}>🎯 Controle de Treinos</h3>
              <p style={{ margin: '0', color: '#7f8c8d' }}>Sistema completo de habitualidade</p>
            </div>
            <div style={{ padding: '15px', backgroundColor: '#ecf0f1', borderRadius: '8px' }}>
              <h3 style={{ color: '#2c3e50', margin: '0 0 10px 0' }}>🏆 Ranking</h3>
              <p style={{ margin: '0', color: '#7f8c8d' }}>Acompanhamento de competições</p>
            </div>
            <div style={{ padding: '15px', backgroundColor: '#ecf0f1', borderRadius: '8px' }}>
              <h3 style={{ color: '#2c3e50', margin: '0 0 10px 0' }}>🔫 Arsenal</h3>
              <p style={{ margin: '0', color: '#7f8c8d' }}>Gestão de equipamentos</p>
            </div>
            <div style={{ padding: '15px', backgroundColor: '#ecf0f1', borderRadius: '8px' }}>
              <h3 style={{ color: '#2c3e50', margin: '0 0 10px 0' }}>📊 Relatórios</h3>
              <p style={{ margin: '0', color: '#7f8c8d' }}>Análise de desempenho</p>
            </div>
          </div>
        </div>

        {/* Credenciais */}
        <div style={{ 
          backgroundColor: '#3498db',
          color: 'white',
          padding: '25px',
          borderRadius: '10px',
          marginTop: '20px',
          textAlign: 'center'
        }}>
          <h2 style={{ margin: '0 0 15px 0' }}>👤 Credenciais de Acesso</h2>
          <div style={{ display: 'flex', justifyContent: 'center', gap: '40px', flexWrap: 'wrap' }}>
            <div>
              <strong>Demo:</strong> demo / demo123
            </div>
            <div>
              <strong>Admin:</strong> admin / admin123
            </div>
          </div>
        </div>
      </main>

      <footer style={{ 
        textAlign: 'center', 
        marginTop: '40px',
        padding: '20px',
        color: '#7f8c8d'
      }}>
        <p>🚀 Desenvolvido com Azure DevOps + Cloud Shell</p>
        <p>Subscription: 130706ec-b9d5-4554-8be1-ef855c2cf41a</p>
      </footer>
    </div>
  )
}

export default App
EOF

# Testes básicos
mkdir -p tests
cat > tests/test_main.py << 'EOF'
import pytest
import sys
import os

# Adicionar src ao path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from main import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_health_check(client):
    """Testar endpoint de health check"""
    rv = client.get('/api/health')
    assert rv.status_code == 200
    data = rv.get_json()
    assert data['status'] == 'healthy'

def test_app_info(client):
    """Testar endpoint de informações"""
    rv = client.get('/api/info')
    assert rv.status_code == 200
    data = rv.get_json()
    assert data['name'] == 'Tiro Esportivo Brasileiro'

def test_index(client):
    """Testar página inicial"""
    rv = client.get('/')
    assert rv.status_code == 200
EOF

# pytest.ini
cat > pytest.ini << 'EOF'
[tool:pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = -v --tb=short
EOF

# Pull request template
mkdir -p .azuredevops
cat > .azuredevops/pull_request_template.md << 'EOF'
# 🔄 Pull Request - Tiro Esportivo Brasileiro

## 📋 Descrição
<!-- Descreva as mudanças implementadas -->

## 🎯 Tipo de Mudança
- [ ] 🐛 Bug fix
- [ ] ✨ Nova funcionalidade
- [ ] 💥 Breaking change
- [ ] 📚 Documentação
- [ ] 🎨 Estilo
- [ ] ♻️ Refatoração
- [ ] ⚡ Performance
- [ ] ✅ Testes

## ✅ Checklist
- [ ] Código revisado
- [ ] Testes adicionados/atualizados
- [ ] Documentação atualizada
- [ ] Pipeline passa sem erros

## 🌐 TIROESPORTIVOBRASILEIRO.COM.BR
EOF

log "✅ Estrutura do projeto criada"

# Commit e push
log "📝 Fazendo commit das mudanças..."
git add .
git commit -m "feat: estrutura completa do projeto

- Pipelines Azure DevOps configurados
- Backend Flask com health checks
- Frontend React básico
- Testes automatizados
- Configurações para Azure Web App
- Subscription: 130706ec-b9d5-4554-8be1-ef855c2cf41a
- Resource Group: tiroesportivo
- Domínio: tiroesportivobrasileiro.com.br"

git push origin main

log "✅ Upload concluído!"

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                  📁 UPLOAD CONCLUÍDO!                       ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}📋 Arquivos enviados para:${NC}"
echo -e "${BLUE}Repository:${NC} https://dev.azure.com/$ORGANIZATION_NAME/$PROJECT_NAME/_git/$PROJECT_NAME"
echo ""
echo -e "${CYAN}📋 Próximos passos:${NC}"
echo -e "${YELLOW}1.${NC} Configure Service Connection no Azure DevOps"
echo -e "${YELLOW}2.${NC} Configure os pipelines (azure-pipelines.yml e infrastructure-pipeline.yml)"
echo -e "${YELLOW}3.${NC} Execute o pipeline de infraestrutura primeiro"
echo -e "${YELLOW}4.${NC} Configure DNS no registrador do domínio"
echo -e "${YELLOW}5.${NC} Execute o pipeline principal para deploy"
echo ""
echo -e "${GREEN}🎯 Projeto pronto para TIROESPORTIVOBRASILEIRO.COM.BR!${NC}"

