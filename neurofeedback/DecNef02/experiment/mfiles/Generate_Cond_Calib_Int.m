function Generate_Cond_Calib_Int(log,task,participant)

%%%%
% This will generate the condition files for Calibrate Intensity procedure
% They need to contain :
% names
% durations
% onsets
% pmod
%
% -VTD-

names= {'Stim','Pain','PainInt', 'PainUnp','NoPain','Heat'};
onsets = {};
durations = {};

pmod = struct('name',{''},'param',{},'poly',{});
pmod(1).name{1} = 'Intensity';
pmod(1).poly{1} = 1;
pmod(3).name{1} = 'PainIntensity';
pmod(3).poly{1} = 1;
pmod(4).name{1} = 'PainUnpleasantness';
pmod(4).poly{1} = 1;
pmod(6).name{1} = 'HeatIntensity';
pmod(6).poly{1} = 1;

% Start with intensity
FirstTrial = find(contains(log,'Calibration trial: 1-'));
stim = find(contains(log,'Stimulation '));

% remove the practice trials
stim = stim(find(stim>FirstTrial));
TimeStim = [];
Intensity = [];
for i = 1:length(stim)
    posCol = findstr(log{stim(i)},':');
    TimeStim(i) = str2double(log{stim(i)}(posCol+1:end));
    posPara = findstr(log{stim(i)},'(');
    Intensity(i) = str2double(log{stim(i)}(posPara+1:posPara+3));
end

onsets{1} = TimeStim;
durations{1} = 2*ones(1,length(TimeStim));
pmod(1).param{1} = Intensity;

% Find Pain responses
pain = find(contains(log,'Answer: Pain'));
pain = pain(find(pain>FirstTrial));

TimePain = [];
for i = 1:length(pain)
    posCol = findstr(log{pain(i)},':');
    TimePain(i) = str2double(log{pain(i)}(posCol(end)+1:end));
end
onsets{2} = TimePain;
durations{2} = zeros(1,length(TimePain));

if ~isempty(TimePain)
    % Find PainInt responses
    TimePainInt = [];
    painInt = [];
    for i = 1:length(pain)
        % Findtherating immediately after the pain rating
        posCol = findstr(log{pain(i)+1},':');
        posSpace = findstr(log{pain(i)+1},' ');
        TimePainInt(i) = str2double(log{pain(i)+1}(posSpace(end)+1:end));
        painInt(i) = str2double(log{pain(i)+1}(posSpace(1)+1:posSpace(2)-1));
    end
    onsets{3} = TimePainInt;
    durations{3} = zeros(1,length(TimePainInt));

    pmod(3).param{1} = painInt;

    % Find PainUnp responses
    TimePainUnp = [];
    painUnp = [];
    for i = 1:length(pain)
        % Findtherating immediately after the pain rating
        posCol = findstr(log{pain(i)+2},':');
        posSpace = findstr(log{pain(i)+2},' ');
        TimePainUnp(i) = str2double(log{pain(i)+2}(posSpace(end)+1:end));
        painUnp(i) = str2double(log{pain(i)+2}(posSpace(1)+1:posSpace(2)-1));
    end

    onsets{4} = TimePainUnp;
    durations{4} = zeros(1,length(TimePainUnp));

    pmod(4).param{1} = painUnp;
end

% Find NoPain responses
noPain = find(contains(log,'Answer: No Pain'));
noPain = noPain(find(noPain>FirstTrial));

TimeNoPain = [];
for i = 1:length(noPain)
    posCol = findstr(log{noPain(i)},':');
    TimeNoPain(i) = str2double(log{noPain(i)}(posCol(end)+1:end));
end
onsets{5} = TimeNoPain;
durations{5} = zeros(1,length(TimeNoPain));

% Find Heat responses
TimeHeat = [];
RateHeat = [];
for i = 1:length(noPain)
    % Findtherating immediately after the pain rating
    posSpace = findstr(log{noPain(i)+1},' ');
    TimeHeat(i) = str2double(log{noPain(i)+1}(posSpace(end)+1:end));
    RateHeat(i) = str2double(log{noPain(i)+1}(posSpace(1)+1:posSpace(2)-1));
end

onsets{6} = TimeHeat;
durations{6} = zeros(1,length(TimeHeat));

pmod(6).param{1} = RateHeat;

save(['condition_',task,'_',participant,'.mat'],'onsets','durations','names','pmod');


