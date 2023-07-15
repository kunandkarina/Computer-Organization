module Mux3to1( data0_i, data1_i, data2_i, select_i, data_o );

parameter size = 0;			   
			
//I/O ports               
input wire	[size-1:0] data0_i;          
input wire	[size-1:0] data1_i;
input wire	[size-1:0] data2_i;
input wire	[2-1:0] select_i;
output wire	[size-1:0] data_o; 

//Main function
/*your code here*/
reg [size-1:0] out;
assign data_o = out;
always @(*)
    if(select_i == 2'b00)
        out = data0_i;
    else if(select_i == 2'b01)
        out = data1_i;
    else if(select_i == 2'b10)
        out = data2_i;
endmodule      
