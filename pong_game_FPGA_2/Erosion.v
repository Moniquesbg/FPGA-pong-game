module Erosion(
    input wire [9:0] p00, // Pixel 0,0
    input wire [9:0] p01, // Pixel 0,1
    input wire [9:0] p02, // Pixel 0,2
    input wire [9:0] p10, // Pixel 1,0
    input wire [9:0] p11, // Pixel 1,1
    input wire [9:0] p12, // Pixel 1,2
    input wire [9:0] p20, // Pixel 2,0
    input wire [9:0] p21, // Pixel 2,1
    input wire [9:0] p22, // Pixel 2,2
    output reg [9:0] result
);
    always @* begin
        result = p00;
        if (p01 < result) result = p01;
        if (p02 < result) result = p02;
        if (p10 < result) result = p10;
        if (p11 < result) result = p11;
        if (p12 < result) result = p12;
        if (p20 < result) result = p20;
        if (p21 < result) result = p21;
        if (p22 < result) result = p22;
    end
endmodule
