%%%%% Set up VAR outcome and explanatory variables

% construct Y values based on specified # of lags and Chol order
CholVAR.Y = VAR.data((VAR.lagLength + 1):end,VAR.cholOrder);

% construct X values based on specified # of vars and # of lags in Chol order
for ck = 1:VAR.lagLength
    % in blocks of (# of vars), add the k-th lag of Y
    CholVAR.lagData(:,((ck - 1)*VAR.numVars + 1):(ck*VAR.numVars)) = VAR.data((VAR.lagLength - ck + 1):(end - ck),VAR.cholOrder);
end

% add constant term
CholVAR.X = [CholVAR.lagData VAR.consTerm];


%%%%% Estimate Cholesky VAR

% retrieve reduced-form VAR beta coefficients
CholVAR.betas = CholVAR.X\CholVAR.Y;
% retrieve reduced-form VAR residuals
CholVAR.residuals = CholVAR.Y - CholVAR.X*CholVAR.betas;

% retrieve VCV matrix of reduced-form residuals
CholVAR.residualsVCV = CholVAR.residuals'*CholVAR.residuals;

% retrieve Chol lower-triangular matrix form of the VCV matrix
CholVAR.VCVlower = chol(CholVAR.residualsVCV,'lower');

% retrieve contemporaneous impact values
CholVAR.shockVals = CholVAR.VCVlower(:,find(VAR.cholOrder == 1));


%%%%% Create Cholesky IRFs

CholVAR.irfBuilder(VAR.lagLength + 1,:) = CholVAR.shockVals*(VAR.shockSize/CholVAR.shockVals(find(VAR.cholOrder == 1)));
for ch = 2:VAR.irfHorizon
    CholVAR.irfHelper = (CholVAR.irfBuilder((VAR.lagLength + ch - 1):-1:ch,:))';
    CholVAR.irfBuilder(VAR.lagLength + ch,:) = CholVAR.irfHelper(:)'*CholVAR.betas(1:(VAR.lagLength*VAR.numVars),:);
end
CholVAR.IRFs = CholVAR.irfBuilder(VAR.lagLength + 1:end,:);