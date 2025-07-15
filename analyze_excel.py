import pandas as pd
import numpy as np

# Ler a planilha Excel
file_path = '/home/ubuntu/upload/HABITUALIDADE-TREINOASECOVERSAO2.xlsx'

try:
    # Ler todas as abas da planilha
    excel_file = pd.ExcelFile(file_path)
    print(f"Abas encontradas: {excel_file.sheet_names}")
    
    # Analisar cada aba
    for sheet_name in excel_file.sheet_names:
        print(f"\n{'='*50}")
        print(f"Analisando aba: {sheet_name}")
        print(f"{'='*50}")
        
        df = pd.read_excel(file_path, sheet_name=sheet_name)
        
        print(f"Dimensões: {df.shape[0]} linhas x {df.shape[1]} colunas")
        print(f"\nColunas:")
        for i, col in enumerate(df.columns):
            print(f"  {i+1}. {col}")
        
        print(f"\nPrimeiras 5 linhas:")
        print(df.head())
        
        print(f"\nTipos de dados:")
        print(df.dtypes)
        
        print(f"\nInformações estatísticas:")
        print(df.describe(include='all'))
        
        # Verificar valores nulos
        null_counts = df.isnull().sum()
        if null_counts.sum() > 0:
            print(f"\nValores nulos por coluna:")
            print(null_counts[null_counts > 0])
        
        print(f"\n" + "-"*50)

except Exception as e:
    print(f"Erro ao ler o arquivo: {e}")

