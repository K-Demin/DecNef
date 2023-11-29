% tcs example:
% set stimulation
% start stimulation
% get temperatures during stimulation
% display stimulation

%clean up workspace ...
clear all

%open com
tcs = TcsOpenCom( 'COM5' );

%set TCS in "quiet mode"
%otherwise TCS sends regularly temperature data
%( @1Hz if no stimulation, @100Hz during stimulation )
TcsQuietMode( tcs );

%set parameters
TcsSetBaseLine( tcs, 40.0 ); %set baseline 31°C
TcsSetDurations( tcs, [ 3.0, 3.0, 3.0, 3.0, 3.0 ] ); %set durations for 5 zones
%TcsSetRampSpeed( tcs, [ 75.0, 75.0, 75.0, 75.0, 75.0 ] ); %set ramp speed for 5 zones
%TcsSetReturnSpeed( tcs, [ 75.0, 75.0, 75.0, 75.0, 75.0 ] ); %set return speed for 5 zones
TcsSetTemperatures( tcs, [ 45.0, 45.0, 45.0, 45.0, 45.0 ] ); %set target temperatures for 5 zones



%send stimulation
TcsStimulate( tcs );

%loop to record stimulation temperatures
recordDuration = 6;
tic; %set start time
currentTime = toc; %get current time
cpt = 0;
while currentTime < recordDuration
    cpt = cpt + 1;
    currentTemperatures = TcsGetTemperatures( tcs ); %array of 5 temperatures ( = 5 zones )
    disp( currentTemperatures ); %disp current temp
    y_temperatures( cpt, 1:5 ) = currentTemperatures; %record temperatures in y_temperatures
    currentTime = toc; %get current time
    x_time( cpt, 1 ) = currentTime; %record time in x_temperatures
end    
    
%display 5x temp curves vs time
plot( x_time, y_temperatures(:,1) ); %plot temperature zone 1
hold on;
plot( x_time, y_temperatures(:,2) ); %plot temperature zone 2
plot( x_time, y_temperatures(:,3) ); %plot temperature zone 3
plot( x_time, y_temperatures(:,4) ); %plot temperature zone 4
plot( x_time, y_temperatures(:,5) ); %plot temperature zone 5
grid on; zoom on;
hold off;

%close com
TcsCloseCom( tcs );
