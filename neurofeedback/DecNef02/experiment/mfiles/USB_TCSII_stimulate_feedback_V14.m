function temp = USB_TCSII_stimulate_feedback(TCS,target_temperature)
%surface_area: '00000' to '11111' (active zone=1, inactive zone=0)
%target_temperature : '050' to '600' (5 to 60°C)
%temperature_slope : '0001' to '9999' (0.1 to 999.9°C/s)
%stimulus_duration : '0010' to '9999' (10 to 9999 ms)
%trigger_code : '001' to '255' (1 to 255)
%Author: D. Mulders & A. Mouraux

%clean
% st=['W000'];
% for i=1:length(st)
%     fwrite(TCS,st(i),'char');
%     WaitSecs(0.001);
%     flushoutput( TCS ); %flush output characters
% end
% disp(st);

%target temperature
st=['C0' target_temperature];
for i=1:length(st)
    fwrite(TCS,st(i),'char');
    WaitSecs(0.001);
    flushoutput( TCS ); %flush output characters
end
disp(st);

%launch stimulation
flushoutput(TCS);
flushinput(TCS);
st='L';
for i=1:length(st)
    fwrite(TCS,st(i),'char');
    %toc
    WaitSecs(0.001);
    flushoutput( TCS ); %flush output characters
end
disp(st);


% a={};
% [ab,~,~]=fscanf(TCS);
% a{1} = ab;
% for i=1:60
%     [ab,~,~]=fscanf(TCS);
%     a{end+1}=ab;
% end
% temp=a';

temp = 0;


end

