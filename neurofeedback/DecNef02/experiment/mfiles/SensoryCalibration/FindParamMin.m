function [xParMin, SSEMin, BICMin, Bomin] = FindParamMin(xPar,SSE,Bo, n)


% Find the 4 parameters associated with lowest SSE.

% SSe:
%minimizing the sum of the squared error between the observed 
%trial-by-trial temperature-adjusted pain ratings and those predicted by
%the model

% input: xPar is vector of free parameters, SSE is vector of SSE
% Pick Min for output
nMin=sum(SSE==min(SSE));
if nMin == 1
    xParMin=xPar(SSE==min(SSE),:);
    SSEMin=SSE(SSE==min(SSE));
    Bomin = Bo(SSE==min(SSE));
elseif nMin > 1 %Pick the first if there are multiple local min of the same value
    minSSE=find(SSE==min(SSE));
    xParMin=xPar(minSSE(1),:);
    SSEMin=SSE(minSSE(1));
    Bomin = Bo(minSSE(1));
end
BICMin = n*log(SSEMin) - n*log(n) + log(n)*size(xPar,2);
