module EdgeDetection(
    input [7:0] pixel_in,       // Huidige pixelwaarde
    input [7:0] prev_pixel,     // Pixel boven de huidige pixel
    input [7:0] next_pixel,     // Pixel onder de huidige pixel
    input VGA_CLK,
    input RST,
    output reg [7:0] edge_out   // Uitgang voor de gedetecteerde rand
);

    // Registers voor opslag van de gradienten
    reg signed [15:0] gradient_x;
    reg signed [15:0] gradient_y;
    reg signed [15:0] gradient_magnitude;

    always @(posedge VGA_CLK or posedge RST) begin
        if (RST) begin
            gradient_x <= 0;
            gradient_y <= 0;
            gradient_magnitude <= 0;
            edge_out <= 0;
        end else begin
            // Sobel kernel waarden (voor X en Y gradienten)
            // Kernel waarden voor de X-gradient
            gradient_x <= (prev_pixel - next_pixel) * 2;
            
            // Kernel waarden voor de Y-gradient
            gradient_y <= (prev_pixel - 2 * pixel_in + next_pixel);

            // Bereken de magnitude van de gradient
            gradient_magnitude <= (gradient_x > gradient_y) ? gradient_x : gradient_y;

            // Gebruik een drempelwaarde voor edge detectie
            edge_out <= (gradient_magnitude > 8'h80) ? 8'hFF : 8'h00; // 8'h80 is een voorbeeld drempelwaarde
        end
    end
endmodule
