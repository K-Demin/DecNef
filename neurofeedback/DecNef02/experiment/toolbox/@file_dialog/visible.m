function [current_dir, current_file] = visible(this)
% file_dialog$B%/%i%9$N(BGUI$B=hM}%a%=%C%I(B

% GUI$B$r9=C[$9$k!#(B
this.private.gui_handles = create_gui(this);

% Dialog window$B$N(B'UserData' property$B$K(Bfile_dialog$B9=B$BN$r%;%C%H$9$k!#(B
UserData = struct('public', this.public, 'private', this.private);
% drive_info$B9=B$BN$r99?7$9$k!#(B(Windows$B4D6-$N$_M-8z(B)
UserData = set_drive_info(UserData);
% current_terminal_dir$B$r99?7$9$k!#(B
% (current_$B8!:w(Bdirectory$BL>$N:G2<AX$N(Bdirectory$BL>$r@_Dj$9$k!#(B)
UserData = set_current_terminal_dir(UserData);
set(this.private.gui_handles.dialog, 'UserData', UserData, 'Visible', 'on');
% Dialog window$B$N(BGUI$B$N(Bproperty$BCM$r99?7$9$k!#(B
set_gui_property(this.private.gui_handles.dialog);

% Dialog window$B$,HsI=<(2=$5$l$k$^$G(Bwait$B$9$k!#(B
waitfor(this.private.gui_handles.dialog, 'Visible', 'off')

% ($B$3$3$G$9$0$K=hM}$rLa$9$H!"4D6-$K$h$C$F$OD>8e$N(BGUI$BA`:n$K(B
% $BIT6q9g$r$-$?$9>l9g$,$"$k$N$G(B)$BG0$N$?$a(B...$B$b$&>/$7BT$D(B
pause(0.5);

if length( find(get(0, 'children') == this.private.gui_handles.dialog) )
  % current$B8!:w(Bdirectory, current$B8!:w(Bfile$B$r5a$a$k!#(B
  this = get(this.private.gui_handles.dialog, 'UserData');
  current_dir = this.public.current_dir;
  current_file = this.private.current_file;
  delete(this.private.gui_handles.dialog);
else
  current_dir = [];
  current_file = {};
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function visible()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
