module pcgen (
    input clk, 
    input reset,
    input [1:0] pc_sel,
    input [31:0] jump_reg_target,
    input [31:0] brjmp_target,
    output [31:0] npc,
    output [31:0] add_pc
);

    reg [31:0] pc0;

    wire [1:0]  s;
    wire [31:0] out;

    assign add_pc = pc0 + 4;
    assign npc = pc0;

    assign out = (pc_sel == 2'b10) ? add_pc :
                 (pc_sel == 2'b01) ? brjmp_target:
                 jump_reg_target; 

    always @(posedge clk) begin
        if (reset)begin
            pc0 <= #1 -4;
        end
        else begin
            pc0 <= #1 out;
        end
    end
endmodule