neutral_temperature = 300; %'150' to '400' (Unit = 0.1°C)
surface_area = '11111'; %'00000' to '11111' (active zone=1, inactive zone=0)
target_temperature = '450'; %'050' to '600' (5 to 60°C)
temperature_slope = '1000'; %'0001' to '9999' (0.1 to 999.9°C/s)
stimulus_duration = '01000'; %'0010' to '9999' (10 to 9999 ms)
trigger_code = '010'; %'001' to '255' (1 to 255)

TCS=USB_TCSII_initialize('/dev/cu.usbmodem1411',neutral_temperature,surface_area,temperature_slope,stimulus_duration,trigger_code);
%tic
stimOne = USB_TCSII_stimulate_feedback(TCS,target_temperature);

WaitSecs(2)

target_temperature = '480'; 

stimTwo = USB_TCSII_stimulate_feedback(TCS,target_temperature);
