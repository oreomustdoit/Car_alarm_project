module testbench;

reg clk=0,rst=0;
reg driver_door_switch=0;
reg passenger_door_switch=0;
reg ignition_switch=0;
reg hidden_switch=0;
reg brake_pedal_switch=0;

always #10 clk=!clk;

wire system_arm;
wire siren;
wire led;
wire fuel_pump_power;


reg driver_door_switchNBA,passenger_door_switchNBA,ignition_switchNBA,hidden_switchNBA,brake_pedal_switchNBA;

always @* driver_door_switchNBA<=driver_door_switch;
always @* passenger_door_switchNBA<=passenger_door_switch;
always @* ignition_switchNBA<=ignition_switch;
always @* hidden_switchNBA<=hidden_switch;
always @* brake_pedal_switchNBA<=brake_pedal_switch;
car_alarm_fsm DUT
(
clk,rst,
driver_door_switchNBA,
passenger_door_switchNBA,
ignition_switchNBA,
hidden_switchNBA,
brake_pedal_switchNBA,
system_arm,
siren,
led,
fuel_pump_power
);

task do_rst;
begin
#0.5;rst=1;#0.2;rst=0;
end
endtask

task turn_on_ignition;
begin
ignition_switch=1;
end
endtask

task turn_off_ignition;
begin
ignition_switch=0;
end
endtask

task open_driver_door;
begin
driver_door_switch=1;
end
endtask

task open_passenger_door;
begin
passenger_door_switch=1;
end
endtask

task close_driver_door;
begin
driver_door_switch=0;
end
endtask

task close_passenger_door;
begin
passenger_door_switch=0;
end
endtask

task press_hidden_switch;
begin
hidden_switch=1;
end
endtask

task release_hidden_switch;
begin
hidden_switch=0;
end
endtask

task press_brake_pedal;
begin
brake_pedal_switch=1;
end
endtask

task release_brake_pedal;
begin
brake_pedal_switch=0;
end
endtask


initial
begin
do_rst;	
@(posedge clk);
turn_on_ignition;
@(posedge clk);
turn_off_ignition;
@(posedge clk);

open_driver_door;

open_passenger_door;
@(posedge clk);
close_passenger_door;

close_driver_door;
@(posedge clk);
@(posedge clk);
@(posedge clk);
open_driver_door;
@(posedge clk);
close_driver_door;
@(posedge clk);
@(posedge clk);
@(posedge clk);

@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
@(posedge clk);
open_driver_door;
repeat(7) @(posedge clk);
close_driver_door;
@(posedge clk);
@(posedge clk);
open_passenger_door;
@(posedge clk);
close_passenger_door;
repeat(14) @(posedge clk);	
open_passenger_door;
repeat(25) @(posedge clk);
close_passenger_door;
repeat(15) @(posedge clk);
turn_on_ignition;
repeat(5) @(posedge clk);
press_brake_pedal;
@(posedge clk);
release_brake_pedal;
press_hidden_switch;
@(posedge clk);
release_hidden_switch;
@(posedge clk);
press_brake_pedal;
press_hidden_switch;
@(posedge clk);
release_brake_pedal;
release_hidden_switch;
repeat(10) @(posedge clk);

$finish;

end

endmodule
