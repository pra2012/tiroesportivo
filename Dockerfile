# Dockerfile para Google Cloud Run
FROM node:20-alpine AS frontend-build

# Construir frontend
WORKDIR /frontend
COPY shooting-sports-frontend/package*.json ./
RUN npm ci --only=production

COPY shooting-sports-frontend/ ./
RUN npm run build

# Imagem principal Python
FROM python:3.11-slim

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Configurar diretório de trabalho
WORKDIR /app

# Copiar e instalar dependências Python
COPY shooting-sports-app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código do backend
COPY shooting-sports-app/ .

# Copiar build do frontend para servir como arquivos estáticos
COPY --from=frontend-build /frontend/dist ./static

# Criar diretório para banco de dados
RUN mkdir -p instance

# Criar banco de dados inicial
RUN python populate_db.py

# Configurar usuário não-root
RUN useradd --create-home --shell /bin/bash app
RUN chown -R app:app /app
USER app

# Expor porta
EXPOSE 8080

# Configurar variáveis de ambiente
ENV FLASK_ENV=production
ENV PORT=8080

# Comando para iniciar a aplicação
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 src.main:app

