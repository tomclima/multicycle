module sign_ext_31b(
    input       wire        [0:0]       data_0,
    output      wire        [31:0]      data_out
);

    assign data_out = {{31'b0}, data_0};

endmodule 