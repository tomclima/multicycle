module Div(
    input wire clk,
    input wire [31:0] Divsrca,   // Dividend
    input wire [31:0] Divsrcb,   // Divisor
    input wire doDiv,            // Control signal to perform division
    output reg [31:0] DivHI,     // Remainder
    output reg [31:0] DivLO,     // Quotient
    output reg by_zero           // Division by zero flag
);

always @(*) begin
    if (doDiv == 1'b0) begin
        DivLO = 32'b0;
        DivHI = 32'b0;
        by_zero = 1'b0;
    end else if (Divsrcb == 32'b0) begin
        by_zero = 1'b1;         // Set division by zero flag
        DivLO = 32'b0;          // Undefined result, set to zero
        DivHI = 32'b0;
    end else begin
        by_zero = 1'b0;         // No division by zero
        DivLO = Divsrca / Divsrcb; // Quotient
        DivHI = Divsrca % Divsrcb; // Remainder
    end
end

endmodule
