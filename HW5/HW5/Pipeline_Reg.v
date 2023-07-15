module Pipeline_Reg(clk_i, rst_n, data_i, data_o);

parameter size = 0;
input wire clk_i;
input wire rst_n;
input wire [size-1:0] data_i;
output reg[size-1:0] data_o;



always @(posedge clk_i)begin
    if(rst_n) 
        data_o <= data_i;
    else 
        data_o <= 0;
end

endmodule