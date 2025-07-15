# Shooting Sports - Aplicação de Controle de Tiro Esportivo

## Visão Geral

A aplicação **Shooting Sports** é uma plataforma web completa para gerenciamento e controle de atividades de tiro esportivo. Desenvolvida com base na análise da planilha de controle fornecida, a aplicação oferece funcionalidades abrangentes para:

- Gestão de acervo de armas
- Controle de sessões de treinamento
- Acompanhamento de ranking em competições
- Sistema de níveis e progressão
- Análise estatística de desempenho

## Arquitetura da Aplicação

### Backend (Flask)
- **Framework**: Flask (Python)
- **Banco de Dados**: SQLite
- **APIs**: RESTful APIs para todas as funcionalidades
- **Porta**: 5000

### Frontend (React)
- **Framework**: React com Vite
- **UI Components**: shadcn/ui + Tailwind CSS
- **Gráficos**: Recharts
- **Ícones**: Lucide React
- **Porta**: 5173

## Funcionalidades Principais

### 1. Dashboard
- Visão geral das estatísticas de treinamento
- Indicadores de desempenho (sessões, disparos, precisão, pontuação)
- Nível atual do usuário com progresso
- Sessões recentes de treinamento

### 2. Arsenal
- Cadastro e gestão de armas do acervo
- Filtros por calibre, proprietário e busca textual
- Informações detalhadas de cada arma
- Funcionalidades de edição e exclusão

### 3. Ranking
- Acompanhamento de desempenho em competições
- Gráficos comparativos por modalidade
- Histórico de evolução por competição
- Estatísticas detalhadas por modalidade

### 4. Treinamento
- Registro de sessões de treinamento
- Controle de disparos, acertos e pontuação
- Estatísticas por arma utilizada
- Histórico completo de sessões

### 5. Níveis
- Sistema de progressão baseado em pontuação
- 4 níveis: Sem Nível, Nível I, II e III
- Barras de progresso visuais
- Dicas para evolução

## Estrutura de Dados

### Modelos Principais

#### Weapon (Arma)
- `id`: Identificador único
- `name`: Nome/modelo da arma
- `caliber`: Calibre da munição
- `owner`: Proprietário da arma
- `created_at`: Data de cadastro

#### TrainingSession (Sessão de Treinamento)
- `id`: Identificador único
- `weapon_id`: Referência à arma utilizada
- `shots_fired`: Número de disparos
- `hits`: Número de acertos
- `score`: Pontuação obtida
- `notes`: Observações
- `duration_minutes`: Duração em minutos
- `date`: Data da sessão

#### Competition (Competição)
- `id`: Identificador único
- `name`: Nome da competição
- `description`: Descrição detalhada

#### CompetitionScore (Pontuação em Competição)
- `id`: Identificador único
- `competition_id`: Referência à competição
- `score`: Pontuação obtida
- `stage`: Etapa da competição
- `date`: Data da participação

#### Level (Nível)
- `id`: Identificador único
- `name`: Nome do nível
- `message`: Mensagem motivacional
- `min_score`: Pontuação mínima necessária
- `order`: Ordem do nível

#### UserProgress (Progresso do Usuário)
- `id`: Identificador único
- `current_level_id`: Nível atual
- `total_sessions`: Total de sessões
- `total_shots`: Total de disparos
- `total_hits`: Total de acertos
- `average_score`: Pontuação média
- `last_session_date`: Data da última sessão

## APIs Disponíveis

### Armas
- `GET /api/weapons` - Listar todas as armas
- `POST /api/weapons` - Criar nova arma
- `PUT /api/weapons/{id}` - Atualizar arma
- `DELETE /api/weapons/{id}` - Excluir arma

### Sessões de Treinamento
- `GET /api/training-sessions` - Listar sessões
- `POST /api/training-sessions` - Criar nova sessão
- `PUT /api/training-sessions/{id}` - Atualizar sessão
- `DELETE /api/training-sessions/{id}` - Excluir sessão
- `GET /api/training-sessions/stats` - Estatísticas gerais
- `GET /api/training-sessions/recent` - Sessões recentes

### Competições
- `GET /api/competitions` - Listar competições
- `GET /api/competitions/ranking` - Ranking geral
- `GET /api/competitions/stats` - Estatísticas
- `GET /api/competitions/{id}/evolution` - Evolução por competição

### Níveis
- `GET /api/levels` - Listar todos os níveis
- `GET /api/progress` - Progresso atual do usuário
- `GET /api/progress/next-level` - Informações do próximo nível
- `POST /api/progress/update` - Atualizar progresso

## Dados Iniciais

A aplicação é populada com dados baseados na planilha original:

### Armas (14 unidades)
- Old - TS9 (9mm)
- Fer - TS9 (9mm)
- JST - RT889 (.38SPL)
- JST - G17 (9mm)
- Fer - TX22 (.22LR)
- Dra - XD (9mm)
- Dra - RT856 (.38SPL)
- Mig - PT1911 (.45)
- Fer - RT838 (.38SPL)
- Fer - PT58 (.380)
- Tex - Tanfoglio (9mm)
- Tex - GP (.380)
- Tex - RT627 - 38 (.38SPL)
- CTJ - G25 (.380)

### Competições (9 modalidades)
- Copa Brasil
- Campeonato Nacional
- Nacional 25m
- Steel Gauge
- Western
- Tactical Shotgun
- SWP Carabina
- SWP Revolver
- SWP Pistola

### Níveis (4 níveis)
- **Sem Nível** (0 pts): "Vai perder seu CR, agiliza!"
- **Nível I** (50 pts): "Você pode mais do que isso, bora!"
- **Nível II** (100 pts): "Está bom, falta pouco para o topo!"
- **Nível III** (150 pts): "Ah, metido, já se acha um sniper!"

## Instalação e Execução

### Pré-requisitos
- Python 3.11+
- Node.js 20+
- npm ou pnpm

### Backend (Flask)
```bash
cd shooting-sports-app
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou venv\Scripts\activate  # Windows
pip install -r requirements.txt
python populate_db.py  # Popular banco com dados iniciais
python src/main.py
```

### Frontend (React)
```bash
cd shooting-sports-frontend
npm install
npm run dev -- --host
```

### Acessar a Aplicação
- Frontend: http://localhost:5173
- Backend API: http://localhost:5000

## Características Técnicas

### Responsividade
- Design totalmente responsivo
- Suporte a dispositivos móveis e desktop
- Menu lateral colapsável em telas pequenas

### Performance
- Carregamento otimizado de dados
- Componentes React otimizados
- Lazy loading quando necessário

### Usabilidade
- Interface intuitiva e moderna
- Feedback visual para ações do usuário
- Navegação fluida entre seções

### Segurança
- Validação de dados no frontend e backend
- Sanitização de inputs
- Tratamento de erros robusto

## Possíveis Melhorias Futuras

1. **Autenticação e Autorização**
   - Sistema de login/logout
   - Múltiplos usuários
   - Perfis de acesso

2. **Relatórios Avançados**
   - Exportação para PDF/Excel
   - Gráficos mais detalhados
   - Análises preditivas

3. **Integração com Dispositivos**
   - Importação automática de dados
   - Sincronização com cronômetros
   - Integração com alvos eletrônicos

4. **Funcionalidades Sociais**
   - Compartilhamento de resultados
   - Ranking entre usuários
   - Desafios e conquistas

5. **Backup e Sincronização**
   - Backup automático na nuvem
   - Sincronização entre dispositivos
   - Histórico de versões

## Suporte e Manutenção

A aplicação foi desenvolvida com foco em:
- Código limpo e bem documentado
- Arquitetura modular e escalável
- Facilidade de manutenção
- Extensibilidade para novas funcionalidades

## Conclusão

A aplicação **Shooting Sports** oferece uma solução completa e moderna para o controle de atividades de tiro esportivo, transformando os dados da planilha original em uma experiência interativa e visual, facilitando o acompanhamento do progresso e a gestão das atividades esportivas.

