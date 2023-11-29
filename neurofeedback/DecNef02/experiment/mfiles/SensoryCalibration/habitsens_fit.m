function [SSE, target, pred, Bo ]=habitsens_fit(xpar, site, temp, RespRes, reset, decay, offset, fig)

global PainRes

%site = site on each trial 
%temp = temp on each trial
%RespRes = response on each trial, corrected for current temp
%reset = indicator of first trial for each subject (for fitting multiple subjects) 
%decay = 1 for decaying all sites every trial, 0 for decaying only stimuluated site 
%offset = intercept for temp-dependence of update rules; 0 for no temp dependence 
%fig = 1 to draw figure, 0 not to

mC = xpar(1); %magnitude for central adaptation (pos = sens, neg = hab)
mP = xpar(2); %magnitude for peripheral adaptation (pos = sens, neg = hab)
dC = xpar(3); %central decay rate
dP = xpar(4); %peripheral decay rate

n = length(temp); %number of trials
k = max(site); %number of sites (assuming site contains positive integers)
PainRes = zeros(n,1); %Predicted temp-corrected pain on each trial

if offset==0 %no temp dependence
    increment = ones(1,n);
else
    increment = temp - offset;
end

for t=1:n %loop trials
    if reset(t)==1 %starting a new subject; set all habituation/sensitization levels to 0
        C = 0; %central-state level
        P = zeros(k,1); %peripheral-state level on each site
    end
    PainRes(t) = C + P(site(t)); %predicted pain residual level on this trial
    C = dC * (C + mC*increment(t)); %update central level: increment based on current temp, then decay
    P(site(t)) = P(site(t)) + mP*increment(t); %increment peripheral level of current site
    if decay==1
        P = dP*P; %decay peripheral levels on all sites
    else
        P(site(t)) = dP*P(site(t)); %only decay current site
    end
end


% MJ: comment out to see what happens without intercept:
PainRes = PainRes-mean(PainRes)+mean(RespRes); %directly compute optimal intercept term

%MJ added: compute intercept value, is output B0 
Bo = mean(RespRes)-mean(PainRes);

SSE = (PainRes-RespRes)'*(PainRes-RespRes); %calculate squared error across all trials

if fig==1 %make a figure
    target = mean(reshape(RespRes,24,length(RespRes)/24),2); %mean RespRes by trial number
    pred = mean(reshape(PainRes,24,length(RespRes)/24),2); %mean PainRes by trial number
    R2 = 1 - sum((target-pred).^2)/(var(target)*23); %R-squared
    SSEnew = (pred-target)'*(pred-target); %calculate squared error across all trials
    
    figure(1),clf,hold on
    plot(target,'k*')
    plot(pred,'b*')
    for b=1:3
        trials = b*8+(-7:0);
        plot(trials,target(trials),'k')
        plot(trials,pred(trials),'b')
    end
    paramText = ['C mag = ' num2str(mC) ', P mag = ' num2str(mP) ', C decay = ' num2str(dC) ', P decay = ' num2str(dP)];
    if decay==1
        modelName = 'With Decay';
    else
        modelName = 'No Decay';
    end
    if offset==0
        modelName = [modelName ', No Temp Dependence'];
    else
        modelName = [modelName ', Temp Dependence with neutral point = ' num2str(offset)];
    end
    title([modelName '\newline{' paramText '}\newline{Black = Data, Blue = Model}\newline{R-squared = ' num2str(R2) '}\newline{SSEnew = ' num2str(SSEnew) '}'])
    xlabel('Trial Number')
    ylabel('Residual Pain Report')
end

