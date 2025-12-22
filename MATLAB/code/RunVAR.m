%%%%% Restart program

close all;
clear;
clc;


%%%%% Load time-series data

% specify file names
Data.MacroFileName = "macro_data";
Data.LaborGapsFileName = "labor_gaps_data";

% import .csv files stored in the data folder and trim its labels
Data.MacroSet = csvread('../data/' + Data.MacroFileName + '.csv',1,2);
Data.LaborGapsSet = csvread('../data/' + Data.LaborGapsFileName + '.csv',1,4);

% group macro and labor sets
Data.Set = [Data.MacroSet Data.LaborGapsSet];

% specify the label of each data col
Data.Labels = {'Y','M','GDP','IP','CPI','UR','EPR','GS1','GS2','CRB','EBP','WXR','MPI_JK','MPI_JK_PM','MPI_MAR','MPS_BS','MPSO_BS',...
               'URG_BW','URG_BW_M','URG_BW_F','URG_BW_M_A1','URG_BW_M_A2','URG_BW_M_A3','URG_BW_M_A4','URG_BW_F_A1','URG_BW_F_A2','URG_BW_F_A3','URG_BW_F_A4','URG_BW_M_A2_E1','URG_BW_M_A2_E2','URG_BW_M_A2_E3','URG_BW_M_A2_E4','URG_BW_M_A3_E1','URG_BW_M_A3_E2','URG_BW_M_A3_E3','URG_BW_M_A3_E4','URG_BW_F_A2_E1','URG_BW_F_A2_E2','URG_BW_F_A2_E3','URG_BW_F_A2_E4','URG_BW_F_A3_E1','URG_BW_F_A3_E2','URG_BW_F_A3_E3','URG_BW_F_A3_E4',...
               'URG_HW','URG_HW_M','URG_HW_F','URG_HW_M_A1','URG_HW_M_A2','URG_HW_M_A3','URG_HW_M_A4','URG_HW_F_A1','URG_HW_F_A2','URG_HW_F_A3','URG_HW_F_A4','URG_HW_M_A2_E1','URG_HW_M_A2_E2','URG_HW_M_A2_E3','URG_HW_M_A2_E4','URG_HW_M_A3_E1','URG_HW_M_A3_E2','URG_HW_M_A3_E3','URG_HW_M_A3_E4','URG_HW_F_A2_E1','URG_HW_F_A2_E2','URG_HW_F_A2_E3','URG_HW_F_A2_E4','URG_HW_F_A3_E1','URG_HW_F_A3_E2','URG_HW_F_A3_E3','URG_HW_F_A3_E4',...
               'EPRG_BW','EPRG_BW_M','EPRG_BW_F','EPRG_BW_M_A1','EPRG_BW_M_A2','EPRG_BW_M_A3','EPRG_BW_M_A4','EPRG_BW_F_A1','EPRG_BW_F_A2','EPRG_BW_F_A3','EPRG_BW_F_A4','EPRG_BW_M_A2_E1','EPRG_BW_M_A2_E2','EPRG_BW_M_A2_E3','EPRG_BW_M_A2_E4','EPRG_BW_M_A3_E1','EPRG_BW_M_A3_E2','EPRG_BW_M_A3_E3','EPRG_BW_M_A3_E4','EPRG_BW_F_A2_E1','EPRG_BW_F_A2_E2','EPRG_BW_F_A2_E3','EPRG_BW_F_A2_E4','EPRG_BW_F_A3_E1','EPRG_BW_F_A3_E2','EPRG_BW_F_A3_E3','EPRG_BW_F_A3_E4',...
               'EPRG_HW','EPRG_HW_M','EPRG_HW_F','EPRG_HW_M_A1','EPRG_HW_M_A2','EPRG_HW_M_A3','EPRG_HW_M_A4','EPRG_HW_F_A1','EPRG_HW_F_A2','EPRG_HW_F_A3','EPRG_HW_F_A4','EPRG_HW_M_A2_E1','EPRG_HW_M_A2_E2','EPRG_HW_M_A2_E3','EPRG_HW_M_A2_E4','EPRG_HW_M_A3_E1','EPRG_HW_M_A3_E2','EPRG_HW_M_A3_E3','EPRG_HW_M_A3_E4','EPRG_HW_F_A2_E1','EPRG_HW_F_A2_E2','EPRG_HW_F_A2_E3','EPRG_HW_F_A2_E4','EPRG_HW_F_A3_E1','EPRG_HW_F_A3_E2','EPRG_HW_F_A3_E3','EPRG_HW_F_A3_E4'};

% specify the value order of each data col
Data.Values = 1:length(Data.Labels);

% map labels and values
Data.Map = containers.Map(Data.Labels,Data.Values);


%%%%% Specify VAR

VAR.monpolVar = {'WXR'}; % possible: 'WXR','GS1','GS2'
VAR.monpolVarLbl = {'Wu-Xia Rate (% pts)'};

VAR.macroVars = {'GDP','CPI','CRB','EBP'};
VAR.macroVarsLbls = {'Real GDP (%)','Consumer Prices (%)','Commodity Prices (%)','Excess Bond Premium (% pts)'};

VAR.ivVar = {'MPI_JK'}; % possible: 'MPI_JK','MPI_JK_PM','MPI_MAR','MPS_BS','MPSO_BS'

VAR.tsFreq = 12;
VAR.lagLength = 12;
VAR.shockSize = 0.25;
VAR.ciLvl = [90 68];
VAR.irfHorizon = 61;

VAR.startDate = [1992 1];
VAR.endDate = [2020 2];

VAR.ivStartDate = [1992 1];
VAR.ivEndDate = [2016 12];

VAR.singleVAR = true;
VAR.doCholVAR = false;
VAR.groupType = 'base'; % possible: 'base', 'age', 'educ'

VAR.laborType = 'UR'; % possible: 'UR', 'EPR'
VAR.gapType = 'BW'; % possible: 'BW', 'HW'
VAR.ageType = 'A2'; % possible: 'A2', 'A3'

if strcmp(VAR.gapType, 'BW')
    VAR.gapTypeLbl = 'Black-white';
else
    VAR.gapTypeLbl = 'Hispanic-white';
end


%%%%% VAR Setup

if VAR.singleVAR == true
    VAR.laborVars = {VAR.laborType};
    VAR.laborVarsLbls = {'Unemployment Rate (% pts)'};
    
    VAR.cholOrder = [1, 2, 3, 4, 5, 6];
    
    VAR.varsLbls = [VAR.monpolVarLbl,VAR.macroVarsLbls,VAR.laborVarsLbls];
    
    VAR.iterate = 1;
else
    if strcmp(VAR.groupType, 'base')
        VAR.laborVars1 = {VAR.laborType,VAR.laborType,VAR.laborType,VAR.laborType,VAR.laborType,VAR.laborType};
        VAR.varsLbls1 = {['Black-white ' VAR.laborType ' gap (% pts)'],['Hispanic-white ' VAR.laborType ' gap (% pts)'],'','','',''};
        
        VAR.laborVars2 = {[VAR.laborType 'G_BW'],[VAR.laborType 'G_HW'],[VAR.laborType 'G_BW_M'],[VAR.laborType 'G_HW_M'],[VAR.laborType 'G_BW_F'],[VAR.laborType 'G_HW_F']};
        VAR.varsLbls2 = {'aggregate','','male','','female',''};
    else
        VAR.laborVars1 = {VAR.laborType,VAR.laborType,VAR.laborType,VAR.laborType,VAR.laborType,VAR.laborType,VAR.laborType,VAR.laborType};
        VAR.varsLbls1 = {[VAR.gapTypeLbl ' male ' VAR.laborType ' gap (% pts)'],[VAR.gapTypeLbl ' female ' VAR.laborType ' gap (% pts)'],'','','','','',''};
        
        if strcmp(VAR.groupType, 'age')
            VAR.laborVars2 = {[VAR.laborType 'G_' VAR.gapType '_M_A1'],[VAR.laborType 'G_' VAR.gapType '_F_A1'],[VAR.laborType 'G_' VAR.gapType '_M_A2'],[VAR.laborType 'G_' VAR.gapType '_F_A2'],[VAR.laborType 'G_' VAR.gapType '_M_A3'],[VAR.laborType 'G_' VAR.gapType '_F_A3'],[VAR.laborType 'G_' VAR.gapType '_M_A4'],[VAR.laborType 'G_' VAR.gapType '_F_A4']};
            VAR.varsLbls2 = {'16-24','','25-44','','45-64','','65+',''};
        else
            VAR.laborVars2 = {[VAR.laborType 'G_' VAR.gapType '_M_' VAR.ageType '_E1'],[VAR.laborType 'G_' VAR.gapType '_F_' VAR.ageType '_E1'],[VAR.laborType 'G_' VAR.gapType '_M_' VAR.ageType '_E2'],[VAR.laborType 'G_' VAR.gapType '_F_' VAR.ageType '_E2'],[VAR.laborType 'G_' VAR.gapType '_M_' VAR.ageType '_E3'],[VAR.laborType 'G_' VAR.gapType '_F_' VAR.ageType '_E3'],[VAR.laborType 'G_' VAR.gapType '_M_' VAR.ageType '_E4'],[VAR.laborType 'G_' VAR.gapType '_F_' VAR.ageType '_E4']};
            VAR.varsLbls2 = {'less than HS','','HS diploma','','some college','','col and higher',''};
        end
    end
    
    VAR.cholOrder = [1, 2, 3, 4, 5, 6, 7];
    
    VAR.iterate = numel(VAR.laborVars2);
end


%%%%% Execute VAR and plot IRFs

DoVAR;
PlotIRFs;