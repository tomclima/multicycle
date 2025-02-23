module sign_ext_16b(
    input       wire        [15:0]      data_0,
    output      wire        [31:0]      data_out
);

    assign data_out = {{16{data_0[15]}}, data_0[15:0]};

endmodule 