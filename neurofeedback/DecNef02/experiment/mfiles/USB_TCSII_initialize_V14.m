function TCS=USB_TCSII_initialize_V14(COMport,neutral_temperature, surface_area,temperature_slope,stimulus_duration,trigger_code)
%COMport : string (e.g. 'COM3')
%neutral_temperature ' : 15°C to 40°C
%Author: D. Mulders & A. Mouraux
if isempty(instrfind)
else
    fclose(instrfind);
end

disp('Initializing the TCS device. This may take a few seconds.');
TCS=serial(COMport,'BaudRate',115200);
fopen(TCS);
disp('Done.');

disp('Setting neutral temperature.');
st=['N' neutral_temperature];
for i=1:length(st)
    fwrite(TCS,st(i),'char');
    WaitSecs(0.001);
    flushoutput( TCS ); %flush output characters
end
disp(st);

%stimulus duration
st=['D0' stimulus_duration];
for i=1:length(st)
    fwrite(TCS,st(i),'char');
    WaitSecs(0.001);
    flushoutput( TCS ); %flush output characters
end
disp(st);

%temperature slope
st=['V0' temperature_slope];
for i=1:length(st)
    fwrite(TCS,st(i),'char');
    WaitSecs(0.001);
    flushoutput( TCS ); %flush output characters
end
disp(st);

%return slope
st=['R0' temperature_slope];
for i=1:length(st)
    fwrite(TCS,st(i),'char');
    WaitSecs(0.001);
    flushoutput( TCS ); %flush output characters
end
disp(st);


disp('Ready.');


end

