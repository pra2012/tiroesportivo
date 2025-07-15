from flask import Blueprint, request, jsonify
from src.models.shooting import db, Weapon
from datetime import datetime

weapons_bp = Blueprint('weapons', __name__)

@weapons_bp.route('/weapons', methods=['GET'])
def get_weapons():
    """Listar todas as armas"""
    try:
        weapons = Weapon.query.all()
        return jsonify({
            'success': True,
            'data': [weapon.to_dict() for weapon in weapons]
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@weapons_bp.route('/weapons/<int:weapon_id>', methods=['GET'])
def get_weapon(weapon_id):
    """Obter uma arma específica"""
    try:
        weapon = Weapon.query.get_or_404(weapon_id)
        return jsonify({
            'success': True,
            'data': weapon.to_dict()
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@weapons_bp.route('/weapons', methods=['POST'])
def create_weapon():
    """Criar nova arma"""
    try:
        data = request.get_json()
        
        # Validação básica
        if not data.get('name') or not data.get('caliber') or not data.get('owner'):
            return jsonify({
                'success': False,
                'error': 'Nome, calibre e proprietário são obrigatórios'
            }), 400
        
        weapon = Weapon(
            name=data['name'],
            caliber=data['caliber'],
            owner=data['owner']
        )
        
        db.session.add(weapon)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': weapon.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@weapons_bp.route('/weapons/<int:weapon_id>', methods=['PUT'])
def update_weapon(weapon_id):
    """Atualizar arma existente"""
    try:
        weapon = Weapon.query.get_or_404(weapon_id)
        data = request.get_json()
        
        # Atualizar campos se fornecidos
        if 'name' in data:
            weapon.name = data['name']
        if 'caliber' in data:
            weapon.caliber = data['caliber']
        if 'owner' in data:
            weapon.owner = data['owner']
        
        weapon.updated_at = datetime.utcnow()
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': weapon.to_dict()
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@weapons_bp.route('/weapons/<int:weapon_id>', methods=['DELETE'])
def delete_weapon(weapon_id):
    """Deletar arma"""
    try:
        weapon = Weapon.query.get_or_404(weapon_id)
        db.session.delete(weapon)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Arma deletada com sucesso'
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@weapons_bp.route('/weapons/by-caliber/<caliber>', methods=['GET'])
def get_weapons_by_caliber(caliber):
    """Listar armas por calibre"""
    try:
        weapons = Weapon.query.filter_by(caliber=caliber).all()
        return jsonify({
            'success': True,
            'data': [weapon.to_dict() for weapon in weapons]
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@weapons_bp.route('/weapons/by-owner/<owner>', methods=['GET'])
def get_weapons_by_owner(owner):
    """Listar armas por proprietário"""
    try:
        weapons = Weapon.query.filter_by(owner=owner).all()
        return jsonify({
            'success': True,
            'data': [weapon.to_dict() for weapon in weapons]
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@weapons_bp.route('/weapons/stats', methods=['GET'])
def get_weapons_stats():
    """Obter estatísticas das armas"""
    try:
        total_weapons = Weapon.query.count()
        
        # Contar por calibre
        calibers = db.session.query(Weapon.caliber, db.func.count(Weapon.id)).group_by(Weapon.caliber).all()
        caliber_stats = {caliber: count for caliber, count in calibers}
        
        # Contar por proprietário
        owners = db.session.query(Weapon.owner, db.func.count(Weapon.id)).group_by(Weapon.owner).all()
        owner_stats = {owner: count for owner, count in owners}
        
        return jsonify({
            'success': True,
            'data': {
                'total_weapons': total_weapons,
                'by_caliber': caliber_stats,
                'by_owner': owner_stats
            }
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

