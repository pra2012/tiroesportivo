import pandas as pd
import json

# Ler a planilha Excel
file_path = '/home/ubuntu/upload/HABITUALIDADE-TREINOASECOVERSAO2.xlsx'

# Estrutura para armazenar dados processados
data_structure = {}

try:
    excel_file = pd.ExcelFile(file_path)
    print(f"Abas disponíveis: {excel_file.sheet_names}")
    
    # Processar primeira aba (parece ser sobre habitualidade)
    first_sheet = excel_file.sheet_names[0]
    df_habitualidade = pd.read_excel(file_path, sheet_name=first_sheet)
    
    print(f"=== ANÁLISE DETALHADA - {first_sheet} ===")
    print(f"Dados brutos da aba {first_sheet}:")
    print(df_habitualidade.to_string())
    
    # Processar aba "Histórico Ranking"
    df_ranking = pd.read_excel(file_path, sheet_name='Histórico Ranking')
    print(f"\n=== ANÁLISE DETALHADA - HISTÓRICO RANKING ===")
    print(f"Dados brutos da aba Histórico Ranking:")
    print(df_ranking.to_string())
    
    # Estruturar dados de ranking
    ranking_data = {}
    for index, row in df_ranking.iterrows():
        modalidade = row['Histórico Ranking Etapas']
        if pd.notna(modalidade):
            scores = []
            for col in df_ranking.columns[1:]:  # Pular primeira coluna
                if pd.notna(row[col]):
                    scores.append(float(row[col]))
            ranking_data[modalidade] = scores
    
    # Processar aba "Níveis"
    df_niveis = pd.read_excel(file_path, sheet_name='Níveis')
    print(f"\n=== ANÁLISE DETALHADA - NÍVEIS ===")
    print(f"Dados brutos da aba Níveis:")
    print(df_niveis.to_string())
    
    # Estruturar dados de níveis
    niveis_data = {}
    for index, row in df_niveis.iterrows():
        nivel = row['Nível']
        msg = row['Msg']
        niveis_data[nivel] = msg
    
    # Analisar estrutura da primeira aba (habitualidade)
    print(f"\n=== ANÁLISE DA ESTRUTURA DE HABITUALIDADE ===")
    
    # Tentar identificar padrões nos dados da primeira aba
    habitualidade_data = {}
    
    # A primeira aba parece ter informações sobre treinos por data
    # Vamos tentar extrair informações úteis
    for index, row in df_habitualidade.iterrows():
        print(f"Linha {index}: {row.to_dict()}")
    
    # Salvar estrutura de dados processados
    data_structure = {
        'habitualidade_raw': df_habitualidade.to_dict('records'),
        'ranking': ranking_data,
        'niveis': niveis_data,
        'sheet_names': excel_file.sheet_names
    }
    
    print(f"\n=== ESTRUTURA DE DADOS PROCESSADOS ===")
    print(json.dumps(data_structure, indent=2, ensure_ascii=False, default=str))
    
    # Salvar em arquivo JSON para uso posterior
    with open('/home/ubuntu/data_structure.json', 'w', encoding='utf-8') as f:
        json.dump(data_structure, f, indent=2, ensure_ascii=False, default=str)
    
    print(f"\n=== INSIGHTS PARA APLICAÇÃO WEB ===")
    print("1. Sistema de controle de habitualidade de treinos")
    print("2. Histórico de ranking por modalidades de tiro esportivo")
    print("3. Sistema de níveis com mensagens motivacionais")
    print("4. Controle por datas e calibres")
    print("5. Modalidades identificadas:")
    for modalidade in ranking_data.keys():
        print(f"   - {modalidade}")
    
except Exception as e:
    print(f"Erro durante análise: {e}")
    import traceback
    traceback.print_exc()

