from flask import Blueprint, request, jsonify
from src.models.shooting import db, Level, UserProgress, TrainingSession
from datetime import datetime

levels_bp = Blueprint('levels', __name__)

@levels_bp.route('/levels', methods=['GET'])
def get_levels():
    """Listar todos os níveis"""
    try:
        levels = Level.query.order_by(Level.order).all()
        return jsonify({
            'success': True,
            'data': [level.to_dict() for level in levels]
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@levels_bp.route('/levels', methods=['POST'])
def create_level():
    """Criar novo nível"""
    try:
        data = request.get_json()
        
        if not data.get('name') or not data.get('message'):
            return jsonify({
                'success': False,
                'error': 'Nome e mensagem são obrigatórios'
            }), 400
        
        level = Level(
            name=data['name'],
            message=data['message'],
            min_score=data.get('min_score', 0),
            order=data.get('order', 0)
        )
        
        db.session.add(level)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': level.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@levels_bp.route('/progress', methods=['GET'])
def get_user_progress():
    """Obter progresso do usuário"""
    try:
        # Para simplicidade, assumimos um único usuário
        progress = UserProgress.query.first()
        
        if not progress:
            # Criar progresso inicial se não existir
            first_level = Level.query.order_by(Level.order).first()
            if first_level:
                progress = UserProgress(current_level_id=first_level.id)
                db.session.add(progress)
                db.session.commit()
        
        return jsonify({
            'success': True,
            'data': progress.to_dict() if progress else None
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@levels_bp.route('/progress/update', methods=['POST'])
def update_user_progress():
    """Atualizar progresso do usuário"""
    try:
        # Recalcular estatísticas baseadas nas sessões de treino
        total_sessions = TrainingSession.query.count()
        
        if total_sessions > 0:
            total_shots = db.session.query(db.func.sum(TrainingSession.shots_fired)).scalar() or 0
            total_hits = db.session.query(db.func.sum(TrainingSession.hits)).scalar() or 0
            avg_score = db.session.query(db.func.avg(TrainingSession.score)).scalar() or 0
            last_session = TrainingSession.query.order_by(TrainingSession.date.desc()).first()
            
            # Determinar nível baseado na pontuação média
            current_level = Level.query.filter(
                Level.min_score <= avg_score
            ).order_by(Level.min_score.desc()).first()
            
            if not current_level:
                current_level = Level.query.order_by(Level.order).first()
        else:
            total_shots = total_hits = avg_score = 0
            last_session = None
            current_level = Level.query.order_by(Level.order).first()
        
        # Atualizar ou criar progresso
        progress = UserProgress.query.first()
        if not progress:
            progress = UserProgress()
            db.session.add(progress)
        
        if current_level:
            progress.current_level_id = current_level.id
        progress.total_sessions = total_sessions
        progress.total_shots = total_shots
        progress.total_hits = total_hits
        progress.average_score = avg_score
        progress.last_session_date = last_session.date if last_session else None
        progress.updated_at = datetime.utcnow()
        
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': progress.to_dict()
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@levels_bp.route('/progress/next-level', methods=['GET'])
def get_next_level_info():
    """Obter informações sobre o próximo nível"""
    try:
        progress = UserProgress.query.first()
        if not progress:
            return jsonify({
                'success': False,
                'error': 'Progresso não encontrado'
            }), 404
        
        current_level = progress.current_level
        next_level = Level.query.filter(
            Level.order > current_level.order
        ).order_by(Level.order).first()
        
        if next_level:
            # Calcular progresso para o próximo nível
            score_needed = next_level.min_score - progress.average_score
            progress_percentage = min(100, (progress.average_score / next_level.min_score) * 100) if next_level.min_score > 0 else 100
        else:
            score_needed = 0
            progress_percentage = 100
        
        return jsonify({
            'success': True,
            'data': {
                'current_level': current_level.to_dict(),
                'next_level': next_level.to_dict() if next_level else None,
                'score_needed': max(0, score_needed),
                'progress_percentage': progress_percentage,
                'is_max_level': next_level is None
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

