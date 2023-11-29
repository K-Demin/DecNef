% send a string to TCS
% ensure 1ms delay between each char and flushes output
function TcsWriteString( ser, str )

for i = 1:length( str )
    pause( 0.001 ); %1ms between each caracters send
    fwrite( ser ,str(i),'char'); %send char
    flushoutput( ser ); %flush output characters
end %endfor
