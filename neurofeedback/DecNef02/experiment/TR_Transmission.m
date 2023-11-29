function TR_Transmission()

% This function emulate the transfert of the TRs by the scanner
% It will copy the TRs in a target directory (target_dir)
bloc = 6;

homeDir = pwd;

source_dir = 'Y:\realtime\From_the_Scanner';
target_dir = 'Y:\realtime\realtime_tranfert_test\';

% TR is the desired repetition time
TR = 0.867;

% There is a delay in the transmission of the images to the MR-RT computer.
% the mean delay is 0.5. Use thiss delay to emulate real-time processing.
delay = 0.5;

cd(source_dir)
if bloc <10
    file_list = dir(['001_00000',num2str(bloc),'*.dcm']);
else
    file_list = dir(['001_0000',num2str(bloc),'*.dcm']);
end
    
start = GetSecs;
live_flag = 1;
scan = 1;
% run this until the live_flag turns off.
while live_flag
  
    time = GetSecs - start;
  
    % LocalTime is the time elapsed since the last scan. 
    RestTime = scan*TR - time;
    
    if RestTime <= 0.0	
        pause(delay)
        % Copy the corresponding TR
        copyfile([source_dir,'\',file_list(scan).name],target_dir)
        disp(['Copying TR number: ', num2str(scan), ' Time:', num2str(time), ' ...'])
        % Update the TR number (here scan)
        if scan <length(file_list)
            scan = scan+1;
        else
            break
        end
    end
end

disp(['Transfert completed ...'])
cd(homeDir)

