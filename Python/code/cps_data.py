#####
import os

import numpy as np

import pandas as pd
pd.options.mode.chained_assignment = None

from ipumspy import IpumsApiClient, MicrodataExtract, readers
#####


#####
# CPS Input Variable/Type Mapping
inp_vars = {
    'serial': np.int32,
    'pernum': np.int8,
    'year': np.int16,
    'month': np.int8,
    'statefip': np.int8,
    'metro': np.int8,
    'wtfinl': np.float64,
    'popstat': np.int8,
    'empstat': np.int8,
    'wkstat': np.int8, # not used
    'sex': np.int8,
    'age': np.int8,
    'race': np.int16,
    'hispan': np.int16,
    'educ': np.int16,
    'schlcoll': np.int8, # not used
    #'citizen': np.int8, # not used and missing
    'marst': np.int8,
    'vetstat': np.int8,
    'occ1990': np.int16,
    'ind1990': np.int16,
}

# CPS Output Variable/Type Mapping
out_vars = {
    #'serial': np.int32,
    #'pernum': np.int8,
    'year': np.int16,
    'month': np.int8,
    'state': str,
    'yyyymm': np.int32,
    'yyyymm_state': str,
    'wtfinl': np.float64,
    'empl_cat': np.int8,
    'sex_cat': np.int8,
    'age_cat': np.int8,
    'race_cat': np.int8,
    'educ_cat': np.int8,
    'occ_cat': np.int8,
    'ind_cat': np.int8,
    #'civilian': np.int8,
    #'employed': np.int8,
    'unemployed': np.int8,
    #'female': np.int8,
    'nonwhite': np.int8,
    #'noncitizen': np.int8,
    'married': np.int8,
    'veteran': np.int8,
    'urban': np.int8,
    #'month_lbl': str,
}

# CPS Sample Mapping
cps_sample_ids = {
    199201: 'cps1992_01s',
    199202: 'cps1992_02b',
    199203: 'cps1992_03b',
    199204: 'cps1992_04b',
    199205: 'cps1992_05b',
    199206: 'cps1992_06s',
    199207: 'cps1992_07b',
    199208: 'cps1992_08b',
    199209: 'cps1992_09s',
    199210: 'cps1992_10s',
    199211: 'cps1992_11s',
    199212: 'cps1992_12b',
    199301: 'cps1993_01s',
    199302: 'cps1993_02b',
    199303: 'cps1993_03b',
    199304: 'cps1993_04s',
    199305: 'cps1993_05s',
    199306: 'cps1993_06b',
    199307: 'cps1993_07b',
    199308: 'cps1993_08b',
    199309: 'cps1993_09s',
    199310: 'cps1993_10s',
    199311: 'cps1993_11b',
    199312: 'cps1993_12b',
    199401: 'cps1994_01b',
    199402: 'cps1994_02s',
    199403: 'cps1994_03b',
    199404: 'cps1994_04b',
    199405: 'cps1994_05b',
    199406: 'cps1994_06s',
    199407: 'cps1994_07b',
    199408: 'cps1994_08b',
    199409: 'cps1994_09s',
    199410: 'cps1994_10s',
    199411: 'cps1994_11s',
    199412: 'cps1994_12s',
    199501: 'cps1995_01b',
    199502: 'cps1995_02s',
    199503: 'cps1995_03b',
    199504: 'cps1995_04s',
    199505: 'cps1995_05s',
    199506: 'cps1995_06s',
    199507: 'cps1995_07b',
    199508: 'cps1995_08s',
    199509: 'cps1995_09s',
    199510: 'cps1995_10s',
    199511: 'cps1995_11b',
    199512: 'cps1995_12b',
    199601: 'cps1996_01s',
    199602: 'cps1996_02s',
    199603: 'cps1996_03b',
    199604: 'cps1996_04b',
    199605: 'cps1996_05s',
    199606: 'cps1996_06b',
    199607: 'cps1996_07b',
    199608: 'cps1996_08b',
    199609: 'cps1996_09s',
    199610: 'cps1996_10s',
    199611: 'cps1996_11s',
    199612: 'cps1996_12b',
    199701: 'cps1997_01b',
    199702: 'cps1997_02s',
    199703: 'cps1997_03b',
    199704: 'cps1997_04s',
    199705: 'cps1997_05s',
    199706: 'cps1997_06b',
    199707: 'cps1997_07b',
    199708: 'cps1997_08b',
    199709: 'cps1997_09s',
    199710: 'cps1997_10s',
    199711: 'cps1997_11b',
    199712: 'cps1997_12b',
    199801: 'cps1998_01b',
    199802: 'cps1998_02s',
    199803: 'cps1998_03b',
    199804: 'cps1998_04b',
    199805: 'cps1998_05b',
    199806: 'cps1998_06s',
    199807: 'cps1998_07b',
    199808: 'cps1998_08s',
    199809: 'cps1998_09s',
    199810: 'cps1998_10s',
    199811: 'cps1998_11s',
    199812: 'cps1998_12s',
    199901: 'cps1999_01s',
    199902: 'cps1999_02s',
    199903: 'cps1999_03b',
    199904: 'cps1999_04s',
    199905: 'cps1999_05s',
    199906: 'cps1999_06b',
    199907: 'cps1999_07b',
    199908: 'cps1999_08b',
    199909: 'cps1999_09s',
    199910: 'cps1999_10s',
    199911: 'cps1999_11b',
    199912: 'cps1999_12b',
    200001: 'cps2000_01s',
    200002: 'cps2000_02s',
    200003: 'cps2000_03b',
    200004: 'cps2000_04b',
    200005: 'cps2000_05s',
    200006: 'cps2000_06s',
    200007: 'cps2000_07b',
    200008: 'cps2000_08s',
    200009: 'cps2000_09s',
    200010: 'cps2000_10s',
    200011: 'cps2000_11s',
    200012: 'cps2000_12b',
    200101: 'cps2001_01b',
    200102: 'cps2001_02s',
    200103: 'cps2001_03b',
    200104: 'cps2001_04s',
    200105: 'cps2001_05s',
    200106: 'cps2001_06s',
    200107: 'cps2001_07b',
    200108: 'cps2001_08s',
    200109: 'cps2001_09s',
    200110: 'cps2001_10s',
    200111: 'cps2001_11s',
    200112: 'cps2001_12s',
    200201: 'cps2002_01s',
    200202: 'cps2002_02s',
    200203: 'cps2002_03b',
    200204: 'cps2002_04b',
    200205: 'cps2002_05b',
    200206: 'cps2002_06s',
    200207: 'cps2002_07b',
    200208: 'cps2002_08s',
    200209: 'cps2002_09s',
    200210: 'cps2002_10s',
    200211: 'cps2002_11s',
    200212: 'cps2002_12s',
    200301: 'cps2003_01b',
    200302: 'cps2003_02s',
    200303: 'cps2003_03b',
    200304: 'cps2003_04b',
    200305: 'cps2003_05b',
    200306: 'cps2003_06s',
    200307: 'cps2003_07b',
    200308: 'cps2003_08s',
    200309: 'cps2003_09s',
    200310: 'cps2003_10s',
    200311: 'cps2003_11s',
    200312: 'cps2003_12s',
    200401: 'cps2004_01s',
    200402: 'cps2004_02b',
    200403: 'cps2004_03b',
    200404: 'cps2004_04b',
    200405: 'cps2004_05s',
    200406: 'cps2004_06s',
    200407: 'cps2004_07b',
    200408: 'cps2004_08b',
    200409: 'cps2004_09s',
    200410: 'cps2004_10s',
    200411: 'cps2004_11s',
    200412: 'cps2004_12s',
    200501: 'cps2005_01s',
    200502: 'cps2005_02s',
    200503: 'cps2005_03b',
    200504: 'cps2005_04b',
    200505: 'cps2005_05s',
    200506: 'cps2005_06b',
    200507: 'cps2005_07s',
    200508: 'cps2005_08s',
    200509: 'cps2005_09s',
    200510: 'cps2005_10s',
    200511: 'cps2005_11s',
    200512: 'cps2005_12s',
    200601: 'cps2006_01s',
    200602: 'cps2006_02b',
    200603: 'cps2006_03b',
    200604: 'cps2006_04b',
    200605: 'cps2006_05s',
    200606: 'cps2006_06s',
    200607: 'cps2006_07b',
    200608: 'cps2006_08s',
    200609: 'cps2006_09s',
    200610: 'cps2006_10s',
    200611: 'cps2006_11s',
    200612: 'cps2006_12s',
    200701: 'cps2007_01s',
    200702: 'cps2007_02b',
    200703: 'cps2007_03b',
    200704: 'cps2007_04b',
    200705: 'cps2007_05b',
    200706: 'cps2007_06b',
    200707: 'cps2007_07b',
    200708: 'cps2007_08s',
    200709: 'cps2007_09s',
    200710: 'cps2007_10s',
    200711: 'cps2007_11b',
    200712: 'cps2007_12s',
    200801: 'cps2008_01s',
    200802: 'cps2008_02b',
    200803: 'cps2008_03b',
    200804: 'cps2008_04b',
    200805: 'cps2008_05s',
    200806: 'cps2008_06s',
    200807: 'cps2008_07b',
    200808: 'cps2008_08s',
    200809: 'cps2008_09s',
    200810: 'cps2008_10s',
    200811: 'cps2008_11s',
    200812: 'cps2008_12s',
    200901: 'cps2009_01s',
    200902: 'cps2009_02b',
    200903: 'cps2009_03b',
    200904: 'cps2009_04b',
    200905: 'cps2009_05b',
    200906: 'cps2009_06b',
    200907: 'cps2009_07b',
    200908: 'cps2009_08s',
    200909: 'cps2009_09s',
    200910: 'cps2009_10s',
    200911: 'cps2009_11s',
    200912: 'cps2009_12s',
    201001: 'cps2010_01s',
    201002: 'cps2010_02b',
    201003: 'cps2010_03b',
    201004: 'cps2010_04b',
    201005: 'cps2010_05s',
    201006: 'cps2010_06s',
    201007: 'cps2010_07s',
    201008: 'cps2010_08s',
    201009: 'cps2010_09s',
    201010: 'cps2010_10s',
    201011: 'cps2010_11s',
    201012: 'cps2010_12s',
    201101: 'cps2011_01s',
    201102: 'cps2011_02b',
    201103: 'cps2011_03b',
    201104: 'cps2011_04b',
    201105: 'cps2011_05s',
    201106: 'cps2011_06s',
    201107: 'cps2011_07s',
    201108: 'cps2011_08s',
    201109: 'cps2011_09s',
    201110: 'cps2011_10s',
    201111: 'cps2011_11s',
    201112: 'cps2011_12s',
    201201: 'cps2012_01s',
    201202: 'cps2012_02b',
    201203: 'cps2012_03b',
    201204: 'cps2012_04b',
    201205: 'cps2012_05s',
    201206: 'cps2012_06s',
    201207: 'cps2012_07s',
    201208: 'cps2012_08s',
    201209: 'cps2012_09s',
    201210: 'cps2012_10s',
    201211: 'cps2012_11s',
    201212: 'cps2012_12s',
    201301: 'cps2013_01b',
    201302: 'cps2013_02s',
    201303: 'cps2013_03b',
    201304: 'cps2013_04b',
    201305: 'cps2013_05b',
    201306: 'cps2013_06s',
    201307: 'cps2013_07s',
    201308: 'cps2013_08s',
    201309: 'cps2013_09s',
    201310: 'cps2013_10s',
    201311: 'cps2013_11s',
    201312: 'cps2013_12s',
    201401: 'cps2014_01s',
    201402: 'cps2014_02s',
    201403: 'cps2014_03b',
    201404: 'cps2014_04b',
    201405: 'cps2014_05b',
    201406: 'cps2014_06s',
    201407: 'cps2014_07s',
    201408: 'cps2014_08s',
    201409: 'cps2014_09s',
    201410: 'cps2014_10s',
    201411: 'cps2014_11s',
    201412: 'cps2014_12s',
    201501: 'cps2015_01s',
    201502: 'cps2015_02s',
    201503: 'cps2015_03b',
    201504: 'cps2015_04b',
    201505: 'cps2015_05s',
    201506: 'cps2015_06s',
    201507: 'cps2015_07s',
    201508: 'cps2015_08s',
    201509: 'cps2015_09s',
    201510: 'cps2015_10s',
    201511: 'cps2015_11b',
    201512: 'cps2015_12s',
    201601: 'cps2016_01s',
    201602: 'cps2016_02s',
    201603: 'cps2016_03b',
    201604: 'cps2016_04b',
    201605: 'cps2016_05b',
    201606: 'cps2016_06s',
    201607: 'cps2016_07b',
    201608: 'cps2016_08s',
    201609: 'cps2016_09s',
    201610: 'cps2016_10s',
    201611: 'cps2016_11s',
    201612: 'cps2016_12s',
    201701: 'cps2017_01b',
    201702: 'cps2017_02s',
    201703: 'cps2017_03b',
    201704: 'cps2017_04b',
    201705: 'cps2017_05s',
    201706: 'cps2017_06s',
    201707: 'cps2017_07s',
    201708: 'cps2017_08s',
    201709: 'cps2017_09s',
    201710: 'cps2017_10s',
    201711: 'cps2017_11s',
    201712: 'cps2017_12s',
    201801: 'cps2018_01s',
    201802: 'cps2018_02s',
    201803: 'cps2018_03b',
    201804: 'cps2018_04b',
    201805: 'cps2018_05s',
    201806: 'cps2018_06s',
    201807: 'cps2018_07s',
    201808: 'cps2018_08s',
    201809: 'cps2018_09s',
    201810: 'cps2018_10s',
    201811: 'cps2018_11s',
    201812: 'cps2018_12s',
    201901: 'cps2019_01s',
    201902: 'cps2019_02s',
    201903: 'cps2019_03b',
    201904: 'cps2019_04b',
    201905: 'cps2019_05s',
    201906: 'cps2019_06s',
    201907: 'cps2019_07s',
    201908: 'cps2019_08s',
    201909: 'cps2019_09s',
    201910: 'cps2019_10s',
    201911: 'cps2019_11s',
    201912: 'cps2019_12s',
    202001: 'cps2020_01s',
    202002: 'cps2020_02s',
}

# State Mapping
states_dict = {
    1: 'al',
    2: 'ak',
    4: 'az',
    5: 'ar',
    6: 'ca',
    8: 'co',
    9: 'ct',
    10: 'de',
    11: 'dc',
    12: 'fl',
    13: 'ga',
    15: 'hi',
    16: 'id',
    17: 'il',
    18: 'in',
    19: 'ia',
    20: 'ks',
    21: 'ky',
    22: 'la',
    23: 'me',
    24: 'md',
    25: 'ma',
    26: 'mi',
    27: 'mn',
    28: 'ms',
    29: 'mo',
    30: 'mt',
    31: 'ne',
    32: 'nv',
    33: 'nh',
    34: 'nj',
    35: 'nm',
    36: 'ny',
    37: 'nc',
    38: 'nd',
    39: 'oh',
    40: 'ok',
    41: 'or',
    42: 'pa',
    44: 'ri',
    45: 'sc',
    46: 'sd',
    47: 'tn',
    48: 'tx',
    49: 'ut',
    50: 'vt',
    51: 'va',
    53: 'wa',
    54: 'wv',
    55: 'wi',
    56: 'wy',
}

# Month Mapping
months_dict = {
    1: 'jan',
    2: 'feb',
    3: 'mar',
    4: 'apr',
    5: 'may',
    6: 'jun',
    7: 'jul',
    8: 'aug',
    9: 'sep',
    10: 'oct',
    11: 'nov',
    12: 'dec',
}
#####


##### Extract CPS Sample Dataframe
def sample_cps_df(api_key: str, sample_ids: list, out_dir: str) -> pd.core.frame.DataFrame:
    extract = MicrodataExtract(collection = 'cps', variables = list(inp_vars.keys()), samples = sample_ids)
    ipums_client = IpumsApiClient(api_key)
    
    ipums_client.submit_extract(extract)
    ipums_client.wait_for_extract(extract)
    
    ext_dir = out_dir + '/CPS/ext/'
    ipums_client.download_extract(extract, download_dir = ext_dir)
    
    ext_id = str(extract.extract_id).zfill(5)
    xml_path = ext_dir + '/cps_' + ext_id + '.xml'
    dat_path = ext_dir + '/cps_' + ext_id + '.dat.gz'
    
    ddi = readers.read_ipums_ddi(xml_path)
    df = readers.read_microdata(ddi, dat_path)
    
    df.columns = [i.lower().strip() for i in df.columns]
    df = df[list(inp_vars.keys())].fillna(0)
    
    for i in inp_vars:
        df[i] = df[i].astype(inp_vars[i])
    
    return df
#####


##### Formatted CPS Sample Dataframe
def format_cps_df(df: pd.core.frame.DataFrame) -> pd.core.frame.DataFrame:
    df = df[(df['popstat'] == 1) & (df['age'] >= 16)] # civilian population
    
    df['empl_cat'] = np.where((df['empstat'] > 1) & (df['empstat'] < 20), 1, # 'e', employed
                     np.where((df['empstat'] >= 20) & (df['empstat'] < 30), 2, # 'u', unemployed
                     np.where((df['empstat'] >= 30), 3, 0))) # 'n', neither; 'o', other
    
    df['sex_cat'] = np.where((df['sex'] == 1), 1, # 'm', male
                    np.where((df['sex'] == 2), 2, 0)) # 'f', female; 'o', other
    
    df['age_cat'] = np.where((df['age'] >= 16) & (df['age'] < 25), 1, # '16-24'
                    np.where((df['age'] >= 25) & (df['age'] < 35), 2, # '25-34'
                    np.where((df['age'] >= 35) & (df['age'] < 45), 3, # '35-44'
                    np.where((df['age'] >= 45) & (df['age'] < 55), 4, # '45-54'
                    np.where((df['age'] >= 55) & (df['age'] < 65), 5, # '55-64'
                    np.where((df['age'] >= 65), 6, 0)))))) # '65+'; 'other'
    
    df['race_cat'] = np.where((df['race'] == 100) & (df['hispan'] == 0), 1, # 'w', white
                     np.where((df['race'] == 200) & (df['hispan'] == 0), 2, # 'b', Black
                     np.where((df['hispan'] > 0) & (df['hispan'] < 901), 3, 0))) # 'h', Hispanic; 'o', other
    
    df['educ_cat'] = np.where((df['educ'] > 1) & (df['educ'] < 73), 1, # 'l', low (less than HS)
                     np.where((df['educ'] == 73), 2, # 'm-l', medium-low (HS diploma)
                     np.where((df['educ'] > 73) & (df['educ'] < 111), 3, # 'm-h', medium-high (some college)
                     np.where((df['educ'] >= 111) & (df['educ'] < 999), 4, 0)))) # 'h', high (col and higher); 'o', other
    
    df = df[(df['empl_cat'] != 0) & (df['sex_cat'] != 0) & (df['age_cat'] != 0) & (df['race_cat'] != 0) & (df['educ_cat'] != 0)]
    
    df['occ_cat'] = np.where((df['occ1990'] > 0) & (df['occ1990'] < 203), 1, # MANAGERIAL AND PROFESSIONAL SPECIALTY
                    np.where((df['occ1990'] >= 203) & (df['occ1990'] < 405), 2, # TECHNICAL, SALES, AND ADMINISTRATIVE SUPPORT
                    np.where((df['occ1990'] >= 405) & (df['occ1990'] < 473), 3, # SERVICE
                    np.where((df['occ1990'] >= 473) & (df['occ1990'] < 503), 4, # FARMING, FORESTRY, AND FISHING
                    np.where((df['occ1990'] >= 503) & (df['occ1990'] < 703), 5, # PRECISION PRODUCTION, CRAFT, AND REPAIR
                    np.where((df['occ1990'] >= 703) & (df['occ1990'] < 905), 6, 0)))))) # OPERATORS, FABRICATORS, AND LABORERS; MISSING
    
    df['ind_cat'] = np.where((df['ind1990'] > 0) & (df['ind1990'] < 40), 1, # AGRICULTURE, FORESTRY, AND FISHERIES
                    np.where((df['ind1990'] >= 40) & (df['ind1990'] < 60), 2, # MINING
                    np.where((df['ind1990'] == 60), 3, # CONSTRUCTION
                    np.where((df['ind1990'] > 60) & (df['ind1990'] < 400), 4, # MANUFACTURING
                    np.where((df['ind1990'] >= 400) & (df['ind1990'] < 500), 5, # TRANSPORTATION, COMMUNICATIONS, AND OTHER PUBLIC UTILITIES
                    np.where((df['ind1990'] >= 500) & (df['ind1990'] < 580), 6, # WHOLESALE TRADE
                    np.where((df['ind1990'] >= 580) & (df['ind1990'] < 700), 7, # RETAIL TRADE
                    np.where((df['ind1990'] >= 700) & (df['ind1990'] < 721), 8, # FINANCE, INSURANCE, AND REAL ESTATE
                    np.where((df['ind1990'] >= 721) & (df['ind1990'] < 761), 9, # BUSINESS AND REPAIR SERVICES
                    np.where((df['ind1990'] >= 761) & (df['ind1990'] < 800), 10, # PERSONAL SERVICES
                    np.where((df['ind1990'] >= 800) & (df['ind1990'] < 812), 11, # ENTERTAINMENT AND RECREATION SERVICES
                    np.where((df['ind1990'] >= 812) & (df['ind1990'] < 900), 12, # PROFESSIONAL AND RELATED SERVICES
                    np.where((df['ind1990'] >= 900) & (df['ind1990'] < 940), 13, 0))))))))))))) # PUBLIC ADMINISTRATION; MISSING
    
    #df['employed'] = np.where(df['empl_cat'] == 1, 1, 0)
    df['unemployed'] = np.where(df['empl_cat'] == 2, 1, 0)
    
    #df['female'] = np.where(df['sex_cat'] == 2, 1, 0)
    df['nonwhite'] = np.where(df['race_cat'] != 1, 1, 0)
    
    #df['civilian'] = np.where(df['popstat'] == 1, 1, 0)
    #df['noncitizen'] = np.where(df['citizen'] == 5, 1, 0)
    
    df['married'] = np.where(df['marst'] == 1, 1, 0)
    df['veteran'] = np.where(df['vetstat'] == 2, 1, 0)
    df['urban'] = np.where(df['metro'] == 2, 1, 0)
    
    df['state'] = df['statefip'].map(states_dict)
    #df['month_lbl'] = df['month'].map(months_dict)
    
    df['yyyymm'] = 100 * df['year'].astype(np.int32) + df['month'].astype(np.int32)
    df['yyyymm_state'] = df['yyyymm'].astype(str) + '_' + df['state']
    
    df = df[list(out_vars.keys())]
    
    for i in out_vars:
        df[i] = df[i].astype(out_vars[i])
    
    return df
#####


##### Store All CPS Sample Data
def store_cps_data(api_key: str, out_dir: str, num_samples: int = 12):
    all_snaps = list(cps_sample_ids.keys())
    all_ids = list(cps_sample_ids.values())
    
    spl_dir = out_dir + '/CPS/spl/'
    fmt_dir = out_dir + '/CPS/fmt/'
    
    for i in range(0, len(cps_sample_ids), num_samples):
        sample_snaps = all_snaps[i:(i + num_samples)]
        sample_ids = all_ids[i:(i + num_samples)]
        
        sample_year = str(sample_snaps[0])[:4]
        sample_window = str(sample_snaps[0]) + '-' + str(sample_snaps[-1])
        print(sample_year, sample_window)
        
        spl_df = sample_cps_df(api_key, sample_ids, out_dir)
        fmt_df = format_cps_df(spl_df)
        
        spl_df.to_pickle(spl_dir + '/cps_spl_' + sample_year + '.pkl')
        fmt_df.to_pickle(fmt_dir + '/cps_fmt_' + sample_year + '.pkl')
        print(sample_ids)
#####


##### Final (Combined) CPS Dataframe
def final_cps_df(api_key: str, out_dir: str, num_samples: int = 12) -> pd.core.frame.DataFrame:
    fmt_dir = out_dir + '/CPS/fmt/'
    
    store_cps_data(api_key, out_dir, num_samples)
    
    cps_df = pd.concat(pd.read_pickle(fmt_dir + i) for i in os.listdir(fmt_dir) if '.pkl' in i)
    
    return cps_df
#####