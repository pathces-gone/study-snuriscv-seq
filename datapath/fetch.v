module fetch(
    input clk,    
    input reset,
    input [31:0] pc,
    output [31:0] data,
    output status
);

    assign status = 2'b0;
    imem icache(.reset(reset), .clk(clk), .memrq(1'b1), .rnw(1'b1), .pc(pc), .data(data));

endmodule