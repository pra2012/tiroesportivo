from flask import Blueprint, request, jsonify, current_app
from werkzeug.security import generate_password_hash
from src.models.user import db, User
from datetime import datetime
import re
from functools import wraps

auth_bp = Blueprint('auth', __name__)

def token_required(f):
    """Decorator para rotas que requerem autenticação"""
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        
        # Verificar se token está no header Authorization
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            try:
                token = auth_header.split(" ")[1]  # Bearer TOKEN
            except IndexError:
                return jsonify({'message': 'Token malformado'}), 401
        
        if not token:
            return jsonify({'message': 'Token não fornecido'}), 401
        
        try:
            current_user = User.verify_token(token)
            if not current_user:
                return jsonify({'message': 'Token inválido'}), 401
        except:
            return jsonify({'message': 'Token inválido'}), 401
        
        return f(current_user, *args, **kwargs)
    
    return decorated

def validate_email(email):
    """Valida formato do email"""
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None

def validate_password(password):
    """Valida força da senha"""
    if len(password) < 6:
        return False, "Senha deve ter pelo menos 6 caracteres"
    if not re.search(r'[A-Za-z]', password):
        return False, "Senha deve conter pelo menos uma letra"
    if not re.search(r'[0-9]', password):
        return False, "Senha deve conter pelo menos um número"
    return True, "Senha válida"

@auth_bp.route('/register', methods=['POST'])
def register():
    """Cadastro de novo usuário"""
    try:
        data = request.get_json()
        
        # Validar dados obrigatórios
        required_fields = ['username', 'email', 'password', 'full_name']
        for field in required_fields:
            if not data.get(field):
                return jsonify({'message': f'Campo {field} é obrigatório'}), 400
        
        username = data['username'].strip()
        email = data['email'].strip().lower()
        password = data['password']
        full_name = data['full_name'].strip()
        
        # Validações
        if len(username) < 3:
            return jsonify({'message': 'Nome de usuário deve ter pelo menos 3 caracteres'}), 400
        
        if not validate_email(email):
            return jsonify({'message': 'Email inválido'}), 400
        
        is_valid, password_message = validate_password(password)
        if not is_valid:
            return jsonify({'message': password_message}), 400
        
        # Verificar se usuário já existe
        if User.query.filter_by(username=username).first():
            return jsonify({'message': 'Nome de usuário já existe'}), 400
        
        if User.query.filter_by(email=email).first():
            return jsonify({'message': 'Email já cadastrado'}), 400
        
        # Criar novo usuário
        user = User(
            username=username,
            email=email,
            full_name=full_name,
            phone=data.get('phone', '').strip(),
            registration_number=data.get('registration_number', '').strip(),
            club=data.get('club', '').strip(),
            category=data.get('category', '').strip()
        )
        user.set_password(password)
        
        db.session.add(user)
        db.session.commit()
        
        # Gerar token
        token = user.generate_token()
        
        return jsonify({
            'message': 'Usuário cadastrado com sucesso',
            'token': token,
            'user': user.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': f'Erro interno: {str(e)}'}), 500

@auth_bp.route('/login', methods=['POST'])
def login():
    """Login do usuário"""
    try:
        data = request.get_json()
        
        if not data.get('username') or not data.get('password'):
            return jsonify({'message': 'Nome de usuário e senha são obrigatórios'}), 400
        
        username = data['username'].strip()
        password = data['password']
        
        # Buscar usuário (pode ser username ou email)
        user = User.query.filter(
            (User.username == username) | (User.email == username)
        ).first()
        
        if not user or not user.check_password(password):
            return jsonify({'message': 'Credenciais inválidas'}), 401
        
        if not user.is_active:
            return jsonify({'message': 'Conta desativada'}), 401
        
        # Atualizar último login
        user.last_login = datetime.utcnow()
        db.session.commit()
        
        # Gerar token
        token = user.generate_token()
        
        return jsonify({
            'message': 'Login realizado com sucesso',
            'token': token,
            'user': user.to_dict()
        }), 200
        
    except Exception as e:
        return jsonify({'message': f'Erro interno: {str(e)}'}), 500

@auth_bp.route('/profile', methods=['GET'])
@token_required
def get_profile(current_user):
    """Obter perfil do usuário logado"""
    return jsonify({'user': current_user.to_dict()}), 200

@auth_bp.route('/profile', methods=['PUT'])
@token_required
def update_profile(current_user):
    """Atualizar perfil do usuário"""
    try:
        data = request.get_json()
        
        # Campos que podem ser atualizados
        updatable_fields = ['full_name', 'phone', 'registration_number', 'club', 'category']
        
        for field in updatable_fields:
            if field in data:
                setattr(current_user, field, data[field].strip() if data[field] else None)
        
        # Atualizar email se fornecido
        if 'email' in data:
            new_email = data['email'].strip().lower()
            if not validate_email(new_email):
                return jsonify({'message': 'Email inválido'}), 400
            
            # Verificar se email já existe para outro usuário
            existing_user = User.query.filter(
                User.email == new_email,
                User.id != current_user.id
            ).first()
            
            if existing_user:
                return jsonify({'message': 'Email já cadastrado para outro usuário'}), 400
            
            current_user.email = new_email
        
        db.session.commit()
        
        return jsonify({
            'message': 'Perfil atualizado com sucesso',
            'user': current_user.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': f'Erro interno: {str(e)}'}), 500

@auth_bp.route('/change-password', methods=['POST'])
@token_required
def change_password(current_user):
    """Alterar senha do usuário"""
    try:
        data = request.get_json()
        
        if not data.get('current_password') or not data.get('new_password'):
            return jsonify({'message': 'Senha atual e nova senha são obrigatórias'}), 400
        
        current_password = data['current_password']
        new_password = data['new_password']
        
        # Verificar senha atual
        if not current_user.check_password(current_password):
            return jsonify({'message': 'Senha atual incorreta'}), 400
        
        # Validar nova senha
        is_valid, password_message = validate_password(new_password)
        if not is_valid:
            return jsonify({'message': password_message}), 400
        
        # Atualizar senha
        current_user.set_password(new_password)
        db.session.commit()
        
        return jsonify({'message': 'Senha alterada com sucesso'}), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'message': f'Erro interno: {str(e)}'}), 500

@auth_bp.route('/verify-token', methods=['POST'])
def verify_token():
    """Verificar se token é válido"""
    try:
        data = request.get_json()
        token = data.get('token')
        
        if not token:
            return jsonify({'valid': False, 'message': 'Token não fornecido'}), 400
        
        user = User.verify_token(token)
        if user and user.is_active:
            return jsonify({
                'valid': True,
                'user': user.to_dict()
            }), 200
        else:
            return jsonify({'valid': False, 'message': 'Token inválido'}), 401
            
    except Exception as e:
        return jsonify({'valid': False, 'message': f'Erro interno: {str(e)}'}), 500

@auth_bp.route('/logout', methods=['POST'])
@token_required
def logout(current_user):
    """Logout do usuário (apenas confirma que token é válido)"""
    return jsonify({'message': 'Logout realizado com sucesso'}), 200

