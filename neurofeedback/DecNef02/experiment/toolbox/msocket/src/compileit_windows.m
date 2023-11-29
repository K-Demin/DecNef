% Note: this only works in windows
% Run mex -setup first, and select the C compiler to
% be the Microsoft compiler
% DKA added C++ routine here just in case
mex -setup C++
% This needs to be changed to the approproate directory
libdir = ...
  "C:\Program Files\MATLAB\R2023a\sys\lcc64\lcc64\lib64\ws2_32.lib";

files = {'msconnect.c',...
  'msaccept.c',...
  'mslisten.c',...
  'msclose.c',...
  'mssendraw.c',...
  'msrecvraw.c'};

% Create libraries for above files
% Sorry, deleted old cmd from herem should've commented
for i1=1:length(files)
  cmd=sprintf('mex %s "%s"',...
    files{i1}, libdir);
  cmd
  eval(cmd);
end

% Compile object code
%Change to DWIN32 if you compile for 32
mex -I. -DWIN64 -c matvar.cpp
mex -I. -DWIN64 -c msrecv.cpp
mex -I. -DWIN64 -c mssend.cpp


%Change to DWIN32 if you compile for 32
mex msrecv.obj matvar.obj -DWIN64 "-L'C:\Program Files\MATLAB\R2023a\sys\lcc64\lcc64\lib64\'" ...
-lws2_32.lib -LC:\ProgramData\MATLAB\SupportPackages\R2023a\3P.instrset\mingw_w64.instrset\lib\gcc\x86_64-w64-mingw32\6.3.0 ...
-lstdc++
% OLD CODE
% cmd = sprintf('mex -I. -DWIN32 msrecv.obj matvar.obj ws2_32.lib -L"%s"',libdir);
%cmd
%eval(cmd);

%Change to DWIN32 if you compile for 32

% OLD CODE
mex mssend.obj matvar.obj -DWIN64 "-L'C:\Program Files\MATLAB\R2023a\sys\lcc64\lcc64\lib64\'" ...
-lws2_32.lib -LC:\ProgramData\MATLAB\SupportPackages\R2023a\3P.instrset\mingw_w64.instrset\lib\gcc\x86_64-w64-mingw32\6.3.0 ...
-lstdc++
%cmd = sprintf('mex -I. -DWIN32 mssend.obj matvar.obj ws2_32.lib -L"%s"',libdir);
%cmd
%eval(cmd);

system('del *.obj');
% system('move *.mexw32 ..');

system('move *.mexw64 ..');
