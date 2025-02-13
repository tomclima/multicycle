module shiftleft2 (
    input   wire    [31:0]      ext,
    output  wire    [31:0]      out
);

assign out = ext << 2;
    
endmodule