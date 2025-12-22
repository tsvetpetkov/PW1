%%%%% Set up outcome and explanatory variables

% construct reduced-form VAR Y values based on specified # of lags
SVARIV.rfY = VAR.data((VAR.lagLength + 1):end,:);

% construct reduced-form VAR X values based on specified # of vars and # of lags
for ik = 1:VAR.lagLength
    % in blocks of (# of vars), add the k-th lag of Y
    SVARIV.lagData(:,((ik - 1)*VAR.numVars + 1):(ik*VAR.numVars)) = VAR.data((VAR.lagLength - ik + 1):(end - ik),:);
end

% add constant term
SVARIV.rfX = [SVARIV.lagData VAR.consTerm];

% construct first-stage IV reg X values
SVARIV.fsX = [VAR.ivTerm VAR.adjConsTerm];


%%%%% Estimate SVAR-IV

% retrieve reduced-form VAR beta coefficients
SVARIV.rfBetas = SVARIV.rfX\SVARIV.rfY;
% retrieve reduced-form VAR residuals
SVARIV.rfResiduals = SVARIV.rfY - SVARIV.rfX*SVARIV.rfBetas;

% retrieve first-stage IV reg beta coefficients
SVARIV.fsBetas = SVARIV.fsX\SVARIV.rfResiduals(VAR.ivStartDiff:VAR.ivEndDiff,1);
% retrieve first-stage IV reg residuals
SVARIV.fsResiduals = SVARIV.rfResiduals(VAR.ivStartDiff:VAR.ivEndDiff,1) - SVARIV.fsX*SVARIV.fsBetas;

% construct second-stage IV reg X values
SVARIV.ssX = [SVARIV.fsX*SVARIV.fsBetas VAR.adjConsTerm];
% retrieve second-stage IV reg beta coefficients
SVARIV.ssBetas = SVARIV.ssX\SVARIV.rfResiduals(VAR.ivStartDiff:VAR.ivEndDiff,:);

% retrieve contemporaneous impact values
SVARIV.shockVals = SVARIV.ssBetas(1,:)';


%%%%% Estimate reduced-form VAR adjusted R2

% retrieve demeaned sample data
SVARIV.rfResidualsCons = detrend(SVARIV.rfY,'constant');

% retrieve demeaned adjusted reduced-form residuals
SVARIV.fsResidualsCons = detrend(SVARIV.rfResiduals(VAR.ivStartDiff:VAR.ivEndDiff,1),'constant');

% retrieve reduced-form # of obs and # of expl. vars
[SVARIV.rfT,SVARIV.rfN] = size(SVARIV.rfX);
% retrieve first-stage # of obs and # of expl. vars
[SVARIV.fsT,SVARIV.fsN] = size(SVARIV.fsX);

% retrieve the reduced-form VAR R2 for each variable
for in = 1:VAR.numVars
    % retrieve n-th variable MSE
    SVARIV.rfMSE(in) = (SVARIV.rfResiduals(:,in)'*SVARIV.rfResiduals(:,in))/(SVARIV.rfT - SVARIV.rfN);
    % retrieve n-th variable reduced MSE
    SVARIV.rfMSEcons(in) = (SVARIV.rfResidualsCons(:,in)'*SVARIV.rfResidualsCons(:,in))/(SVARIV.rfT - 1);
    
    % estimate n-th variable adjusted R2
    SVARIV.rfAdjR2(in) = round((1 - SVARIV.rfMSE(in)/SVARIV.rfMSEcons(in)),4);
end


%%%%% Estimate first-stage IV reg F-stat

% retrieve first-stage IV reg SSE
SVARIV.fsSSE = SVARIV.fsResiduals'*SVARIV.fsResiduals;
% retrieve reduced first-stage IV reg SSE
SVARIV.fsSSEcons = SVARIV.fsResidualsCons'*SVARIV.fsResidualsCons;

% estimate first-stage IV reg F-stat
SVARIV.fsFstat = round(((SVARIV.fsSSEcons - SVARIV.fsSSE)/(SVARIV.fsN - 1))/(SVARIV.fsSSE/(SVARIV.fsT - SVARIV.fsN)),2);

% estimate first-stage IV reg het-rob F-stat
SVARIV.fsSS = zeros(SVARIV.fsN,SVARIV.fsN);
for it = 1:SVARIV.fsT
    SVARIV.fsSS = SVARIV.fsSS + 1/SVARIV.fsT*SVARIV.fsX(it,:)'*SVARIV.fsX(it,:)*SVARIV.fsResiduals(it)^2;
end
SVARIV.fsBB = inv(1/SVARIV.fsT*SVARIV.fsX'*SVARIV.fsX)*SVARIV.fsSS*inv(1/SVARIV.fsT*SVARIV.fsX'*SVARIV.fsX);
SVARIV.fsRR = [eye(SVARIV.fsN - 1) zeros((SVARIV.fsN - 1))];
SVARIV.fsWW = SVARIV.fsT*(SVARIV.fsRR*SVARIV.fsBetas)'*inv(SVARIV.fsRR*SVARIV.fsBB*SVARIV.fsRR')*(SVARIV.fsRR*SVARIV.fsBetas);
SVARIV.fsHetRobFstat = round(SVARIV.fsWW/(SVARIV.fsN - 1),2);


%%%%% Create SVAR-IV IRFs

SVARIV.irf(VAR.lagLength + 1,:) = SVARIV.shockVals*(VAR.shockSize/SVARIV.shockVals(1));
for ih = 2:VAR.irfHorizon
    SVARIV.irfHelper = (SVARIV.irf((VAR.lagLength + ih - 1):-1:ih,:))';
    SVARIV.irf(VAR.lagLength + ih,:) = SVARIV.irfHelper(:)'*SVARIV.rfBetas(1:(VAR.lagLength*VAR.numVars),:);
end
SVARIV.IRFs = SVARIV.irf(VAR.lagLength + 1:end,:);