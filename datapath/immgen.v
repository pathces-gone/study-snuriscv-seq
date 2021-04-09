module immgen(
    input [11:0] imm12,
    output [31:0] immgen
);

    assign immgen = $signed(imm12);

endmodule