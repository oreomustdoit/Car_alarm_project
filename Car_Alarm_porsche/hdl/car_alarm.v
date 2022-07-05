module car_alarm
(clk,rst,
driver_door_switch,
passenger_door_switch,
ignition_switch,
hidden_switch,
brake_pedal_switch,
clk_onehz,
led,
siren,
fuel_pump_power);

input clk,rst;
input driver_door_switch;//driver door open=1 close=0
input passenger_door_switch;//passenger door open=1 close=0
input ignition_switch;//ignition=1 off=0
input hidden_switch;
input brake_pedal_switch;

output clk_onehz;
output siren;//the siren
output led;
output fuel_pump_power;

fiftymhz_to_onehz clock_freq_reducer(clk,rst,clk_onehz);
car_alarm_fsm
(
clk_onehz,rst,
driver_door_switch,
passenger_door_switch,
ignition_switch,
hidden_switch,
brake_pedal_switch,
system_arm,
siren,
led,
fuel_pump_power
);

endmodule