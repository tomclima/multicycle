module Div(
    input wire [31:0] Divsrca,            
    input wire [31:0] Divsrcb,            
    output wire [31:0] DivHI,   
    output wire [31:0] DivLO,      
    output wire by_zero             
);

    reg [31:0] quotient;
    reg [31:0] rem;
    reg div_by_zero;

    always @(*) begin
        if (b == 32'b0) begin
            div_by_zero = 1'b1;
            quotient = 32'b0;
            rem = a; 
        end else begin
            div_by_zero = 1'b0;
            quotient = a / b;
            rem = a % b;
        end
    end


    assign result = quotient;
    assign remainder = rem;
    assign by_zero = div_by_zero;

endmodule
