module mux_regin(
    input       wire                MemWrite,
    input       wire    [31:0]      ALU_out,
    input       wire    [31:0]      Mem_reg
    output      wire    [31:0]      data_out
);


    assign data_out = selector ? ALU_out: Mem_reg;

endmodule

