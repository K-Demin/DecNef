% set baseline temperature in °C ( also called "neutral temperature )
function TcsSetBaseLineTemp( ser,  baselineTemp )

temp = baselineTemp;
if temp > 40 temp = 40; end
if temp < 20 temp = 20; end   
command = sprintf( 'N%03d', temp*10 );
TcsWriteString( ser, command );

