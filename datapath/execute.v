module execute(
    input reset,
    input clk,
    input [31:0] pc,
    input [3:0] alu_ctrl,
    input br_type,
    input [31:0] mux1out,
    input [31:0] mux2out,
    input [31:0] rs2_data,
    output [31:0] brjmp_target,
    output [31:0] alu_out
);



wire [31:0] alu_in1;
wire [31:0] alu_in2;
assign alu_in1 = mux1out;
assign alu_in2 = (br_type == 0) ? rs2_data: mux2out;
alu alu1(.clk(clk), .reset(reset), .alu_in1(alu_in1), .alu_in2(alu_in2), .alu_ctrl(alu_ctrl), .alu_out(alu_out));

assign brjmp_target = mux2out + pc;


endmodule