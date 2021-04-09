module decode(
    input reset,
    input clk,
    input rf_wen,
    input [31:0] pc,
    input [31:0] data,
    input [31:0] wbdata,
    input op1_sel,
    input op2_sel,
    input [11:0] imm12,
    output [31:0] mux1out,
    output [31:0] mux2out,
    output [31:0] rs2_data
);

    wire [31:0] zero;
    assign zero = 31'b0;

    // Register File
    reg [31:0] rf[0:30];
    wire [31:0] rs1_data;

    wire [4:0] rs2;
    wire [4:0] rs1;
    wire [4:0] rd;
    assign rs2 = data[24:20];
    assign rs1 = data[19:15];
    assign rd = data[11:7];

    assign rs1_data = rf[rs1];
    assign rs2_data = rf[rs2];

    wire [31:0] immgen_out;
    wire [11:0] imm12;

    immgen _immgen(
        .imm12(imm12),
        .immgen(immgen_out)
    );

    assign mux1out = (op1_sel) ? pc : rs1_data;
    assign mux2out = (op2_sel) ? rs2_data : immgen_out;

    always @(posedge clk) begin
        if(reset) begin
            rf[0] <= #1 zero;
            rf[1] <= #1 zero;
            rf[2] <= #1 zero;
            rf[3] <= #1 zero;
            rf[4] <= #1 zero;
            rf[5] <= #1 zero;
            rf[6] <= #1 zero;
            rf[7] <= #1 zero;
            rf[8] <= #1 zero;
            rf[9] <= #1 zero;
            rf[10] <= #1 zero;
            rf[11] <= #1 zero;
            rf[12] <= #1 zero;
            rf[13] <= #1 zero;
            rf[14] <= #1 zero;
            rf[15] <= #1 zero;
            rf[16] <= #1 zero;
            rf[17] <= #1 zero;
            rf[18] <= #1 zero;
            rf[19] <= #1 zero;
            rf[20] <= #1 zero;
            rf[21] <= #1 zero;
            rf[22] <= #1 zero;
            rf[23] <= #1 zero;
            rf[24] <= #1 zero;
            rf[25] <= #1 zero;
            rf[26] <= #1 zero;
            rf[27] <= #1 zero;
            rf[28] <= #1 zero;
            rf[29] <= #1 zero;
            rf[30] <= #1 zero;
        end
        else begin

            if(rf_wen) begin
                rf[rd] <= #1 wbdata;
            end
        end
    end

    /* Debug wire */
    wire [31:0] db_r0 = rf[0];
    wire [31:0] db_r1 = rf[1];
    wire [31:0] db_r2 = rf[2];
    wire [31:0] db_r3 = rf[3];
    wire [31:0] db_r4 = rf[4];



endmodule