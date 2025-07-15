#!/usr/bin/env python3
"""
Arquivo de inicialização para Azure Web App
Shooting Sports - Controle de Tiro Esportivo
"""

import os
import sys
import logging
from pathlib import Path

# Configurar logging para Azure
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler('/home/LogFiles/application.log') if os.path.exists('/home/LogFiles') else logging.NullHandler()
    ]
)

logger = logging.getLogger(__name__)

# Configurar paths para Azure
current_dir = Path(__file__).parent
sys.path.insert(0, str(current_dir))

try:
    # Importar a aplicação Flask
    from src.main import app
    
    # Configurações específicas para Azure
    app.config.update({
        'SECRET_KEY': os.environ.get('SECRET_KEY', 'shooting-sports-azure-secret-key-2024'),
        'SQLALCHEMY_DATABASE_URI': f"sqlite:///{current_dir}/instance/database.db",
        'SQLALCHEMY_TRACK_MODIFICATIONS': False,
        'FLASK_ENV': 'production',
        'DEBUG': False
    })
    
    # Criar diretório instance se não existir
    instance_dir = current_dir / 'instance'
    instance_dir.mkdir(exist_ok=True)
    
    # Inicializar banco de dados se necessário
    with app.app_context():
        from src.models.user import db
        
        # Verificar se o banco existe
        db_path = instance_dir / 'database.db'
        if not db_path.exists():
            logger.info("Criando banco de dados inicial...")
            db.create_all()
            
            # Executar script de população
            try:
                from populate_db import load_initial_data
                load_initial_data()
                logger.info("Banco de dados populado com sucesso!")
            except Exception as e:
                logger.error(f"Erro ao popular banco: {e}")
        else:
            logger.info("Banco de dados já existe")
    
    logger.info("Aplicação inicializada com sucesso!")
    
except Exception as e:
    logger.error(f"Erro ao inicializar aplicação: {e}")
    raise

if __name__ == '__main__':
    # Obter porta do Azure
    port = int(os.environ.get('PORT', 8000))
    
    logger.info(f"Iniciando servidor na porta {port}")
    
    # Executar aplicação
    app.run(
        host='0.0.0.0',
        port=port,
        debug=False,
        threaded=True
    )

