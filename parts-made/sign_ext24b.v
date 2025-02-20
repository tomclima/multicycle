module sign_ext_24b(
    input       wire        [7:0]      data_0,
    output      wire        [31:0]      data_out
);

    assign data_out = data_0[7] ? {{24'b1}, data_0} : {{24'b0}, data_0};

endmodule 