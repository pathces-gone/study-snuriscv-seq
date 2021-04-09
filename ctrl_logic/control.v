module control(
    input clk,
    input reset,
    input [31:0] pc,
    input [31:0] data,
    input [31:0] jump_reg_target,
    input status, // 2bit ??
    input [31:0] alu_out,
    output [1:0] pc_sel,
    output [11:0] imm12,    
    output op1_sel,
    output op2_sel,
    output [3:0] alu_ctrl,
    output br_type,
    output rf_wen,
    output dmem_vaild,
    output dmem_fcn,
    output [1:0] wb_sel
);

/*
OPCODE:
R type: 0110011
    add     rd rs1 rs2 31..25=0  14..12=0 6..2=0x0C 1..0=3
    sub     rd rs1 rs2 31..25=32 14..12=0 6..2=0x0C 1..0=3
    sll     rd rs1 rs2 31..25=0  14..12=1 6..2=0x0C 1..0=3
    slt     rd rs1 rs2 31..25=0  14..12=2 6..2=0x0C 1..0=3
    sltu    rd rs1 rs2 31..25=0  14..12=3 6..2=0x0C 1..0=3
    xor     rd rs1 rs2 31..25=0  14..12=4 6..2=0x0C 1..0=3
    srl     rd rs1 rs2 31..25=0  14..12=5 6..2=0x0C 1..0=3
    sra     rd rs1 rs2 31..25=32 14..12=5 6..2=0x0C 1..0=3
    or      rd rs1 rs2 31..25=0  14..12=6 6..2=0x0C 1..0=3
    and     rd rs1 rs2 31..25=0  14..12=7 6..2=0x0C 1..0=3
I type: 00100 11
    addi    rd rs1 imm12           14..12=0 6..2=0x04 1..0=3
    slli    rd rs1 31..26=0  shamt 14..12=1 6..2=0x04 1..0=3
    slti    rd rs1 imm12           14..12=2 6..2=0x04 1..0=3
    sltiu   rd rs1 imm12           14..12=3 6..2=0x04 1..0=3
    xori    rd rs1 imm12           14..12=4 6..2=0x04 1..0=3
    srli    rd rs1 31..26=0  shamt 14..12=5 6..2=0x04 1..0=3
    srai    rd rs1 31..26=16 shamt 14..12=5 6..2=0x04 1..0=3
    ori     rd rs1 imm12           14..12=6 6..2=0x04 1..0=3
    andi    rd rs1 imm12           14..12=7 6..2=0x04 1..0=3
I type2: 00000 11
    lb      rd rs1       imm12 14..12=0 6..2=0x00 1..0=3
    lh      rd rs1       imm12 14..12=1 6..2=0x00 1..0=3
    lw      rd rs1       imm12 14..12=2 6..2=0x00 1..0=3
    lbu     rd rs1       imm12 14..12=4 6..2=0x00 1..0=3
    lhu     rd rs1       imm12 14..12=5 6..2=0x00 1..0=3
S type: 01000 11
    sb     imm12hi rs1 rs2 imm12lo 14..12=0 6..2=0x08 1..0=3
    sh     imm12hi rs1 rs2 imm12lo 14..12=1 6..2=0x08 1..0=3
    sw     imm12hi rs1 rs2 imm12lo 14..12=2 6..2=0x08 1..0=3
SB type: 11000 11
    beq     bimm12hi rs1 rs2 bimm12lo 14..12=0 6..2=0x18 1..0=3
    bne     bimm12hi rs1 rs2 bimm12lo 14..12=1 6..2=0x18 1..0=3
    blt     bimm12hi rs1 rs2 bimm12lo 14..12=4 6..2=0x18 1..0=3
    bge     bimm12hi rs1 rs2 bimm12lo 14..12=5 6..2=0x18 1..0=3
    bltu    bimm12hi rs1 rs2 bimm12lo 14..12=6 6..2=0x18 1..0=3
    bgeu    bimm12hi rs1 rs2 bimm12lo 14..12=7 6..2=0x18 1..0=3
U type:
    jal     rd jimm20                          6..2=0x1b 1..0=3
J type:
    jalr    rd rs1 imm12              14..12=0 6..2=0x19 1..0=3    
*/

    `define R_FORMAT  7'b0110011
    `define I_FORMAT  7'b0010011
    `define I2_FORMAT 7'b0000011
    `define S_FORMAT  7'b0100011
    `define SB_FORMAT 7'b1001011
    `define U_FORMAT  7'b1100111
    `define J_FORMAT  7'b1101111

    //Common
    wire [6:0] opcode;
    wire [4:0] rs2;
    wire [4:0] rs1;
    wire [2:0] funct3;
    wire [4:0] rd;
    assign rs2 = data[24:20];
    assign rs1 = data[19:15];
    assign funct3 = data[14:12];
    assign rd = data[11:7];
    assign opcode = data[6:0];
    // R type
    wire [6:0] r_funct7;
    assign r_funct7 = data[31:25];
    // I type
    wire [11:0] i_imm;
    assign i_imm = data[31:20];
    // S type
    wire [6:0] s_imm_h;
    wire [4:0] s_imm_l;
    assign s_imm_h = data[31:25];
    assign s_imm_l = data[11:7];
    // SB type
    wire [6:0] sb_imm_h;
    wire [4:0] sb_imm_l;
    assign sb_imm_h = data[31:25];
    assign sb_imm_l = data[11:7];


    assign alu_ctrl = (opcode == `I_FORMAT)  ? 4'b0010
    : (opcode == `I2_FORMAT) ? 4'b0010  
    : (opcode == `SB_FORMAT) ? 4'b0110
    : (opcode == `S_FORMAT)  ? 4'b0010
    : (opcode == `R_FORMAT)  ? (funct3 == 3'b111) ? 4'b0000 
            : (funct3 == 3'b110) ? 4'b0001
            : (funct3 == 3'b000) ? (r_funct7[5] == 0) ? 4'b0010
                    : 4'b0110
            : 4'b0000
    : 4'b0000;



    /*PCGEN*/
    wire [1:0] taken = (alu_out == 0) ? 2'b01 : 2'b10;

    assign pc_sel = (pc==32'hfffffffc) ? 2'b10 
    : (opcode == `J_FORMAT) ? 2'b00
    : (opcode == `U_FORMAT) ? 2'b01
    : (opcode == `S_FORMAT) ? 2'b10
    : (opcode == `R_FORMAT) ? 2'b10
    : (opcode == `SB_FORMAT)? taken
    : 2'b10;


    /*Fatch*/

    /*Decoder*/
    assign imm12 = (opcode == `I_FORMAT) ?  data[31:20]
    : (opcode == `I2_FORMAT) ?  data[31:20]
    : (opcode == `S_FORMAT)  ? {data[31:24],data[11:7]}
    : (opcode == `SB_FORMAT) ? {data[31], data[7], data[30:25], data[11:8]}
    : (opcode == `J_FORMAT) ? {data[22:11]}
    : 12'bx;

    //assign imm20 = ; // TODO

    wire [1:0] aluop = (opcode == `R_FORMAT) ? 2'b10
    : (opcode == `I_FORMAT)  ? 2'b00
    : (opcode == `S_FORMAT)  ? 2'b00
    : (opcode == `I2_FORMAT) ? 2'b00
    : (opcode == `SB_FORMAT) ? 2'b00
    : 2'b00 ;

    assign op1_sel = aluop[0];
    assign op2_sel = aluop[1];

    assign rf_wen = (opcode == `R_FORMAT) ? 1 
    : (opcode == `I_FORMAT) ? 1
    : (opcode == `I2_FORMAT) ? 1
    : 0;

    /*Excution*/
    assign br_type = (opcode == `SB_FORMAT) ? 0: 1;

    /*memory*/
    assign dmem_vaild = ((opcode == `S_FORMAT) | (opcode == `I2_FORMAT)) ? 1 : 0;
    assign dmem_fcn = (opcode == `I2_FORMAT) ? 1:0;

    /*Writeback*/
    assign wb_sel = (opcode == `R_FORMAT) ? 2'b01
    : (opcode == `I2_FORMAT) ? 2'b00
    : (opcode == `I_FORMAT) ? 2'b01
    : 2'b10;
endmodule