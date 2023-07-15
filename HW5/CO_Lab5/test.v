module Simple_Single_CPU( clk_i, rst_n );

//I/O port
input         clk_i;
input         rst_n;

//Internal Signles
wire [32-1:0] instr, PC_i, PC_o, ReadData1, ReadData2, WriteData;
wire [32-1:0] signextend, zerofilled, ALUinput2, ALUResult, ShifterResult;
wire [5-1:0] WriteReg_addr, Shifter_shamt;
wire [4-1:0] ALU_operation;
wire [3-1:0] ALUOP;
wire [2-1:0] FURslt;
wire [2-1:0] RegDst, MemtoReg;
wire RegWrite, ALUSrc, zero, overflow;
wire Jump, Branch, BranchType, MemWrite, MemRead;
wire [32-1:0] PC_add1, PC_add2, PC_no_jump, PC_t, Mux3_result, DM_ReadData;
wire Jr;
assign Jr = ((instr[31:26] == 6'b000000) && (instr[20:0] == 21'd8)) ? 1 : 0;
wire MEM_EX_ID_RegWrite;
wire [32-1:0] WB_Data;
//modules
//IF
Program_Counter PC(
        .clk_i(clk_i),
	    .rst_n(rst_n),
	    .pc_in_i(PC_i),
	    .pc_out_o(PC_o)
	    );

Adder Adder1(//next instruction
        .src1_i(PC_o), 
	    .src2_i(32'd4),
	    .sum_o(PC_add1)
	    );
	    
Instr_Memory IM(
        .pc_addr_i(PC_o),
	    .instr_o(instr)
	    );

// IF/ID
wire [32-1:0] IF_instr;
Pipeline_Reg #(.size(32)) Pipeline_IFID(
            .clk_i(clk_i),
            .rst_n(rst_n),
            .data_i(instr),
            .data_o(IF_instr)
        );

// ID
Reg_File RF(
        .clk_i(clk_i),
	    .rst_n(rst_n),
        .RSaddr_i(IF_instr[25:21]),
        .RTaddr_i(IF_instr[20:16]),
        .Wrtaddr_i(WriteReg_addr),
        .Wrtdata_i(WB_Data),
        .RegWrite_i(MEM_EX_ID_RegWrite),// consider jr
        .RSdata_o(ReadData1),
        .RTdata_o(ReadData2)
        );
        
Decoder Decoder(
        .instr_op_i(IF_instr[31:26]),
	    .RegWrite_o(RegWrite),
	    .ALUOp_o(ALUOP),
	    .ALUSrc_o(ALUSrc),
	    .RegDst_o(RegDst),
		.Jump_o(Jump),
		.Branch_o(Branch),
		.BranchType_o(BranchType),
		.MemWrite_o(MemWrite),
		.MemRead_o(MemRead),
		.MemtoReg_o(MemtoReg)
		);

Sign_Extend SE(
        .data_i(IF_instr[15:0]),
        .data_o(signextend)
        );

Zero_Filled ZF(
        .data_i(IF_instr[15:0]),
        .data_o(zerofilled)
        );

//ID/EX
wire [2-1:0] ID_RegDst;
wire ID_RegWrite;
wire [3-1:0] ID_ALUOp;
wire ID_ALUSrc;
wire ID_MemWrite;
wire ID_MemRead;
wire ID_MemtoReg;
Pipeline_Reg #(.size(9)) Pipeline_Control(
            .clk_i(clk_i),
            .rst_n(rst_n),
            .data_i({RegWrite, ALUOP, ALUSrc, RegDst, MemRead, MemWrite, MemtoReg}),
            .data_o({ID_RegWrite, ID_ALUOp, ID_ALUSrc, ID_RegDst, ID_MemRead, ID_MemWrite, ID_MemtoReg})
        );
wire [32-1:0] ID_ReadData1;
Pipeline_Reg #(.size(32)) Pipeline_ReadData1(
            .clk_i(clk_i),
            .rst_n(rst_n),
            .data_i(ReadData1),
            .data_o(ID_ReadData1)
        );
wire [32-1:0] ID_ReadData2;
Pipeline_Reg #(.size(32)) Pipeline_ReadData2(
            .clk_i(clk_i),
            .rst_n(rst_n),
            .data_i(ReadData2),
            .data_o(ID_ReadData2)
        );
wire [32-1:0] ID_signextend;
Pipeline_Reg #(.size(32)) Pipeline_SE( 
		.clk_i(clk_i),
		.rst_n(rst_n),
		.data_i(signextend),
		.data_o(ID_signextend)
		);
wire [32-1:0] ID_zerofilled;
Pipeline_Reg #(.size(32)) Pipeline_ZF( 
		.clk_i(clk_i),
		.rst_n(rst_n),
		.data_i(zerofilled),
		.data_o(ID_zerofilled)
		);
wire [32-1:0] ID_IF_instr;
Pipeline_Reg #(.size(32)) Pipeline_IM_ID_EX( 
		.clk_i(clk_i),
		.rst_n(rst_n),
		.data_i(IF_instr),
		.data_o(ID_IF_instr)
		);
//EX
wire [5-1:0] Write_reg;
Mux2to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(ID_IF_instr[20:16]),
        .data1_i(ID_IF_instr[15:11]),
        .select_i(ID_RegDst[0]),
        .data_o(Write_reg)
        );
ALU_Ctrl AC(
        .funct_i(ID_IF_instr[5:0]),
        .ALUOp_i(ID_ALUOp),
        .ALU_operation_o(ALU_operation),
		.FURslt_o(FURslt)
        );
Mux2to1 #(.size(32)) ALU_src2Src(
        .data0_i(ID_ReadData2),
        .data1_i(ID_signextend),
        .select_i(ALUSrc),
        .data_o(ALUinput2)
        );	

ALU ALU(
		.aluSrc1(ReadData1),
	    .aluSrc2(ALUinput2),
	    .ALU_operation_i(ALU_operation),
		.result(ALUResult),
		.zero(zero),
		.overflow(overflow)
	    );
Shifter shifter( 
		.result(ShifterResult),
		.leftRight(ALU_operation[0]),
		.shamt(ID_IF_instr[10:6]),
		.sftSrc(ALUinput2)
		);	    
Mux3to1 #(.size(32)) RDdata_Source(
        .data0_i(ALUResult),
        .data1_i(ShifterResult),
		.data2_i(ID_zerofilled),
        .select_i(FURslt),
        .data_o(Mux3_result)
        );
//EX/MEM
wire EX_ID_RegWrite;
wire EX_ID_MemWrite;
wire EX_ID_MemRead;
wire EX_ID_MemtoReg;
Pipeline_Reg #(.size(4)) Pipeline_Control_EX(
        .clk_i(clk_i),
        .rst_n(rst_n),
        .data_i({ID_RegWrite, ID_MemRead, ID_MemWrite, ID_MemtoReg}),
        .data_o({EX_ID_RegWrite, EX_ID_MemRead, EX_ID_MemWrite, EX_ID_MemtoReg})
        );
wire [32-1:0] EX_Mux3_result;
Pipeline_Reg #(.size(4)) Pipeline_Write_Data(
        .clk_i(clk_i),
        .rst_n(rst_n),
        .data_i(Mux3_result),
        .data_o(EX_Mux3_result)
        );
wire [32-1:0] EX_ID_ReadData2;
Pipeline_Reg #(.size(32)) Pipeline_RT_EX(
        .clk_i(clk_i),
        .rst_n(rst_n),
        .data_i(ID_ReadData2),
        .data_o(EX_ID_ReadData2)    
        );
wire [5-1:0] EX_Write_reg;
Pipeline_Reg #(.size(5)) Pipeline_Write_reg( 
		.clk_i(clk_i),
		.rst_n(rst_n),
		.data_i(Write_reg),
		.data_o(EX_Write_reg)
		);
//MEM
Data_Memory DM(
		.clk_i(clk_i),
		.addr_i(EX_Mux3_result),
		.data_i(EX_ID_ReadData2),
		.MemRead_i(EX_ID_MemRead),
		.MemWrite_i(EX_ID_MemWrite),
		.data_o(DM_ReadData)
		);
//MEM/WB
wire MEM_EX_ID_MemtoReg;

Pipeline_Reg #(.size(2)) Pipeline_Control_MEM( 
		.clk_i(clk_i),
		.rst_n(rst_n),
		.data_i({EX_ID_RegWrite, EX_ID_MemtoReg}),
		.data_o({MEM_EX_ID_RegWrite, MEM_EX_ID_MemtoReg})
		);
wire [32-1:0] MEM_EX_Mux3_result;
Pipeline_Reg #(.size(32)) Pipeline_Write_Data_MEM( 
		.clk_i(clk_i),
		.rst_n(rst_n),
		.data_i(EX_Mux3_result),
		.data_o(MEM_EX_Mux3_result)
		);
wire [32-1:0] MEM_MemReadData;
wire [32-1:0] MemReadData;
Pipeline_Reg #(.size(32)) Pipeline_MEM_Data( 
		.clk_i(clk_i),
		.rst_n(rst_n),
		.data_i(MemReadData),
		.data_o(MEM_MemReadData)
		);
wire [5-1:0] MEM_EX_Write_reg;
Pipeline_Reg #(.size(5)) Pipeline_Write_reg_MEM( 
		.clk_i(clk_i),
		.rst_n(rst_n),
		.data_i(EX_Write_reg),
		.data_o(MEM_EX_Write_reg)
		);	
//WB

Mux2to1 #(.size(32)) WB_Mux(
        .data0_i(MEM_EX_Mux3_result),
        .data1_i(MEM_MemReadData),
        .select_i(MEM_EX_ID_MemtoReg),
        .data_o(WB_Data)
	);

endmodule