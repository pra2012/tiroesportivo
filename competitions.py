from flask import Blueprint, request, jsonify
from src.models.shooting import db, Competition, CompetitionScore
from datetime import datetime
from sqlalchemy import desc

competitions_bp = Blueprint('competitions', __name__)

@competitions_bp.route('/competitions', methods=['GET'])
def get_competitions():
    """Listar todas as competições"""
    try:
        competitions = Competition.query.all()
        return jsonify({
            'success': True,
            'data': [comp.to_dict() for comp in competitions]
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@competitions_bp.route('/competitions', methods=['POST'])
def create_competition():
    """Criar nova competição"""
    try:
        data = request.get_json()
        
        if not data.get('name'):
            return jsonify({
                'success': False,
                'error': 'Nome da competição é obrigatório'
            }), 400
        
        competition = Competition(
            name=data['name'],
            description=data.get('description', '')
        )
        
        db.session.add(competition)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': competition.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@competitions_bp.route('/competitions/<int:competition_id>/scores', methods=['GET'])
def get_competition_scores(competition_id):
    """Obter pontuações de uma competição"""
    try:
        competition = Competition.query.get_or_404(competition_id)
        scores = CompetitionScore.query.filter_by(competition_id=competition_id).order_by(desc(CompetitionScore.date)).all()
        
        return jsonify({
            'success': True,
            'data': {
                'competition': competition.to_dict(),
                'scores': [score.to_dict() for score in scores]
            }
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@competitions_bp.route('/competitions/<int:competition_id>/scores', methods=['POST'])
def add_competition_score(competition_id):
    """Adicionar pontuação a uma competição"""
    try:
        competition = Competition.query.get_or_404(competition_id)
        data = request.get_json()
        
        if not data.get('score') or not data.get('stage'):
            return jsonify({
                'success': False,
                'error': 'Pontuação e etapa são obrigatórias'
            }), 400
        
        score = CompetitionScore(
            competition_id=competition_id,
            score=float(data['score']),
            stage=int(data['stage']),
            notes=data.get('notes', ''),
            date=datetime.fromisoformat(data['date']) if data.get('date') else datetime.utcnow()
        )
        
        db.session.add(score)
        db.session.commit()
        
        return jsonify({
            'success': True,
            'data': score.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@competitions_bp.route('/competitions/ranking', methods=['GET'])
def get_ranking():
    """Obter ranking geral de todas as competições"""
    try:
        # Obter últimas pontuações de cada competição
        latest_scores = db.session.query(
            Competition.name,
            CompetitionScore.score,
            CompetitionScore.stage,
            CompetitionScore.date
        ).join(CompetitionScore).order_by(
            Competition.name, 
            desc(CompetitionScore.date)
        ).all()
        
        # Agrupar por competição
        ranking_data = {}
        for comp_name, score, stage, date in latest_scores:
            if comp_name not in ranking_data:
                ranking_data[comp_name] = []
            ranking_data[comp_name].append({
                'score': score,
                'stage': stage,
                'date': date.isoformat() if date else None
            })
        
        return jsonify({
            'success': True,
            'data': ranking_data
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@competitions_bp.route('/competitions/<int:competition_id>/evolution', methods=['GET'])
def get_competition_evolution(competition_id):
    """Obter evolução de pontuações de uma competição"""
    try:
        competition = Competition.query.get_or_404(competition_id)
        scores = CompetitionScore.query.filter_by(
            competition_id=competition_id
        ).order_by(CompetitionScore.date).all()
        
        evolution_data = []
        for score in scores:
            evolution_data.append({
                'date': score.date.isoformat() if score.date else None,
                'score': score.score,
                'stage': score.stage
            })
        
        return jsonify({
            'success': True,
            'data': {
                'competition': competition.to_dict(),
                'evolution': evolution_data
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@competitions_bp.route('/competitions/stats', methods=['GET'])
def get_competitions_stats():
    """Obter estatísticas gerais das competições"""
    try:
        total_competitions = Competition.query.count()
        total_scores = CompetitionScore.query.count()
        
        # Média geral de pontuações
        avg_score = db.session.query(db.func.avg(CompetitionScore.score)).scalar()
        
        # Melhor pontuação
        best_score = db.session.query(
            CompetitionScore.score,
            Competition.name
        ).join(Competition).order_by(desc(CompetitionScore.score)).first()
        
        # Competição com mais participações
        most_active = db.session.query(
            Competition.name,
            db.func.count(CompetitionScore.id).label('count')
        ).join(CompetitionScore).group_by(Competition.name).order_by(desc('count')).first()
        
        return jsonify({
            'success': True,
            'data': {
                'total_competitions': total_competitions,
                'total_scores': total_scores,
                'average_score': round(avg_score, 2) if avg_score else 0,
                'best_score': {
                    'score': best_score[0] if best_score else 0,
                    'competition': best_score[1] if best_score else None
                },
                'most_active_competition': {
                    'name': most_active[0] if most_active else None,
                    'participations': most_active[1] if most_active else 0
                }
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

