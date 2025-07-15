from flask import Blueprint, request, jsonify
from src.models.shooting import db, TrainingSession, Weapon
from datetime import datetime, timedelta
from sqlalchemy import desc, func

training_bp = Blueprint('training', __name__)

@training_bp.route('/training-sessions', methods=['GET'])
def get_training_sessions():
    """Listar sessões de treinamento"""
    try:
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 10, type=int)
        weapon_id = request.args.get('weapon_id', type=int)
        
        query = TrainingSession.query
        
        if weapon_id:
            query = query.filter_by(weapon_id=weapon_id)
        
        sessions = query.order_by(desc(TrainingSession.date)).paginate(
            page=page, per_page=per_page, error_out=False
        )
        
        return jsonify({
            'success': True,
            'data': {
                'sessions': [session.to_dict() for session in sessions.items],
                'pagination': {
                    'page': page,
                    'per_page': per_page,
                    'total': sessions.total,
                    'pages': sessions.pages,
                    'has_next': sessions.has_next,
                    'has_prev': sessions.has_prev
                }
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@training_bp.route('/training-sessions', methods=['POST'])
def create_training_session():
    """Criar nova sessão de treinamento"""
    try:
        data = request.get_json()
        
        if not data.get('weapon_id'):
            return jsonify({
                'success': False,
                'error': 'ID da arma é obrigatório'
            }), 400
        
        # Verificar se a arma existe
        weapon = Weapon.query.get(data['weapon_id'])
        if not weapon:
            return jsonify({
                'success': False,
                'error': 'Arma não encontrada'
            }), 404
        
        session = TrainingSession(
            weapon_id=data['weapon_id'],
            shots_fired=data.get('shots_fired', 0),
            hits=data.get('hits', 0),
            score=data.get('score'),
            notes=data.get('notes', ''),
            duration_minutes=data.get('duration_minutes'),
            date=datetime.fromisoformat(data['date']) if data.get('date') else datetime.utcnow()
        )
        
        db.session.add(session)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': session.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@training_bp.route('/training-sessions/<int:session_id>', methods=['GET'])
def get_training_session(session_id):
    """Obter sessão de treinamento específica"""
    try:
        session = TrainingSession.query.get_or_404(session_id)
        return jsonify({
            'success': True,
            'data': session.to_dict()
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@training_bp.route('/training-sessions/<int:session_id>', methods=['PUT'])
def update_training_session(session_id):
    """Atualizar sessão de treinamento"""
    try:
        session = TrainingSession.query.get_or_404(session_id)
        data = request.get_json()
        
        # Atualizar campos se fornecidos
        if 'shots_fired' in data:
            session.shots_fired = data['shots_fired']
        if 'hits' in data:
            session.hits = data['hits']
        if 'score' in data:
            session.score = data['score']
        if 'notes' in data:
            session.notes = data['notes']
        if 'duration_minutes' in data:
            session.duration_minutes = data['duration_minutes']
        if 'date' in data:
            session.date = datetime.fromisoformat(data['date'])
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': session.to_dict()
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@training_bp.route('/training-sessions/<int:session_id>', methods=['DELETE'])
def delete_training_session(session_id):
    """Deletar sessão de treinamento"""
    try:
        session = TrainingSession.query.get_or_404(session_id)
        db.session.delete(session)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Sessão deletada com sucesso'
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@training_bp.route('/training-sessions/stats', methods=['GET'])
def get_training_stats():
    """Obter estatísticas de treinamento"""
    try:
        # Estatísticas gerais
        total_sessions = TrainingSession.query.count()
        total_shots = db.session.query(func.sum(TrainingSession.shots_fired)).scalar() or 0
        total_hits = db.session.query(func.sum(TrainingSession.hits)).scalar() or 0
        avg_accuracy = (total_hits / total_shots * 100) if total_shots > 0 else 0
        avg_score = db.session.query(func.avg(TrainingSession.score)).scalar() or 0
        
        # Estatísticas por arma
        weapon_stats = db.session.query(
            Weapon.name,
            Weapon.caliber,
            func.count(TrainingSession.id).label('sessions'),
            func.sum(TrainingSession.shots_fired).label('shots'),
            func.sum(TrainingSession.hits).label('hits'),
            func.avg(TrainingSession.score).label('avg_score')
        ).join(TrainingSession).group_by(Weapon.id).all()
        
        weapon_data = []
        for weapon_name, caliber, sessions, shots, hits, avg_score in weapon_stats:
            accuracy = (hits / shots * 100) if shots > 0 else 0
            weapon_data.append({
                'weapon_name': weapon_name,
                'caliber': caliber,
                'sessions': sessions,
                'shots': shots or 0,
                'hits': hits or 0,
                'accuracy': round(accuracy, 2),
                'avg_score': round(avg_score, 2) if avg_score else 0
            })
        
        # Últimas 7 sessões para gráfico de evolução
        recent_sessions = TrainingSession.query.order_by(
            desc(TrainingSession.date)
        ).limit(7).all()
        
        evolution_data = []
        for session in reversed(recent_sessions):
            evolution_data.append({
                'date': session.date.strftime('%Y-%m-%d') if session.date else None,
                'accuracy': session.accuracy,
                'score': session.score
            })
        
        return jsonify({
            'success': True,
            'data': {
                'general': {
                    'total_sessions': total_sessions,
                    'total_shots': total_shots,
                    'total_hits': total_hits,
                    'avg_accuracy': round(avg_accuracy, 2),
                    'avg_score': round(avg_score, 2)
                },
                'by_weapon': weapon_data,
                'evolution': evolution_data
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@training_bp.route('/training-sessions/recent', methods=['GET'])
def get_recent_sessions():
    """Obter sessões recentes"""
    try:
        limit = request.args.get('limit', 5, type=int)
        sessions = TrainingSession.query.order_by(
            desc(TrainingSession.date)
        ).limit(limit).all()
        
        return jsonify({
            'success': True,
            'data': [session.to_dict() for session in sessions]
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

