module Simple_Single_CPU( clk_i, rst_n );

//I/O port
input         clk_i;
input         rst_n;

//Internal Signles
wire [31:0] pc_in;
wire [31:0] pc_out;
wire [31:0] instruction;
wire RegDst;
wire [4:0] write_Reg;
wire [31:0] write_Data;
wire RegWrite;
wire [31:0] rs_data;
wire [31:0] rt_data;
wire [2:0]ALUOP;
wire ALUSrc;
wire [3:0] ALU_operation;
wire [1:0] FURslt;
wire [31:0] Sign_ext;
wire [31:0] Zero_fill;
wire [31:0] ALU_src2;
wire [31:0] result;
wire zero;
wire overflow;
wire [31:0] shift_result;

//modules
Program_Counter PC(
        .clk_i(clk_i),      
	    .rst_n(rst_n),     
	    .pc_in_i(pc_in) ,   
	    .pc_out_o(pc_out) 
	    );
	
Adder Adder1(
        .src1_i(pc_out),     
	    .src2_i(32'd4),
	    .sum_o(pc_in)    
	    );
	
Instr_Memory IM(
        .pc_addr_i(pc_out),  
	    .instr_o(instruction)    
	    );

Mux2to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(instruction[20:16]),
        .data1_i(instruction[15:11]),
        .select_i(RegDst),
        .data_o(write_Reg)
        );	
		
Reg_File RF(
        .clk_i(clk_i),      
	    .rst_n(rst_n) ,     
        .RSaddr_i(instruction[25:21]) ,  
        .RTaddr_i(instruction[20:16]) ,  
        .RDaddr_i(write_Reg) ,  
        .RDdata_i(write_Data)  , 
        .RegWrite_i(RegWrite),
        .RSdata_o(rs_data) ,  
        .RTdata_o(rt_data)   
        );
	
Decoder Decoder(
        .instr_op_i(instruction[31:26]), 
	    .RegWrite_o(RegWrite), 
	    .ALUOp_o (ALUOP),   
	    .ALUSrc_o(ALUSrc),   
	    .RegDst_o(RegDst)   
		);

ALU_Ctrl AC(
        .funct_i(instruction[5:0]),   
        .ALUOp_i(ALUOP),   
        .ALU_operation_o(ALU_operation),
		.FURslt_o(FURslt)
        );
	
Sign_Extend SE(
        .data_i(instruction[15:0]),
        .data_o(Sign_ext)
        );

Zero_Filled ZF(
        .data_i(instruction[15:0]),
        .data_o(Zero_fill)
        );
		
Mux2to1 #(.size(32)) ALU_src2Src(
        .data0_i(rt_data),
        .data1_i(Sign_ext),
        .select_i(ALUSrc),
        .data_o(ALU_src2)
        );	
		
ALU ALU(
		.aluSrc1(rs_data),
	    .aluSrc2(ALU_src2),
	    .ALU_operation_i(ALU_operation),
		.result(result),
		.zero(zero),
		.overflow(overflow)
	    );
		
Shifter shifter( 
		.result(shift_result), 
		.leftRight(ALU_operation[3]),
		.shamt(instruction[10:6]),
		.sftSrc(ALU_src2) 
		);
		
Mux3to1 #(.size(32)) RDdata_Source(
        .data0_i(result),
        .data1_i(shift_result),
		.data2_i(Zero_fill),
        .select_i(FURslt),
        .data_o(write_Data)
        );			

endmodule
