% 计算LLE的局部重建权值矩阵
% 基于https://github.com/ArrowLuo/LLE_Algorithm修改
function [W,neighborhood] = LLEWeight(X,K)
    % X = data as D x N matrix (D = dimensionality, N = #points)
    % K = number of neighbors
    % W = weight matrix, K x N matrix
    
    [D,N] = size(X);
%     fprintf(1,'LLE running on %d points in %d dimensions\n',N,D);
    
    
    % STEP1: COMPUTE PAIRWISE DISTANCES & FIND NEIGHBORS 
%     fprintf(1,'-->Finding %d nearest neighbours.\n',K);
    
    X2 = sum(X.^2,1);
    distance = repmat(X2,N,1)+repmat(X2',1,N)-2*X'*X;
    
    [sorted,index] = sort(distance);
    neighborhood = index(2:(1+K),:);
    
    
    
    % STEP2: SOLVE FOR RECONSTRUCTION WEIGHTS
%     fprintf(1,'-->Solving for reconstruction weights.\n');
    
    if(K>D) 
%       fprintf(1,'   [note: K>D; regularization will be used]\n'); 
      tol=1e-3; % regularlizer in case constrained fits are ill conditioned
    else
      tol=0;
    end
    
    W = zeros(K,N);
    for ii=1:N
       z = X(:,neighborhood(:,ii))-repmat(X(:,ii),1,K); % shift ith pt to origin
       C = z'*z;                                        % local covariance
       C = C + eye(K,K)*tol*trace(C);                   % regularlization (K>D)
       W(:,ii) = C\ones(K,1);                           % solve Cw=1
       W(:,ii) = W(:,ii)/sum(W(:,ii));                  % enforce sum(w)=1
    end

end