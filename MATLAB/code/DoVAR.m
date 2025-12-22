%%%%% Set up VAR

% retrieve sample start time
VAR.start = VAR.tsFreq*(VAR.startDate(1) - Data.Set(1,1)) + VAR.startDate(2);
% retrieve sample end time
VAR.end = VAR.tsFreq*(VAR.endDate(1) - Data.Set(1,1)) + VAR.endDate(2);

% retrieve IV start time
VAR.ivStart = VAR.tsFreq*(VAR.ivStartDate(1) - Data.Set(1,1)) + VAR.ivStartDate(2);
% retrieve IV end time
VAR.ivEnd = VAR.tsFreq*(VAR.ivEndDate(1) - Data.Set(1,1)) + VAR.ivEndDate(2);

% retrieve adjusted IV start time
VAR.ivStartAdj = max(VAR.ivStart,(VAR.start + VAR.lagLength));
% retrieve adjusted IV end time
VAR.ivEndAdj = min(VAR.ivEnd,VAR.end);

% retrieve difference in start time between sample and IV
VAR.ivStartDiff = VAR.ivStartAdj - VAR.start - VAR.lagLength + 1;
% retrieve difference in end time between sample and IV
VAR.ivEndDiff = VAR.ivEndAdj - VAR.start - VAR.lagLength + 1;

% retrieve specified IV
VAR.ivTerm = Data.Set(VAR.ivStartAdj:VAR.ivEndAdj,cell2mat(values(Data.Map,VAR.ivVar)));

% construct VAR constant term
VAR.consTerm = ones((VAR.end - VAR.start - VAR.lagLength + 1),1);
% construct IV regs constant term
VAR.adjConsTerm = VAR.consTerm(VAR.ivStartDiff:VAR.ivEndDiff);

% retrieve number of specified CI levels
VAR.numCILvls = numel(VAR.ciLvl);

% retrieve data of all estimated gaps
if VAR.singleVAR == false
    VAR.gapsData = Data.Set(VAR.start:VAR.end,cell2mat(values(Data.Map,VAR.laborVars2)));
end

% iterate through one or multiple VARs as specified
for i = 1:VAR.iterate
    % construct laborVars if running multiple VARs
    if VAR.singleVAR == false
        % map respective laborVar1 and laborVar2
        VAR.laborVars = [VAR.laborVars1(i),VAR.laborVars2(i)];
    end
    
    % construct set of variables
    VAR.vars = [VAR.monpolVar,VAR.macroVars,VAR.laborVars];
    % retrieve specified sample dataset
    VAR.data = Data.Set(VAR.start:VAR.end,cell2mat(values(Data.Map,VAR.vars)));
    % retrieve number of specified vars
    VAR.numVars = numel(VAR.vars);
    
    % execute CholVAR & IRFs
    if VAR.doCholVAR == true
        DoCholVAR;
    end
    % execute SVAR-IV & IRFs
    DoSVARIV;
    % execute WIVR CIs
    DoWIVRCI;
    
    % retrieve only laborVar2 IRFs from multiple VARs
    if VAR.singleVAR == false
        % capture laborVar2 estimates based on each set of CholVAR IRFs
        if VAR.doCholVAR == true
            VAR.cholLaborVar2IRFs(:,i) = CholVAR.IRFs(:,find(VAR.cholOrder == 7));
        end
        
        % capture laborVar2 estimates and CIs based on each set of SVAR-IV IRFs
        VAR.ivLaborVar2IRFs(:,i) = SVARIV.IRFs(:,7);
        VAR.ivLaborVar2IRFsL(:,:,i) = SVARIV.IRFsL(:,:,7);
        VAR.ivLaborVar2IRFsH(:,:,i) = SVARIV.IRFsH(:,:,7);
        
        % capture reduced-form VAR adjusted R2 for laborVar2
        VAR.rfAdjR2LaborVar2(i) = SVARIV.rfAdjR2(7);
        % capture first-stage IV reg F-stat
        VAR.fsFstat(i) = SVARIV.fsFstat;
        % capture first-stage IV reg het-rob F-stat
        VAR.fsHetRobFstat(i) = SVARIV.fsHetRobFstat;
    end
end