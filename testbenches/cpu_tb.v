`timescale 1ns / 1ps

module cpu_tb;
    reg clk;
    reg reset;

    cpu uut (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk; 

        clk = 0;
        reset = 1;
        
        #10 reset = 0;

        #500 $stop;
endmodule
