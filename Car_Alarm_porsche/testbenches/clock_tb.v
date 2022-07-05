module tb;

reg clk_fiftymhz=0;
reg rst=0;

always #10 clk_fiftymhz=!clk_fiftymhz;

wire clk_onehz;

fiftymhz_to_onehz DUT(clk_fiftymhz,rst,clk_onehz);

initial
begin
#1;rst=1;#1;rst=0;
repeat(200000000) @(posedge clk_fiftymhz);
$finish;
end

endmodule