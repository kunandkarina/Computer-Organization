module Decoder( instr_op_i, RegWrite_o,	ALUOp_o, ALUSrc_o, RegDst_o, Jump_o, Branch_o, BranchType_o, MemWrite_o, MemRead_o, MemtoReg_o);
     
//I/O ports
input	[6-1:0] instr_op_i;

output			RegWrite_o;
output	[3-1:0] ALUOp_o;
output			ALUSrc_o;
output	[2-1:0]	RegDst_o, MemtoReg_o;
output			Jump_o, Branch_o, BranchType_o, MemWrite_o, MemRead_o;
 
//Internal Signals
wire	[3-1:0] ALUOp_o;
wire			ALUSrc_o;
wire			RegWrite_o;
wire	[2-1:0]	RegDst_o, MemtoReg_o;
wire			Jump_o, Branch_o, BranchType_o, MemWrite_o, MemRead_o;

//Main function
/*your code here*/

assign RegWrite_o = (instr_op_i == 6'b000000) ? 1'b1:  //R-format
                   (instr_op_i == 6'b001000) ? 1'b1:  // addi
                   (instr_op_i == 6'b100001) ? 1'b1:  //  lw
                   1'b0;
assign ALUOp_o = (instr_op_i == 6'b000000) ? 3'b010:  //R-format
                (instr_op_i == 6'b001000) ? 3'b011:  // addi
                (instr_op_i == 6'b100001) ? 3'b000:  // lw
                (instr_op_i == 6'b100011) ? 3'b000:  // sw
                (instr_op_i == 6'b111011) ? 3'b001:  // beq
                (instr_op_i == 6'b100101) ? 3'b110:  // bne
                3'b000;
assign ALUSrc_o = (instr_op_i == 6'b000000) ? 1'b0:  // R-format
                 (instr_op_i == 6'b001000) ? 1'b1:  // addi
                 (instr_op_i == 6'b100001) ? 1'b1:  // lw
                 (instr_op_i == 6'b100011) ? 1'b1:  // sw
                 1'b0;
assign RegDst_o[0] = (instr_op_i == 6'b000000) ? 1'b1:  // R-format
                 (instr_op_i == 6'b001000) ? 1'b0:  // addi
                 1'b0;
assign MemtoReg_o[0] = (instr_op_i == 6'b100001) ? 1'b1:  // lw
                 1'b0;
assign Jump_o = (instr_op_i == 6'b100010) ? 1'b1:  // jump
               1'b0;
assign Branch_o = (instr_op_i == 6'b111011) ? 1'b1:  // beq
                 (instr_op_i == 6'b100101) ? 1'b1:  // bne
                 1'b0;
assign BranchType_o = (instr_op_i == 6'b111011) ? 1'b0:  // beq
                     (instr_op_i == 6'b100101) ? 1'b1:  // bne
                     1'b0;
assign MemWrite_o = (instr_op_i == 6'b100011) ? 1'b1:  // sw
                   1'b0;
assign MemRead_o = (instr_op_i == 6'b100001) ? 1'b1:  // lw
                  1'b0;
endmodule
   