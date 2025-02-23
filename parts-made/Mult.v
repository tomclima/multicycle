module Mult(
    input wire [31:0] MultSrc1,
    input wire [31:0] MultSrc2,
    output wire Over,
    output wire [31:0] MultHI,
    output wire [31:0] MultLO
);

    wire [63:0] product;

    assign product = $signed(MultSrc1) * $signed(MultSrc2);

    assign MultLO = product[31:0];

    assign MultHI = product[63:32];

    assign Over = (MultHI != 32'b0 && MultHI != 32'b11111111111111111111111111111111);

endmodule
