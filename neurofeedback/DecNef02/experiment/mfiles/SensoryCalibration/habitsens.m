function [target, pred, Cs, Phcom] = habitsens(xpar, site, temp, RespRes, reset, NewRun, offset)

global PainRes
global Cs
global Phcom
global target
global pred


%site = site on each trial
%temp = temp on each trial
%RespRes = response on each trial, corrected for current temp
%reset = indicator of first trial for each subject (for fitting multiple subjects)
%NewRun = indicator first trial after a break (gets additional decay)
%offset = intercept for temp-dependence of update rules; 0 for no temp dependence


mC = xpar(1); %magnitude for site-nonspecific adaptation (pos = sens, neg = hab)
mP = xpar(2); %magnitude for site-specific adaptation (pos = sens, neg = hab)
dC = xpar(3); %site-nonspecific decay rate
dP = xpar(4); %site-specific decay rate

n = length(temp); % number of trials
k = max(site); % number of sites (assuming site contains positive integers)

PainRes = zeros(n,1); % Predicted temp-corrected pain on each trial

if offset==0 %no temp dependence
    increment = ones(1,n);
else
    increment = temp - offset;
end

Cs = zeros(1,n); 
Ph = zeros(k,n);

for t=1:n %loop trials
    
    if reset(t)==1 %starting a new subject; set all habituation/sensitization levels to 0
        Cs(1,t) = 0; %site-nonspecific state level
        Ph(1:k,t) = zeros(k,1); %state level on each site
    end
    
    PainRes(t) = Cs(t) + Ph(site(t),t); %predicted pain residual level on this trial
    
    
    % Update site-nonspecific level: increment based on current temp, then decay
    % decay 10x in between runs (CHANGE IF NEEDED!), 1x between trials within runs
    if NewRun(t) ==1 %last trial of run
        Cs(1,t+1) = dC*dC*dC*dC*dC*dC*dC*dC*dC*dC*(Cs(1,t) + mC*increment(t));
    else
        Cs(1,t+1) = dC * (Cs(1,t) + mC*increment(t));
    end
    
    % Update current site's level:
    Ph(1:k,t+1)= Ph(1:k,t);
    Ph(site(t),t+1) = Ph(site(t),t) + mP*increment(t);
    if NewRun(t) ==1
        Ph(1:k,t+1) = dP*dP*dP*dP*dP*dP*dP*dP*dP*dP* Ph(1:k,t+1);
    end
    if NewRun(t) ==0
        Ph(1:k,t+1) = dP* Ph(1:k,t+1);
    end
    
end

for i = 1:n
    Phcom(i) = Ph(site(i),i);
end


PainRes = PainRes-mean(PainRes)+mean(RespRes); %directly compute optimal intercept term

target = mean(reshape(RespRes,n,length(RespRes)/n),2); %mean RespRes by trial number
pred = mean(reshape(PainRes,n,length(RespRes)/n),2); %mean PainRes by trial number



