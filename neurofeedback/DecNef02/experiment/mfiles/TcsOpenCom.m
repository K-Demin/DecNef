% open serial com with TCS
function TCS = TcsOpenCom( COMport )

%close all opened instruments !!!
if isempty(instrfind)
else
    fclose(instrfind);
end

%try to open COMport
disp('Initializing the TCS device');
TCS = serial( COMport, 'BaudRate', 115200, 'Timeout', 1 ); %, 'BytesAvailableFcnMode', 'byte');
%set( TCS, 'Timu
fopen( TCS );
