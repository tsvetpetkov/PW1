%%%%% Specify IV-stage Model Specs
n = VAR.numVars;
m = 1;
k = SVARIV.fsN - 1;
p = VAR.lagLength;
h = VAR.irfHorizon;
scale = VAR.shockSize;

t = SVARIV.fsT;
Z = VAR.ivTerm;
eta = SVARIV.rfResiduals(VAR.ivStartDiff:VAR.ivEndDiff,:)';
X = [VAR.adjConsTerm SVARIV.lagData(VAR.ivStartDiff:VAR.ivEndDiff,:)];
AL = SVARIV.rfBetas(1:(VAR.lagLength*VAR.numVars),:)';


%%%%% Remaining Weak-IV-Robust CI Estimation Code is Courtesy of Montiel Olea, Stock, and Watson (2021)

Gamma = eta*Z./t;
nwlags = floor(4*(((t-p)/100)^(2/9)));

matagg = [X,eta',Z]'; %The columns of this vector are (W_t;X_t; eta_t;Z_t)
T1aux = size(eta,2); %This is the number of time periods
T2aux = size(matagg,1); %This is the column dimension of (W_t;X_t;eta_t;Z_t)
etaaux = reshape(eta,[n,1,T1aux]); %Each 2-D page contains eta_t
mataggaux = permute(reshape(matagg,[T2aux,1,T1aux]),[2,1,3]); %Each 2-D page contains (W_t',X_t',\eta_t',Z_t')
auxeta = bsxfun(@plus,bsxfun(@times,etaaux,mataggaux),-mean(bsxfun(@times,etaaux,mataggaux),3));
vecAss1 = reshape(auxeta,[(n*m) + (p*(n^2)) + n^2 + (n*k),1,T1aux]); %Each 2-D page contains [eta_t W_t', eta_t X_t', eta_t eta_t'-Sigma, eta_tZ_t'-Gamma]

%Each 2-D page contains [vec(eta_tW_t'); vec(eta_tX_t') ; vec(eta_t*eta_t'-Sigma) ; vec(eta_tZ_t'-Gamma)]
%Auxiliary matrix to compute the HAC covariance matrix
AuxHAC1 = vecAss1(1:end,:,:);
AuxHAC2 = reshape(AuxHAC1,[size(vecAss1,1),size(vecAss1,3)])';
Sigma0 = (1/(size(AuxHAC2,1)))*(AuxHAC2'*AuxHAC2);
Sigma_cov = @(k) (1/(size(AuxHAC2,1)))*(AuxHAC2(1:end-k,:))'*(AuxHAC2(1+k:end,:));
AuxHAC3 = Sigma0;
for s_sig=1:nwlags
    AuxHAC3 = AuxHAC3 + (1 - s_sig/(nwlags + 1))*(Sigma_cov(s_sig) + Sigma_cov(s_sig)');
end
WhatAss1 = AuxHAC3;

%% Construct the selector matrix Vaux that gives: vech(Sigma)=Vaux*vec(Sigma)
I = eye(n);
V = kron(I(1,:),I);
for i_vars = 2:n
    V = [V; kron(I(i_vars,:),I(i_vars:end,:))];
end
%% This is the estimator of What based on Montiel-Olea, Stock, and Watson
Q1 = (X'*X./T1aux);
Q2 = Z'*X/T1aux;
Shat = [kron([zeros(n*p,m),eye(n*p)]/Q1,eye(n)), zeros((n^2)*p,n^2 + (k*n)); ...
    zeros(n*(n + 1)/2,((n^2)*p) + n*m), V, zeros(n*(n + 1)/2,k*n);...
    -kron(Q2/Q1,eye(n)), zeros(k*n,n^2),eye(k*n)];
WHataux = (Shat)*(WhatAss1)*(Shat');
%WHataux is the covariance matrix of vec(A),vech(Sigma),Gamma
WHat = [WHataux(1:(n^2)*p,1:(n^2)*p),...
    WHataux(1:(n^2)*p,((n^2)*p)+(n*(n+1)/2)+1:end);...
    WHataux(1:(n^2)*p,((n^2)*p)+(n*(n+1)/2)+1:end)',...
    WHataux(((n^2)*p)+(n*(n+1)/2)+1:end,((n^2)*p)+(n*(n+1)/2)+1:end)];

%% Reshape AL into a 3-D array
vecAL = reshape(AL,[n,n,p]);
%% Initialize the value of the auxiliary array vecALrevT
vecALrevT = zeros(n,n,h);
for i_al = 1:h
    if i_al<(h-p)+1
        vecALrevT(:,:,i_al) = zeros(n,n);
    else
        vecALrevT(:,:,i_al) = vecAL(:,:,(h - i_al) + 1)';
    end
end
vecALrevT = reshape(vecALrevT,[n,n*h]);
%% MA coefficients
C = repmat(vecAL(:,:,1),[1,h]);
for i_c = 1:(h-1)
    C(:,(n*i_c) + 1:(n*(i_c + 1))) = [eye(n),C(:,1:n*i_c)]*vecALrevT(:,(h*n - (n*(i_c + 1))) + 1:end)';
end
Caux = [eye(n),C(:,1:(end - n))];
C = reshape(Caux,[n,n,h]);

%% A and J matrices in Lutkepohl's formula for the derivative of C with respect to A
J = [eye(n), zeros(n,(p - 1)*n)];
Alut = [AL; eye(n*(p - 1)),zeros(n*(p - 1),n)];
%% AJ is a 3D array that contains A^(k-1) J' in the kth 2D page of the the 3D array
AJ = zeros(n*p,n,h);
for k_aj = 1:h
    AJ(:,:,k_aj) = ((Alut)^(k_aj - 1))*J';
end
%% matrix [ JA'^0; JA'^1; ... J'A^{k-1} ];
JAp = reshape(AJ, [n*p,n*h])';
%% G matrices
AJaux = zeros(size(JAp,1)*n,size(JAp,2)*n,h);
Caux = reshape([eye(n),C(:,1:(h - 1)*n)],[n,n,h]);
for i_aj = 1:h
    AJaux(((n^2)*(i_aj-1))+1:end,:,i_aj) = kron(JAp(1:n*(h+1-i_aj),:), Caux(:,:,i_aj));
end
Gaux = permute(reshape(sum(AJaux,3)',[(n^2)*p,n^2,h]),[2,1,3]);
G = zeros(size(Gaux,1),size(Gaux,2),size(Gaux,3)+1);
G(:,:,2:end) = Gaux;

%% Label the submatrices of the asy var of (vecA,Gamma)
W1 = WHat(1:(n^2)*p,1:(n^2)*p);
W12 = WHat(1:(n^2)*p,1 + (n^2)*p:end);
W2 = WHat(1 + (n^2)*p:end,1 + (n^2)*p:end);

%% 4) Definitions to apply the formulae in MSW for noncumulative IRFs
%a) Definitions to compute the MSW confidence interval for $\lambda_{k,i}$
for wci = 1:VAR.numCILvls
    critval=(-sqrt(2)*erfcinv(2*(1-((1-VAR.ciLvl(wci)/100)/2))))^2;
    
    e         = eye(n);
    ahat      = zeros(n,h);
    bhat      = zeros(n,h);
    chat      = zeros(n,h);
    Deltahat  = zeros(n,h);
    MSWlbound = zeros(n,h);
    MSWubound = zeros(n,h);
    casedummy = zeros(n,h);
    
    lambdahat=zeros(n,h);
    DmethodVar=zeros(n,h);
    Dmethodlbound=zeros(n,h);
    Dmethodubound=zeros(n,h);
    
    for i_dh=1:h
        for ivar=1:n
            lambdahat(ivar,i_dh)=scale*e(:,ivar)'*C(:,:,i_dh)*Gamma./Gamma(1,1);
            d1=(kron(Gamma',e(:,ivar)')*scale*G(:,:,i_dh));
            d2=(scale*e(:,ivar)'*C(:,:,i_dh))-(lambdahat(ivar,i_dh)*e(:,1)');
            d=[d1,d2]';
            DmethodVar(ivar,i_dh)=d'*WHat*d;
            Dmethodlbound(ivar,i_dh)= lambdahat(ivar,i_dh)-...
                ((critval./t)^.5)*(DmethodVar(ivar,i_dh)^.5)/abs(Gamma(1,1));
            Dmethodubound(ivar,i_dh)= lambdahat(ivar,i_dh)+...
                ((critval./t)^.5)*(DmethodVar(ivar,i_dh)^.5)/abs(Gamma(1,1));
        end
    end
    
    for j_n = 1:n
        for i_h = 1:h
            ahat(j_n,i_h)     = (t*(Gamma(1,1)^2))-(critval*W2(1,1));
            bhat(j_n,i_h)     = -2*t*scale*(e(:,j_n)'*C(:,:,i_h)*Gamma)*Gamma(1,1)...
                + 2*critval*scale*(kron(Gamma',e(:,j_n)'))*G(:,:,i_h)*W12(:,1)...
                + 2*critval*scale*e(:,j_n)'*C(:,:,i_h)*W2(:,1);
            chat(j_n,i_h)     = ((t^.5)*scale*e(:,j_n)'*C(:,:,i_h)*Gamma).^2 ...
                -critval*(scale^2)*(kron(Gamma',e(:,j_n)'))*G(:,:,i_h)*W1*...
                ((kron(Gamma',e(:,j_n)'))*G(:,:,i_h))' ...
                -2*critval*(scale^2)*(kron(Gamma',e(:,j_n)'))*G(:,:,i_h)*W12*C(:,:,i_h)'*e(:,j_n)...
                -critval*(scale^2)*e(:,j_n)'*C(:,:,i_h)*W2*C(:,:,i_h)'*e(:,j_n);
            Deltahat(j_n,i_h) = bhat(j_n,i_h).^2-(4*ahat(j_n,i_h)*chat(j_n,i_h));
            
            if ahat(j_n,i_h)>0 && Deltahat(j_n,i_h)>0
                casedummy(j_n,i_h) = 1;
                MSWlbound(j_n,i_h) = (-bhat(j_n,i_h) - (Deltahat(j_n,i_h)^.5))/(2*ahat(j_n,i_h));
                MSWubound(j_n,i_h) = (-bhat(j_n,i_h) + (Deltahat(j_n,i_h)^.5))/(2*ahat(j_n,i_h));
            elseif ahat(j_n,i_h)<0 && Deltahat(j_n,i_h)>0
                casedummy(j_n,i_h) = 2;
                MSWlbound(j_n,i_h) = (-bhat(j_n,i_h) + (Deltahat(j_n,i_h)^.5))/(2*ahat(j_n,i_h));
                MSWubound(j_n,i_h) = (-bhat(j_n,i_h) - (Deltahat(j_n,i_h)^.5))/(2*ahat(j_n,i_h));
            elseif ahat(j_n,i_h)>0 && Deltahat(j_n,i_h)<0
                casedummy(j_n,i_h) = 3;
                MSWlbound(j_n,i_h) = NaN;
                MSWubound(j_n,i_h) = NaN;
            else
                casedummy(j_n,i_h) = 4;
                MSWlbound(j_n,i_h) = -inf;
                MSWubound(j_n,i_h) = inf;
            end
        end
    end
    MSWlbound(1,1)=scale;
    MSWubound(1,1)=scale;
    
    lB = MSWlbound';
    uB = MSWubound';
    
    %lB = Dmethodlbound';
    %uB = Dmethodubound';
    
    SVARIV.IRFsL(:,wci,:) = lB;
    SVARIV.IRFsH(:,wci,:) = uB;
end