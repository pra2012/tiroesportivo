import os
import sys
# DON'T CHANGE THIS !!!
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from flask import Flask, send_from_directory, jsonify
from flask_cors import CORS
from src.models.user import db
from src.models.shooting import Weapon, Competition, CompetitionScore, Level, TrainingSession, UserProgress
from src.routes.user import user_bp
from src.routes.auth import auth_bp
from src.routes.weapons import weapons_bp
from src.routes.competitions import competitions_bp
from src.routes.levels import levels_bp
from src.routes.training import training_bp

app = Flask(__name__, static_folder=os.path.join(os.path.dirname(__file__), 'static'))
app.config['SECRET_KEY'] = 'shooting-sports-secret-key-2024-secure'

# Habilitar CORS para todas as rotas
CORS(app, origins=['http://localhost:5173', 'http://localhost:3000'])

# Registrar blueprints
app.register_blueprint(user_bp, url_prefix='/api')
app.register_blueprint(auth_bp, url_prefix='/api/auth')
app.register_blueprint(weapons_bp, url_prefix='/api')
app.register_blueprint(competitions_bp, url_prefix='/api')
app.register_blueprint(levels_bp, url_prefix='/api')
app.register_blueprint(training_bp, url_prefix='/api')

# Configuração do banco de dados
app.config['SQLALCHEMY_DATABASE_URI'] = f"sqlite:///{os.path.join(os.path.dirname(__file__), '..', 'instance', 'database.db')}"
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db.init_app(app)

# Health check para monitoramento
@app.route('/api/health')
def health_check():
    """Endpoint de verificação de saúde da aplicação"""
    return jsonify({
        'status': 'healthy',
        'message': 'Shooting Sports API is running',
        'version': '1.0.0'
    }), 200

# Criar tabelas do banco de dados
with app.app_context():
    db.create_all()

@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def serve(path):
    """Servir arquivos estáticos do frontend"""
    static_folder_path = app.static_folder
    if static_folder_path is None:
        return "Static folder not configured", 404

    if path != "" and os.path.exists(os.path.join(static_folder_path, path)):
        return send_from_directory(static_folder_path, path)
    else:
        index_path = os.path.join(static_folder_path, 'index.html')
        if os.path.exists(index_path):
            return send_from_directory(static_folder_path, 'index.html')
        else:
            return "index.html not found", 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
