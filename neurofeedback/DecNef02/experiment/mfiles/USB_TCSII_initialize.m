function TCS=USB_TCSII_initialize(COMport,neutral_temperature, surface_area,temperature_slope,stimulus_duration,trigger_code)
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
st=['N' sprintf('%03d',neutral_temperature)];
disp(st);
for i=1:length(st)
    fwrite(TCS,st(i),'uchar');
end


st='O';
for i=1:length(st);
    fwrite(TCS,st(i),'uchar');
    WaitSecs(0.001);
end;

%surface area
st=['S' surface_area];
for i=1:length(st);
    fwrite(TCS,st(i),'uchar');
    WaitSecs(0.001);
end;
disp(st);

%temperature slope
st=['V0' temperature_slope];
for i=1:length(st);
    fwrite(TCS,st(i),'uchar');
    WaitSecs(0.001);
end;
disp(st);

%return slope
st=['R0' temperature_slope];
for i=1:length(st);
    fwrite(TCS,st(i),'uchar');
    WaitSecs(0.001);
end;
disp(st);

%stimulus duration
st=['D0' stimulus_duration];
for i=1:length(st);
    fwrite(TCS,st(i),'uchar');
    WaitSecs(0.001);
end;
disp(st);

%trigger
st=['T' trigger_code];
for i=1:length(st);
    fwrite(TCS,st(i),'uchar');
    WaitSecs(0.001);
end;
disp(st);


%Y
st=['Y1100'];
for i=1:length(st);
    fwrite(TCS,st(i),'uchar');
    WaitSecs(0.001);
end;
disp(st);


% disp('Disabling the temperature feedback at 1 Hz.');
% st='F';
% for i=1:length(st)
%     fwrite(TCS,st(i),'uchar');
% end
disp('Ready.');



end

