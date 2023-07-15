module Pipeline_CPU( clk_i, rst_n );
input         clk_i;
input         rst_n;




wire [32-1:0] PC_i;
wire [32-1:0] PC_o;

Mux2to1 #(.size(32)) to_PC(
        .data0_i(PC_add1),
        .data1_i(EXMEM_o[101:70]),
        .select_i(PCsrc),
        .data_o(PC_i)
);
Program_Counter PC(
        .clk_i(clk_i),      
        .rst_n(rst_n),     
        .pc_in_i(PC_i),//32b
        .pc_out_o(PC_o) //32b
);
wire [32-1:0] PC_add1;
Adder PC_plus_4(
    .src1_i(PC_o), 
    .src2_i(32'd4), 
    .sum_o(PC_add1)//32b
); 
wire [32-1:0] instr;
Instr_Memory IM( 
        .pc_addr_i(PC_o), //32b
        .instr_o(instr)//32b
);

wire [64-1:0] IFID_o;
Pipeline_Reg #(.size(64)) IFID(
    .clk_i(clk_i),
    .rst_n(rst_n), 
    .data_i({PC_add1,instr}), 
    .data_o(IFID_o)
);

// 


wire RegWrite;//WB
wire [2:0]ALUOP; //EX
wire ALUSrc; //EX
wire [1:0]RegDst; //EX
wire Branch; //M
wire MemWrite; //M
wire MemRead; //M
wire Jump; //
wire BranchType; //
wire [1:0]MemtoReg; //WB


wire[32-1:0] ReadData1, ReadData2;
Reg_File RF( 
	.clk_i(clk_i), 
	.rst_n(rst_n), 
	.RSaddr_i(IFID_o[25:21]), 
	.RTaddr_i(IFID_o[20:16]), 
	.Wrtaddr_i(MEMWB_o[4:0]), 
	.Wrtdata_i(write_data_o[31:0]), 
	.RegWrite_i(MEMWB_o[70]), 
	.RSdata_o(ReadData1), 
	.RTdata_o (ReadData2)
);
wire [32-1:0]signextend;
Sign_Extend sign_extend( 
	.data_i(IFID_o[15:0]), 
	.data_o(signextend)//32b 
);
/*
RegWrite//WB
ALUOP //EX
ALUSrc //EX
RegDst //EX
Branch //M
MemWrite //M
MemRead //M
Jump //
BranchType //
MemtoReg //WB
*/
Decoder decoder( 
	.instr_op_i(IFID_o[31:26]), //6b
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

wire [148-1:0] IDEX_o;
Pipeline_Reg #(.size(148)) IDEX(
    .clk_i(clk_i),
    .rst_n(rst_n), 
    .data_i({
        RegWrite,       //WB    [147]
        MemtoReg[0],    //WB    [146]
        Branch,         //M     [145]
        MemRead,        //M     [144]
        MemWrite,       //M     [143]
        RegDst[0],      //EX    [142]
        ALUOP[2:0],     //EX    [141:139]
        ALUSrc,         //EX    [138]
        IFID_o[64-1:32],//32    [137:106]
        ReadData1,      //32    [105:74]
        ReadData2,      //32    [73:42]
        signextend,     //32    [41:10]
        IFID_o[20:16],  //5     [9:5]
        IFID_o[15:11]   //5     [4:0] 
        }), 
    .data_o(IDEX_o)
);


wire [32-1:0]branch_address; 
Adder get_branch_address(
	.src1_i(IDEX_o[137:106]),
	.src2_i({IDEX_o[39:10],2'b00}),
	.sum_o(branch_address[31:0])
);
wire[32-1:0] alu_src_2;

Mux2to1 #(.size(32)) ALUsrc2(
	.data0_i(IDEX_o[73:42]),
	.data1_i(IDEX_o[41:10]), 
	.select_i(IDEX_o[138]),
	.data_o(alu_src_2[31:0])
);
wire [4-1:0]ALU_operation;
wire [2-1:0]FURslt;
ALU_Ctrl aluctrl( 
	.funct_i(IDEX_o[15:10]), 
	.ALUOp_i(IDEX_o[141:139]), 
	.ALU_operation_o(ALU_operation[3:0]), 
	.FURslt_o(FURslt)
);
wire [32-1:0] alu_res;
wire zero;
wire overflow;
ALU alu( 
	.aluSrc1(IDEX_o[105:74]), 
	.aluSrc2(alu_src_2[31:0]), 
	.ALU_operation_i(ALU_operation[3:0]), 
	.result(alu_res), 
	.zero(zero), 
	.overflow(overflow)
);
wire[5-1:0] write_address;
Mux2to1 #(.size(5)) regadd(
	.data0_i(IDEX_o[9:5]),
	.data1_i(IDEX_o[4:0]), 
	.select_i(IDEX_o[142]),
	.data_o(write_address[4:0])
);
wire[107-1:0] EXMEM_o;
Pipeline_Reg #(.size(107)) EXMEM(
	.clk_i(clk_i),
	.rst_n(rst_n), 
	.data_i({
        IDEX_o[147:146],//WB-2  [106:105]
        IDEX_o[145:143],//M-3   [104:102]
        branch_address[31:0],// [101:70]
        zero,//                 [69]
        alu_res[31:0],//        [68:37]
        IDEX_o[73:42],//        [36:5]
        write_address[4:0]//    [4:0]   
        }), 
    .data_o(EXMEM_o)
);
wire PCsrc;
assign PCsrc = EXMEM_o[104]&EXMEM_o[69];

wire [32-1:0] read_data;
Data_Memory DM(	
	.clk_i(clk_i), 
	.addr_i(EXMEM_o[68:37]), 
	.data_i(EXMEM_o[36:5]), 
	.MemRead_i(EXMEM_o[103]), 
	.MemWrite_i(EXMEM_o[102]), 
	.data_o(read_data[31:0])
);

wire [71-1:0]MEMWB_o;
Pipeline_Reg #(.size(71)) MEMWB(
	.clk_i(clk_i),
	.rst_n(rst_n), 
	.data_i({
        EXMEM_o[106:105],//WB-2  [106:105]
        read_data,		 //[68:37]
		EXMEM_o[68:37],  //[37:5]
		EXMEM_o[4:0]     //[4:0]
        }), 
    .data_o(MEMWB_o)
);

wire [32-1:0] write_data_o;

Mux2to1 #(.size(32)) write_data(
	.data0_i(MEMWB_o[36:5]), 
	.data1_i(MEMWB_o[68:37]), 
	.select_i(MEMWB_o[69]), 
	.data_o(write_data_o)
);

endmodule