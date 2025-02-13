module jump_Shiftleft2(
    input wire [25:0] offset,
    input wire [3:0] PCjump,
    output wire [31:0] out,
);
    wire   [27:0]   shifted;
    assign shifted = {{2'b00}, offset} << 2;
    assign out = {PCjump, shifted};

endmodule