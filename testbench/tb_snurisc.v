module tb_snurisc;
    reg reset, clk;

    initial clk =0;
    always #50 clk = !clk;
    
    initial begin
        $vcdplusfile;
        $vcdpluson;
    end

    initial begin
        reset = 1;
        #200
        reset = 0;

        #2000
        $finish;
    end

    snurisc dut(
        .reset(reset),
        .clk(clk)
        );

endmodule