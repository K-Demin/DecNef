function [] = visual_feedback(status)

global gData

% Initialize the visual display if asked for.
if status == gData.define.feedback.INITIALIZE
  if 0
    fprintf(...
	'\nŽ‹Šofeedback?ˆ—?‚ðŠJŽn‚µ‚Ü‚·?B (''%s'')\n',...
	get_field_name(gData.para.feedback.io_tool,...
	gData.define.feedback.io_tool));
    if gData.para.feedback.io_tool ==...
	  gData.define.feedback.io_tool.PSYCHTOOLBOX |...
	  gData.para.feedback.io_tool ==...
	  gData.define.feedback.io_tool.MATLAB
      fprintf('[‚±‚ê‚æ‚è?æ?AŽÀŒ±’†‚ÍPC‚Ì‘€?ì‚Í?s‚È‚í‚È‚¢‚Å‰º‚³‚¢?B]\n')
    end
  else
    fprintf(...
	'\nThe visual display is ready to start. (''%s'')\n',...
	get_field_name(gData.para.feedback.io_tool,...
	gData.define.feedback.io_tool));
  end
  R = input('Plaese hit the Enter key when you are ready. : ', 's');
  fprintf('\n');
end


% This is the crux of that function: send the status to the disual_feedback
% function.
switch gData.para.feedback.io_tool
  case gData.define.feedback.io_tool.PSYCHTOOLBOX
      
    visual_feedback_ptb(status);
    
  case gData.define.feedback.io_tool.MATLAB

    visual_feedback_mat(status);
end

