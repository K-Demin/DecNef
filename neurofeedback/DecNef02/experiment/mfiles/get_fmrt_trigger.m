function get_fmrt_trigger()
% GetMRItrig: This program enables this computer to synchronize fMRI
% scanner. Follow instructions from MRI operators and make sure triggers
% are 't'. If not, change 'fmri_trigger_key' to something appropriate.

global gData

fmri_trigger_key = gData.define.key.FMRI_TRIGGER_KEY;
fprintf('Waiting for trigger from fMRI ... ')

switch gData.para.feedback.io_tool
  case gData.define.feedback.io_tool.PSYCHTOOLBOX
    % PsychtoolboxによるVisual feedback処理を行なう。
    Keys = KbName(fmri_trigger_key);	 % Getting a keycode
    FlushEvents('keyDown');
    while true
      [KeyIsDown, Secs, Response] = KbCheck;
      if KeyIsDown
	if sum(Response(Keys))
	  break;
	end
      end
    end
    
  case gData.define.feedback.io_tool.MATLAB
    % MATLABによるVisual feedback処理を行なう。
    while true
      figure(gData.data.feedback.window_id);
      drawnow
	
      if strcmp( get(gData.data.feedback.window_id,...
	    'currentcharacter'), fmri_trigger_key )
	break;
      end
    end
    
  case gData.define.feedback.io_tool.DO_NOT_USE
    ;
    
end	

fprintf('OK!\n')
