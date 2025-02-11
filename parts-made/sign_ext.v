module sign_ext_16b(
    input       wire        [15:0]      data_0,
    output      wire        [31:0]      data_out
);

    assign data_out = data_0[15] ? {{16'b1}, data_0} : {{16'b0}, data_0};

endmodule 