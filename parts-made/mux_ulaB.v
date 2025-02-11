module mux_aluB(
    input wire      [3:0]       selector;
    input wire      [31:0]      data_0;
    input wire      [31:0]      data_2;
    input wire      [31:0]      data_3;
    output wire     [31:0]      data_out;
);

assign data_out = (selector == 0)*(data_0) + (selector == 1)*(4) + (selector == 2)*(data_2) + (selector == 3)*(data+3);

endmodule