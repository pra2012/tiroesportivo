#!/usr/bin/env python3
"""
Script para popular o banco de dados com dados iniciais
baseados na planilha de controle de tiro esportivo
"""

import os
import sys
import json
from datetime import datetime, timedelta
import random

# Adicionar o diretório raiz ao path
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

def load_initial_data():
    """Carregar dados iniciais baseados na análise da planilha"""
    
    # Importar depois de configurar o path
    from src.main import app
    from src.models.user import db, User
    from src.models.shooting import Weapon, Competition, CompetitionScore, Level, TrainingSession, UserProgress
    
    with app.app_context():
        # Criar todas as tabelas
        db.create_all()
        
        # Verificar se já existem dados
        if User.query.first():
            print("Banco de dados já possui dados. Pulando inicialização.")
            return
        
        print("Inicializando banco de dados...")
        
        # 1. Criar usuário administrador padrão
        admin_user = User(
            username='admin',
            email='admin@shootingsports.com',
            full_name='Administrador do Sistema',
            phone='(11) 99999-9999',
            registration_number='ADMIN001',
            club='Sistema',
            category='Administrador',
            is_admin=True
        )
        admin_user.set_password('admin123')
        db.session.add(admin_user)
        
        # Criar usuário demo
        demo_user = User(
            username='demo',
            email='demo@shootingsports.com',
            full_name='Usuário Demonstração',
            phone='(11) 88888-8888',
            registration_number='DEMO001',
            club='Clube Demonstração',
            category='Amador'
        )
        demo_user.set_password('demo123')
        db.session.add(demo_user)
        
        db.session.commit()
        print("✅ Usuários criados com sucesso!")
        print("   - Admin: admin / admin123")
        print("   - Demo: demo / demo123")
        
        # Obter usuários para associar dados
        admin = User.query.filter_by(username='admin').first()
        demo = User.query.filter_by(username='demo').first()
        
        # 2. Criar armas baseadas na planilha
        weapons_data = [
            {'name': 'Old - TS9', 'caliber': '9mm', 'owner': 'Old', 'user_id': demo.id},
            {'name': 'Fer - TS9', 'caliber': '9mm', 'owner': 'Fer', 'user_id': demo.id},
            {'name': 'JST - RT889', 'caliber': '.38SPL', 'owner': 'JST', 'user_id': demo.id},
            {'name': 'JST - G17', 'caliber': '9mm', 'owner': 'JST', 'user_id': demo.id},
            {'name': 'Fer - TX22', 'caliber': '.22LR', 'owner': 'Fer', 'user_id': demo.id},
            {'name': 'Dra - XD', 'caliber': '9mm', 'owner': 'Dra', 'user_id': demo.id},
            {'name': 'Dra - RT856', 'caliber': '.38SPL', 'owner': 'Dra', 'user_id': demo.id},
            {'name': 'Mig - PT1911', 'caliber': '.45', 'owner': 'Mig', 'user_id': demo.id},
            {'name': 'Fer - RT838', 'caliber': '.38SPL', 'owner': 'Fer', 'user_id': demo.id},
            {'name': 'Fer - PT58', 'caliber': '.380', 'owner': 'Fer', 'user_id': demo.id},
            {'name': 'Tex - Tanfoglio', 'caliber': '9mm', 'owner': 'Tex', 'user_id': demo.id},
            {'name': 'Tex - GP', 'caliber': '.380', 'owner': 'Tex', 'user_id': demo.id},
            {'name': 'Tex - RT627 - 38', 'caliber': '.38SPL', 'owner': 'Tex', 'user_id': demo.id},
            {'name': 'CTJ - G25', 'caliber': '.380', 'owner': 'CTJ', 'user_id': demo.id},
        ]
        
        for weapon_data in weapons_data:
            weapon = Weapon(**weapon_data)
            db.session.add(weapon)
        
        db.session.commit()
        print("✓ Armas criadas")
        
        # 3. Criar níveis de progressão
        levels_data = [
            {'name': 'Sem Nível', 'message': 'Vai perder seu CR, agiliza!', 'min_score': 0, 'order': 0},
            {'name': 'Nível I', 'message': 'Você pode mais do que isso, bora!', 'min_score': 50, 'order': 1},
            {'name': 'Nível II', 'message': 'Está bom, falta pouco para o topo!', 'min_score': 100, 'order': 2},
            {'name': 'Nível III', 'message': 'Ah, metido, já se acha um sniper!', 'min_score': 150, 'order': 3},
        ]
        
        for level_data in levels_data:
            level = Level(**level_data)
            db.session.add(level)
        
        db.session.commit()
        print("✓ Níveis criados")
        
        # 4. Criar competições
        competitions_data = [
            {'name': 'Copa Brasil', 'description': 'Copa Brasil (comecei na BB estou na A)'},
            {'name': 'Campeonato Nacional', 'description': 'Campeonato Nacional (comecei na B estou na A)'},
            {'name': 'Nacional 25m', 'description': 'Nacional 25m'},
            {'name': 'Steel Gauge', 'description': 'Steel Gauge'},
            {'name': 'Western', 'description': 'Western'},
            {'name': 'Tactical Shotgun', 'description': 'Tactical Shotgun'},
            {'name': 'SWP Carabina', 'description': 'SWP Carabina'},
            {'name': 'SWP Revolver', 'description': 'SWP Revolver'},
            {'name': 'SWP Pistola', 'description': 'SWP Pistola'},
        ]
        
        for comp_data in competitions_data:
            competition = Competition(**comp_data)
            db.session.add(competition)
        
        db.session.commit()
        print("✓ Competições criadas")
        
        # 5. Criar pontuações de competições (associadas ao usuário demo)
        competitions = Competition.query.all()
        for competition in competitions:
            # Criar algumas pontuações de exemplo
            for i in range(random.randint(2, 5)):
                score = CompetitionScore(
                    competition_id=competition.id,
                    user_id=demo.id,
                    score=random.uniform(20, 250),
                    stage=i + 1,
                    date=datetime.now().date() - timedelta(days=random.randint(1, 90))
                )
                db.session.add(score)
        
        print("✓ Pontuações de competições criadas")
        
        # 6. Criar sessões de treinamento (associadas ao usuário demo)
        weapons = Weapon.query.all()
        
        for i in range(20):
            weapon = random.choice(weapons)
            shots = random.randint(20, 100)
            hits = random.randint(int(shots * 0.6), shots)
            
            session = TrainingSession(
                user_id=demo.id,
                weapon_id=weapon.id,
                shots_fired=shots,
                hits=hits,
                score=random.uniform(80, 200),
                notes=f"Sessão de treinamento {i + 1}",
                duration_minutes=random.randint(30, 120),
                date=datetime.now().date() - timedelta(days=random.randint(1, 60))
            )
            db.session.add(session)
        
        print("✓ Sessões de treinamento criadas")
        
        # 7. Criar progresso do usuário demo
        first_level = Level.query.order_by(Level.order).first()
        progress = UserProgress(
            user_id=demo.id,
            current_level_id=first_level.id,
            total_sessions=20,
            total_shots=1500,
            total_hits=1200,
            average_score=125.5,
            last_session_date=datetime.now().date() - timedelta(days=1)
        )
        db.session.add(progress)
        
        print("✓ Progresso do usuário criado")
        
        db.session.commit()
        print("\n🎯 Banco de dados populado com sucesso!")
        
        # Mostrar estatísticas
        print(f"\nEstatísticas:")
        print(f"- Usuários: {User.query.count()}")
        print(f"- Armas: {Weapon.query.count()}")
        print(f"- Competições: {Competition.query.count()}")
        print(f"- Pontuações: {CompetitionScore.query.count()}")
        print(f"- Níveis: {Level.query.count()}")
        print(f"- Sessões de treino: {TrainingSession.query.count()}")
        print(f"- Progresso: {UserProgress.query.count()}")

if __name__ == '__main__':
    load_initial_data()

