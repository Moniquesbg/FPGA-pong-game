module PixelBuffer(
    input [7:0] current_pixel,
    input VGA_CLK,
    input RST,
    output reg [7:0] prev_pixel,
    output reg [7:0] next_pixel
);

    reg [7:0] buffer [0:2]; // Buffer om vorige en huidige pixels op te slaan

    always @(posedge VGA_CLK or posedge RST) begin
        if (RST) begin
            buffer[0] <= 0;
            buffer[1] <= 0;
            buffer[2] <= 0;
            prev_pixel <= 0;
            next_pixel <= 0;
        end else begin
            buffer[0] <= buffer[1]; // Oude pixel wordt de vorige pixel
            buffer[1] <= buffer[2]; // Huidige pixel wordt de vorige pixel
            buffer[2] <= current_pixel; // Nieuwe pixel wordt de huidige pixel
            
            prev_pixel <= buffer[0];
            next_pixel <= buffer[2];
        end
    end
endmodule
