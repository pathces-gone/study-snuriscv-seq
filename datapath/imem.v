module imem (
    input reset,
    input clk,
    input memrq,
    input rnw,
    input [31:0] pc,
    inout [31:0] data
);

reg [31:0] mem [1023:0];
wire [10:0] index;

assign index = pc>>2;
assign data = (memrq & rnw) ? mem[index]: 32'hx;


/*
    addi
    lw
    sw
    add
    beq

    nop = addi x0,x0,0
*/
always @(posedge clk) begin
    if(reset) begin // op rd, r1, r2
        mem[0] <= #1 {7'b0000000,5'b01000,5'b00000,3'b000,5'b00001,`I_FORMAT}; 
        // addi t1, zero, 8
        mem[1] <= #1 {7'b0000000,5'b00000,5'b00001,3'b000,5'b00011,`I2_FORMAT};
        // lw t3,0(t1) //t3=0x2222
        mem[2] <= #1 {7'b0000000,5'b00100,5'b00000,3'b000,5'b00001,`I_FORMAT}; 
        // addi t1, zero, 4
        mem[3] <= #1 {7'b0000000,5'b00011,5'b00000,3'b000,5'b00100,`S_FORMAT}; 
        // sw t3,4(t0)
        mem[4] <= #1 {7'b0000000,5'b00000,5'b00001,3'b000,5'b00100,`I2_FORMAT};
        // lw t4,0(t1)

        mem[5] <= #1 {7'b0000000,5'b00000,5'b00000,3'b000,5'b00000,`I_FORMAT};
        // nop
        mem[6] <= #1 {7'b0000000,5'b00100,5'b00000,3'b000,5'b00001,`I_FORMAT}; 
        // addi t1,zero,4
        mem[7] <= #1 {7'b0000000,5'b00100,5'b00000,3'b000,5'b00010,`I_FORMAT}; 
        // addi t2,zero,4
        mem[8] <= #1 {7'b0010000,5'b00010,5'b00001,3'b000,5'b00000,`SB_FORMAT}; ;
        // beq t1,t2,256
        mem[9] <= #1 {32'h0};
        mem[10] <= #1 {32'h0};
        mem[11] <= #1 {32'h0};

        mem[72] <= #1 {7'b0000000,5'b01111,5'b00000,3'b000,5'b00011,`I_FORMAT}; 
        // addi t3,zero,0xf
    end
    else begin
        if(memrq & !rnw) mem[index] <= data;        
    end
end

endmodule