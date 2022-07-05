module fiftymhz_to_onehz(clk_fiftymhz,rst,clk_onehz);

output reg clk_onehz;
input clk_fiftymhz,rst;

reg [25:0]count;

always @(posedge clk_fiftymhz or posedge rst)
begin
if(rst) count<=1;
else count<=(count==50000000)?1:count+1;
end

always @(posedge clk_fiftymhz or posedge rst)
begin
if(rst) clk_onehz<=1;
else
begin
if((count==24999999)|(count==49999999)) clk_onehz<=!clk_onehz;
else clk_onehz<=clk_onehz;
end
end

endmodule