%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script will record the timing of the image transmission
% by the scanner. This is to measure if there is a delay.
% Wait for the trigger from the scanner ('t' key)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global gData
bloc = '12';
TR = 0.867;

fmri_trigger_key = 't';
fprintf('Waiting for trigger from fMRI ... ')

Keys = KbName(fmri_trigger_key);	 % Getting a keycode
FlushEvents('keyDown');
while true
  [KeyIsDown, Secs, Response] = KbCheck;
  if KeyIsDown
    if sum(Response(Keys))
        start = GetSecs;
       break;
    end
  end
end

go = 1;
scan = 1;
time_file = [];
while go
    
    if scan < 10
        dicom_file_name = ['Y:\realtime\20201214.Phantom.Phantom\001_0000',bloc,'_00000',num2str(scan),'.dcm'];
    elseif scan < 100
        dicom_file_name = ['Y:\realtime\20201214.Phantom.Phantom\001_0000',bloc,'_0000',num2str(scan),'.dcm'];
    elseif scan < 1000
        dicom_file_name = ['Y:\realtime\20201214.Phantom.Phantom\001_0000',bloc,'_000',num2str(scan),'.dcm'];
    end
    
    % DICOM file
    if exist(dicom_file_name, 'file')
        time_file(end+1) = GetSecs - start;
        scan = scan+1;
        if scan == 300
            go = 0;
        end
    end
end

opt_time = TR:TR:(299*TR);

figure(1)
plot(time_file - opt_time)

mean_delay = mean((time_file - opt_time));


