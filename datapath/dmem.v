module dmem (
    input reset,
    input clk,
    input enable,       //dmem_vaild
    input rnw,          //dmem_fcn
    input [31:0] addr,  //alu_out
    input [31:0] wdata,
    output [31:0] rdata,
    output status
    );

reg [31:0] mem [1023:0];
wire [10:0] index;

assign status = 2'b1;

assign index = addr>>2;
assign rdata = (enable & rnw) ? mem[index]: 32'hx;

always @(posedge clk) begin
    if(reset) begin
        mem[0] <= #1 {32'hffff};
        mem[1] <= #1 {32'habcd};
        mem[2] <= #1 {32'h2222};
        mem[3] <= #1 {32'hfdfd};
        mem[4] <= #1 {32'h1111};
        mem[5] <= #1 {32'h3333};
        mem[6] <= #1 {32'h4444};
        mem[7] <= #1 {32'h7777};
        mem[8] <= #1 {32'h8888};
        mem[9] <= #1 {32'h9999};
        mem[10] <= #1 {32'h0};
        mem[11] <= #1 {32'h0};
    end 
    else begin
        if(enable & !rnw) mem[index] <= wdata;
    end
end

    /* Debug wire */
    wire [31:0] db_r0 = mem[0];
    wire [31:0] db_r1 = mem[1];
    wire [31:0] db_r2 = mem[2];
    wire [31:0] db_r3 = mem[3];
    wire [31:0] db_r4 = mem[4];


endmodule