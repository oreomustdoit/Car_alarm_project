module car_alarm_fsm
(
clk,rst,
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

input clk,rst;
input driver_door_switch;//driver door open=1 close=0
input passenger_door_switch;//passenger door open=1 close=0
input ignition_switch;//ignition=1 off=0
input hidden_switch;
input brake_pedal_switch;


output reg system_arm;//alarm system activated=1 deactivated=0
output reg siren;//the siren
output reg led;
output reg fuel_pump_power;


reg [2:0]state;//states for system before it gets armed
reg [2:0]state_armed;//states for system after it gets armed
reg [1:0]state_led;//states for lED blinking
reg [3:0]count;//counter for system to go into armed mode
reg door_open_between;//if door is opened before 6 seconds of closing it
reg [3:0]count_driver;//counter for driver to start ignition after opening driver door
reg [3:0]count_passenger;//counter for driver to start ignition after opening passenger door
reg [3:0]count_alarm_extra;//counter alarm remains active after closing door
reg [1:0]count_led;
reg [1:0]state_fuelpump;

parameter t_arm_delay=6;//time before activation of system
parameter t_driver_delay=8;//time between driver door opening and alarm
parameter t_passenger_delay=15;//time between passenger door opening and alarm
parameter t_alarm_on=10;//time alarm remains active after all the doors are closed

/*--------------------------COUNTER FOR ACTIVATION THE SYSTEM------------------------------*/
always @(posedge rst or posedge clk)//for the counter for activation
begin

if(rst) {system_arm,state,state_armed,state_led,state_fuelpump,count,door_open_between,count_driver,count_passenger,count_alarm_extra,count_led,siren,led,fuel_pump_power}<=0;//all doors closed and alarm is off and counter=0//all doors closed and alarm is off and counter=0

else
begin

if(state>2) count<= (count==(t_arm_delay-1)|door_open_between|state==5)?1:count+1;//1to(t_arm_delay-1) counter which resets to 1 if door is opened in between or when alarm system is active 
else count<=1;
end

end

/*------------------------FSM FOR ACTIVATING THE ALARM SYSTEM---------------------------*/
always @(posedge rst or posedge clk)
begin
if(rst) {system_arm,state,state_armed,state_led,state_fuelpump,count,door_open_between,count_driver,count_passenger,count_alarm_extra,count_led,siren,led,fuel_pump_power}<=0;//all doors closed and alarm is off and counter=0//all doors closed and alarm is off and counter=0

else
begin
if(ignition_switch==0)
begin
door_open_between<=0;//door open between signal is off
case(state)
0: state<= ignition_switch?0:1;//when the ignition is turned off goes to state 1
1: begin
   case({driver_door_switch,passenger_door_switch})
   2'b00: state<=1;//none of the doors open yet so remains in state 1
   2'b01: state<=2;//even if one of the doors open it goes to state 2
   2'b10: state<=2;//even if one of the doors open it goes to state 2
   2'b11: state<=2;//even if one of the doors open it goes to state 2
   endcase
   end
2: begin
   case({driver_door_switch,passenger_door_switch})
   2'b00: state<=3;//reclosing both the doors it goes to state 3
   2'b01: state<=2;//even if one of the door remains open it stays in state 2
   2'b10: state<=2;//even if one of the door remains open it stays in state 2
   2'b11: state<=2;//even if one of the door remains open it stays in state 2
   endcase
   end

3: begin
     if((driver_door_switch==1|passenger_door_switch==1)&count<(t_arm_delay))//if either of the doors are opened before t_arm_delay then
       begin
	   door_open_between<=1;//the signal door open before t_arm_delay
	   state<=2;// it goes back to state 2 where atleast one door is open
       end	 
	 
	 else if(count==(t_arm_delay-1)) begin//once count==5 it goes to state 4
                                 	 state<=4;
									 system_arm<=1;//once count==5 the system is armed immediately as it enters the next state
									 end
	 
	 else state<=3;//remains in state 3 until count==5
	
   end

4: begin//system remains armed and the state remains in state  4
   system_arm<=1;
   state<=4;
   end
default: state<=4;
endcase
end
else {system_arm,count,door_open_between,state}<=0;//if ignition is off all these are defaulted to 0
end

end

/*-----------------------------------COUNTER FOR DRIVER DELAY---------------------------------*/
always @(posedge rst or posedge clk)
begin
if(rst) {system_arm,state,state_armed,state_led,state_fuelpump,count,door_open_between,count_driver,count_passenger,count_alarm_extra,count_led,siren,led,fuel_pump_power}<=0;//all doors closed and alarm is off and counter=0//all doors closed and alarm is off and counter=0
else
begin
if(state_armed==1) count_driver<=(count_driver==(t_driver_delay-1)|(driver_door_switch==0&passenger_door_switch==0))?1:count_driver+1;//0-t_driver_delay-1 counter which resets to 1 if driver and passenger both doors are closed
else count_driver<=1;

end
end

/*-------------------------------COUNTER FOR PASSENGER DELAY---------------------------------*/
always @(posedge rst or posedge clk)
begin
if(rst) {system_arm,state,state_armed,state_led,state_fuelpump,count,door_open_between,count_driver,count_passenger,count_alarm_extra,count_led,siren,led,fuel_pump_power}<=0;//all doors closed and alarm is off and counter=0//all doors closed and alarm is off and counter=0
else
begin
if(state_armed==2|state_armed==4) count_passenger<=(count_passenger==(t_passenger_delay-1))?1:count_passenger+1;//0-t_passenger_delay-1 counter which resets to one if state_armed!=2 or state!=4
else count_passenger<=1;

end
end

/*---------------------------COUNTER FOR EXTRA TIME THE ALARM IS ON AFTER CLOSING ALL DOORS-----------------------------*/
always @(posedge rst or posedge clk)
begin
if(rst) {system_arm,state,state_armed,state_led,state_fuelpump,count,door_open_between,count_driver,count_passenger,count_alarm_extra,count_led,siren,led,fuel_pump_power}<=0;//all doors closed and alarm is off and counter=0//all doors closed and alarm is off and counter=0
else
begin
if(state_armed==3) count_alarm_extra<=(count_alarm_extra==(t_alarm_on)|driver_door_switch==1|passenger_door_switch==1)?1:count_alarm_extra+1;//0-t_alarm_on counter which works when state_armed==3
else count_alarm_extra<=1;

end
end

/*-------------------------FSM FOR BEHAVIOUR OF SYSTEM IN ARMED STATE-----------------------------------------------*/
always @(posedge rst or posedge clk)
begin
if(rst) {system_arm,state,state_armed,state_led,state_fuelpump,count,door_open_between,count_driver,count_passenger,count_alarm_extra,count_led,siren,led,fuel_pump_power}<=0;//all doors closed and alarm is off and counter=0//all doors closed and alarm is off and counter=0

else
begin
if(system_arm==1&ignition_switch==0)
begin
siren<=0;
case(state_armed)
0:begin
  if(system_arm==1&driver_door_switch==1)  state_armed<=1;//if driver door opens first then state_armed goes to 1

  else if(system_arm==1&passenger_door_switch==1)  state_armed<=2;//if passenger door opens first then state_armed goes to 2

  else state_armed<=0;//if no door opens then state_armed stays in 0
  end
1: begin
   if(driver_door_switch==0&count_driver<t_driver_delay) state_armed<=0;//if driver door is closed before count_driver reaches t_driver_delay then state_armed goes back to 0
   else if(count_driver==(t_driver_delay-1)) begin                     //once count_driver reaches t_driver_delay-1 then siren starts and state_armed goes to 3
                                             siren<=1;
											 state_armed<=3;
                                             end
   else state_armed<=1;//otherwise state_armed waits in 1
   end
2: begin
   if(driver_door_switch==0&passenger_door_switch==0&count_passenger<t_passenger_delay) state_armed<=4;//if passenger closes door then after opening his first state_armed goes to 4
   else if(count_passenger==(t_passenger_delay-1))     begin //once count_passenger reaches t_passenger_delay-1 then siren starts and state_armed goes to 3
                                                       siren<=1;
													   state_armed<=3;
                                                       end
   else state_armed<=2;// otherwise state_armed waits in 2
   end
3: begin
   if(driver_door_switch==0&passenger_door_switch==0&count_alarm_extra==(t_alarm_on)) begin //if driver door && passenger door remain closed for t_alarm_on then siren stops and state_armed goes back to 0 
                                                                                      siren<=0;
																				      state_armed<=0;
																					  end
   else begin //otherwise siren keeps sounding with state_armed remaining at 3
        siren<=1;
		state_armed<=3;
		end
		
   end
4: begin
   if(driver_door_switch==0&passenger_door_switch==0&count_passenger==(t_passenger_delay-1)) state_armed<=0;//if all doors remain closed for t_passenger_delay then state_armed goes to 0
   else if(driver_door_switch==0&passenger_door_switch==0&count_passenger<(t_passenger_delay-1)) state_armed<=4;
   else if((driver_door_switch==1|passenger_door_switch==1)&count_passenger<(t_passenger_delay-1)) state_armed<=2;
   else if((driver_door_switch==1|passenger_door_switch==1)&count_passenger==(t_passenger_delay-1)) begin
                                                                                                   state_armed<=3;
																								   siren<=1;
                                                                                                   end
   

   end
default: state_armed<=0;
endcase
end
else {count_driver,count_passenger,count_alarm_extra,siren}<=0;

end

end

/*--------------------COUNTER FOR LED-------------------------------------------*/
always @(posedge rst or posedge clk)
begin
if(rst) {system_arm,state,state_armed,state_led,state_fuelpump,count,door_open_between,count_driver,count_passenger,count_alarm_extra,count_led,siren,led,fuel_pump_power}<=0;//all doors closed and alarm is off and counter=0//all doors closed and alarm is off and counter=0

else count_led<=count_led+1;
end

/*-----------------FSM FOR LED BLINKING---------------------------------------*/
always @(posedge rst or posedge clk)
begin
if(rst) {system_arm,state,state_armed,state_led,state_fuelpump,count,door_open_between,count_driver,count_passenger,count_alarm_extra,count_led,siren,led,fuel_pump_power}<=0;//all doors closed and alarm is off and counter=0//all doors closed and alarm is off and counter=0

else
begin
if(ignition_switch==0)
begin
led<=0;
case(state_led)
0:begin
  if(system_arm==0&count>=1) begin
                            state_led<=1;
							led<=1;
							end
  else state_led<=0;
  end
1:begin
  if(system_arm==0&count<(t_arm_delay-1)&count>=1) begin
                                                   state_led<=1;
												   led<=1;
												   end
												   
  else if(system_arm==1|count==(t_arm_delay-1)) begin
                                                led<=count_led[1];
												state_led<=2;
												end
  end

2:begin
  if(system_arm==1&siren==1) begin
                               led<=1;
							   state_led<=3;
							   end
  else if(system_arm==1&siren==0) begin
                                   led<=count_led[1];
								   state_led<=2;
								   end
  else if(system_arm==0) state_led<=0;
  end
  
3:begin
  if(siren==1) begin
               led<=1;
			   state_led<=3;
			   end
  else begin
       led<=count_led[1];
	   state_led<=2;
	   end
  end  

endcase
end
else led<=0;
end


end


/*-------------------------FSM FOR FUEL PUMP POWER------------------------------*/
always @(posedge rst or posedge clk)
begin
if(rst) {system_arm,state,state_armed,state_led,state_fuelpump,count,door_open_between,count_driver,count_passenger,count_alarm_extra,count_led,siren,led,fuel_pump_power}<=0;//all doors closed and alarm is off and counter=0//all doors closed and alarm is off and counter=0
else
begin
fuel_pump_power<=0;
case(state_fuelpump)
0: state_fuelpump<=ignition_switch;
1: begin
   if(ignition_switch==1&brake_pedal_switch==1&hidden_switch==1) begin
                                                          state_fuelpump<=2;
														  fuel_pump_power<=1;
														  end
   else if(ignition_switch==0) state_fuelpump<=0;
   else state_fuelpump<=1;
   end   
2: begin
   if(ignition_switch==1) begin
                          fuel_pump_power<=1;
						  state_fuelpump<=2;
						  end
   else begin
        state_fuelpump<=0;
		fuel_pump_power<=0;
		end
   end
default: begin 
fuel_pump_power<=0; 
state_fuelpump<=0;
 end
endcase
end
end
endmodule