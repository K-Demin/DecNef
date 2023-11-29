%[calib_output] = pain_calib(subdir); 
%[calib_output] = pain_calib(subdir,F, remove_last_temp);

%[calib_output] = pain_calib_correction(subdir,F, remove_last_temp);
[calib_output] = pain_calib_correction_TV(subdir,F, remove_last_temp);

outputdir = [subdir  '/calibration_html_output'];
cd(outputdir); save('calib_output', 'calib_output'); % Save calib output html. VT: I suppose no need to specify the file format.

