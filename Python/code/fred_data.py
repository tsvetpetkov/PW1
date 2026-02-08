#####
import numpy as np
import pandas as pd

from fredapi import Fred
#####


#####
# List of States
states = [
    'al', 'ak', 'az', 'ar', 'ca', 'co', 'ct', 'de', 'dc',
    'fl', 'ga', 'hi', 'id', 'il', 'in', 'ia', 'ks', 'ky',
    'la', 'me', 'md', 'ma', 'mi', 'mn', 'ms', 'mo', 'mt',
    'ne', 'nv', 'nh', 'nj', 'nm', 'ny', 'nc', 'nd', 'oh',
    'ok', 'or', 'pa', 'ri', 'sc', 'sd', 'tn', 'tx', 'ut',
    'vt', 'va', 'wa', 'wv', 'wi', 'wy',
]
#####


##### FRED Data to Pandas Dataframe
def fred_to_df(api_key: str, series_lbl: str, as_of_date: str = None, data_lbl: str = None) -> pd.core.frame.DataFrame:
    if data_lbl is None:
        data_lbl = series_lbl.lower()
    
    fred = Fred(api_key = api_key)
    
    if as_of_date is None:
        series = fred.get_series(series_lbl)
        
        df = series.to_frame().dropna().reset_index()
    else:
        df = fred.get_series_as_of_date(series_lbl, as_of_date)
        
        df['realtime_start'] = pd.to_datetime(df['realtime_start'], format = '%m/%d/%Y', errors = 'coerce')
        df['date'] = pd.to_datetime(df['date'], format = '%m/%d/%Y', errors = 'coerce')
        df['value'] = pd.to_numeric(df['value'], errors = 'coerce')
        
        df = df.dropna().reset_index(drop = True)
        
        df = df.merge(df.groupby('date')['realtime_start'].max().rename('max_realtime_start'), on = 'date', how = 'left')
        df = df[(df['realtime_start'] == df['max_realtime_start'])].reset_index(drop = True)
        
        df = df[['date', 'value']]
    
    df.columns = ['date', data_lbl]
    
    df['yyyymm'] = 100 * df['date'].dt.year + df['date'].dt.month
    df = df.dropna(subset = ['yyyymm']).sort_values('yyyymm').reset_index(drop = True)
    
    if df['yyyymm'].duplicated().any():
        df = df.merge(df.groupby('yyyymm')['date'].max().rename('max_date'), on = 'yyyymm', how = 'left')
        df = df[(df['date'] == df['max_date'])].reset_index(drop = True)
    
    df = df[['yyyymm', data_lbl]]
    return df
#####


##### Formatted FRED Macro Dataframe
def fred_macro_df(api_key: str, series_lbl: str, as_of_date: str = None, data_lbl: str = None, take_log: bool = False) -> pd.core.frame.DataFrame:
    df = fred_to_df(api_key, series_lbl, as_of_date, data_lbl)
    
    if series_lbl == 'BBKMGDP':
        df[data_lbl] = df[data_lbl] / 1200
        df.loc[0, data_lbl] = 100
        df.loc[1:, data_lbl] += 1
        df[data_lbl] = df[data_lbl].cumprod()
    
    if take_log == True:
        df[data_lbl] = np.log(df[data_lbl]) * 100
    
    return df
#####


##### State-Level Unemployment Rate
def fred_sur_df(api_key: str, state: str, as_of_date: str = None, label: str = 'sur_sa', num_lags: int = 12) -> pd.core.frame.DataFrame:
    df = fred_to_df(api_key, state + 'ur', as_of_date, label)
    
    df['yyyymm_state'] = df['yyyymm'].astype(str) + '_' + state
    
    for i in range(num_lags + 1):
        df[label + '_l' + str(i)] = df[label].shift(i)
    
    if num_lags >= 12:
        lags_list = [label + '_l' + str(i) for i in range(1, 13)]
        df[label + '_1y_avg'] = sum([df[i] for i in lags_list]) / len(lags_list)
    
    df = df[['yyyymm_state'] + [label + '_l' + str(i) for i in range(num_lags + 1)] + [label + '_1y_avg']]
    return df
#####


##### All State-Level Unemployment Rates
def all_fred_sur_df(api_key: str, as_of_date: str = None, label: str = 'sur_sa', num_lags: int = 12) -> pd.core.frame.DataFrame:
    dfs_list = []
    
    for state in states:
        df_state = fred_sur_df(api_key, state, as_of_date, label, num_lags)
        dfs_list.append(df_state)
    
    df = pd.concat(dfs_list).reset_index(drop = True)
    return df
#####


##### Local CSV Data to Pandas Dataframe
def csv_to_df(data_dir: str, data_lbl: str, take_log: bool = False) -> pd.core.frame.DataFrame:
    df = pd.read_csv(data_dir + '/' + data_lbl + '.csv', float_precision = 'round_trip')
    df['date'] = pd.to_datetime(df['date'], format = '%m/%d/%Y', errors = 'coerce')
    
    df['yyyymm'] = 100 * df['date'].dt.year + df['date'].dt.month
    df = df.dropna(subset = ['yyyymm']).sort_values('yyyymm').reset_index(drop = True)
    
    if take_log == True:
        df[data_lbl] = np.log(df[data_lbl]) * 100
    
    df = df[['yyyymm', data_lbl]]
    return df
#####
