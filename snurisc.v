module snurisc(
    input reset,
    input clk
    );

    wire [31:0] jump_reg_target;
    wire [31:0] brjmp_target;

    wire [31:0] data;
    wire [31:0] wbdata;

    wire [1:0] pc_sel;
    wire im_status;
    wire dm_status;
    wire [11:0] imm12;
    wire op1_sel;
    wire op2_sel;
    wire [3:0] alu_ctrl;
    wire br_type;

    wire dmem_fcn;
    wire dmem_vaild;
    wire [1:0] wb_sel;
    wire rf_wen;

    wire [31:0] inst_pc;
    wire [31:0] add_pc;
    wire [31:0] mux1out;
    wire [31:0] mux2out;
    wire [31:0] rs2_data;
    wire [31:0] alu_out;
    wire [31:0] rdata;

    control ctrl(
        .clk(clk),
        .reset(reset),
        .data(data),
        .pc(inst_pc),
        .jump_reg_target(jump_reg_target),
        .status(im_status),
        .alu_out(alu_out),
        .pc_sel(pc_sel),
        .imm12(imm12),
        .op1_sel(op1_sel),
        .op2_sel(op2_sel),
        .alu_ctrl(alu_ctrl),
        .br_type(br_type),
        .rf_wen(rf_wen),
        .dmem_vaild(dmem_vaild),
        .dmem_fcn(dmem_fcn),
        .wb_sel(wb_sel)
    );

    pcgen pc_gen(
        .clk(clk),
        .reset(reset),
        .pc_sel(pc_sel),
        .jump_reg_target(jump_reg_target),
        .brjmp_target(brjmp_target),
        .npc(inst_pc),
        .add_pc(add_pc)
        );

    fetch inst_fetch(
        .clk(clk),
        .reset(reset),
        .pc(inst_pc),
        .data(data),
        .status(im_status)
    );


    decode inst_decoder(
        .clk(clk),
        .reset(reset),
        .pc(inst_pc),
        .data(data),
        .wbdata(wbdata),
        .rf_wen(rf_wen),
        .op1_sel(op1_sel),
        .op2_sel(op2_sel),
        .imm12(imm12),
        .mux1out(mux1out),
        .mux2out(mux2out),
        .rs2_data(rs2_data)
    );

    execute inst_execute(
        .clk(clk),
        .reset(reset),
        .pc(inst_pc),
        .alu_ctrl(alu_ctrl),
        .br_type(br_type),
        .mux1out(mux1out),
        .mux2out(mux2out),
        .rs2_data(rs2_data),
        .brjmp_target(brjmp_target),
        .alu_out(alu_out)
    );

    dmem data_memory(
        .reset(reset), 
        .clk(clk),
        .rnw(dmem_fcn),
        .enable(dmem_vaild),
        .status(dm_status),
        .addr(alu_out),
        .wdata(rs2_data),
        .rdata(rdata)
    );

    assign jump_reg_target = alu_out;
    assign wbdata = (wb_sel == 2'b10) ? add_pc
        : (wb_sel == 2'b01) ? alu_out 
        : rdata;


endmodule