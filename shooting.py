from src.models.user import db
from datetime import datetime

class Weapon(db.Model):
    """Modelo para armas do acervo"""
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)  # Nome/modelo da arma
    caliber = db.Column(db.String(20), nullable=False)  # Calibre (.22LR, 9mm, .38SPL, etc.)
    owner = db.Column(db.String(50), nullable=False)  # Proprietário (Old, Fer, JST, etc.)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=True)  # Usuário que cadastrou
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relacionamentos
    training_sessions = db.relationship('TrainingSession', backref='weapon', lazy=True)
    
    def __repr__(self):
        return f'<Weapon {self.name} - {self.caliber}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'caliber': self.caliber,
            'owner': self.owner,
            'user_id': self.user_id,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

class Competition(db.Model):
    """Modelo para modalidades de competição"""
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False, unique=True)
    description = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relacionamentos
    scores = db.relationship('CompetitionScore', backref='competition', lazy=True)
    
    def __repr__(self):
        return f'<Competition {self.name}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'description': self.description,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }

class CompetitionScore(db.Model):
    """Modelo para pontuações em competições"""
    id = db.Column(db.Integer, primary_key=True)
    competition_id = db.Column(db.Integer, db.ForeignKey('competition.id'), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    score = db.Column(db.Float, nullable=False)
    stage = db.Column(db.String(50))  # Etapa da competição
    date = db.Column(db.Date, nullable=False)
    notes = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def __repr__(self):
        return f'<CompetitionScore {self.score} - {self.competition.name}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'competition_id': self.competition_id,
            'competition_name': self.competition.name if self.competition else None,
            'user_id': self.user_id,
            'score': self.score,
            'stage': self.stage,
            'date': self.date.isoformat() if self.date else None,
            'notes': self.notes,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }

class Level(db.Model):
    """Modelo para níveis de progressão"""
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), nullable=False, unique=True)
    message = db.Column(db.String(200), nullable=False)  # Mensagem motivacional
    min_score = db.Column(db.Float, nullable=False)  # Pontuação mínima para alcançar
    order = db.Column(db.Integer, nullable=False)  # Ordem do nível (0, 1, 2, 3...)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relacionamentos
    user_progress = db.relationship('UserProgress', backref='current_level', lazy=True)
    
    def __repr__(self):
        return f'<Level {self.name}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'message': self.message,
            'min_score': self.min_score,
            'order': self.order,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }

class TrainingSession(db.Model):
    """Modelo para sessões de treinamento"""
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    weapon_id = db.Column(db.Integer, db.ForeignKey('weapon.id'), nullable=False)
    shots_fired = db.Column(db.Integer, nullable=False)  # Número de disparos
    hits = db.Column(db.Integer, nullable=False)  # Número de acertos
    score = db.Column(db.Float, nullable=False)  # Pontuação obtida
    notes = db.Column(db.Text)  # Observações
    duration_minutes = db.Column(db.Integer)  # Duração em minutos
    date = db.Column(db.Date, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    @property
    def accuracy(self):
        """Calcula a precisão da sessão"""
        if self.shots_fired == 0:
            return 0
        return (self.hits / self.shots_fired) * 100
    
    def __repr__(self):
        return f'<TrainingSession {self.date} - {self.score} pts>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'weapon_id': self.weapon_id,
            'weapon_name': f"{self.weapon.name} - {self.weapon.caliber}" if self.weapon else None,
            'shots_fired': self.shots_fired,
            'hits': self.hits,
            'score': self.score,
            'accuracy': self.accuracy,
            'notes': self.notes,
            'duration_minutes': self.duration_minutes,
            'date': self.date.isoformat() if self.date else None,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }

class UserProgress(db.Model):
    """Modelo para progresso do usuário"""
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    current_level_id = db.Column(db.Integer, db.ForeignKey('level.id'), nullable=False)
    total_sessions = db.Column(db.Integer, default=0)
    total_shots = db.Column(db.Integer, default=0)
    total_hits = db.Column(db.Integer, default=0)
    average_score = db.Column(db.Float, default=0.0)
    last_session_date = db.Column(db.Date)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    @property
    def accuracy(self):
        """Calcula a precisão geral"""
        if self.total_shots == 0:
            return 0
        return (self.total_hits / self.total_shots) * 100
    
    def __repr__(self):
        return f'<UserProgress User:{self.user_id} Level:{self.current_level.name}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'user_id': self.user_id,
            'current_level_id': self.current_level_id,
            'current_level': self.current_level.to_dict() if self.current_level else None,
            'total_sessions': self.total_sessions,
            'total_shots': self.total_shots,
            'total_hits': self.total_hits,
            'average_score': self.average_score,
            'accuracy': self.accuracy,
            'last_session_date': self.last_session_date.isoformat() if self.last_session_date else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }

