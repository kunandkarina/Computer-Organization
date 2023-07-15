module ALU_Ctrl( funct_i, ALUOp_i, ALU_operation_o, FURslt_o );

//I/O ports 
input      [6-1:0] funct_i;
input      [3-1:0] ALUOp_i;

output     [4-1:0] ALU_operation_o;  
output     [2-1:0] FURslt_o;
     
//Internal Signals
wire		[4-1:0] ALU_operation_o;
wire		[2-1:0] FURslt_o;

//Main function
/*your code here*/
assign {ALU_operation_o, FURslt_o} = (ALUOp_i[1] == 1'b0) ? {4'b0010, 2'b00} : // addi
                                     (ALUOp_i[1] == 1'b1) ? {                  // r-format
                                            (funct_i == 6'b010010) ? {4'b0010, 2'b00} : // add
                                            (funct_i == 6'b010000) ? {4'b0110, 2'b00} : // sub
                                            (funct_i == 6'b010100) ? {4'b0001, 2'b00} : // and
                                            (funct_i == 6'b010110) ? {4'b0000, 2'b00} : // or
                                            (funct_i == 6'b010101) ? {4'b1101, 2'b00} : // nor
                                            (funct_i == 6'b100000) ? {4'b0111, 2'b00} : // slt
                                            (funct_i == 6'b000000) ? {4'b1000, 2'b01} : // sll
                                            (funct_i == 6'b000010) ? {4'b0000, 2'b01} : // srl
                                            0
                                     } : 0;

endmodule     
