module SquareMasking(
    input wire VGA_CLK,
    input wire RST,
    input wire [7:0] pixel_in,   // Ingangspixelwaarde van de afbeelding
    input wire [10:0] square_x,  // X-coördinaat van het vierkant
    input wire [10:0] square_y,  // Y-coördinaat van het vierkant
    input wire [10:0] square_size,  // Grootte van het vierkant (gelijk aan breedte en hoogte)
    input wire square_detected,  // Vlag die aangeeft of het vierkant gedetecteerd is
    input wire [12:0] VGA_H_CNT, // Horizontale telling van de VGA-controller
    input wire [12:3] VGA_V_CNT, // Verticale telling van de VGA-controller
    output reg [7:0] pixel_out   // Uitgangspixelwaarde na maskering
);

    always @(posedge VGA_CLK or posedge RST) begin
        if (RST) begin
            pixel_out <= 8'd0; // Reset naar zwart
        end else if (square_detected) begin
            // Controleer of de huidige pixel binnen het vierkant valt
            if ((VGA_H_CNT >= square_x) && (VGA_H_CNT < (square_x + square_size)) &&
                (VGA_V_CNT >= square_y) && (VGA_V_CNT < (square_y + square_size))) begin
                pixel_out <= 8'd255;  // Zet het vierkant op wit
            end else begin
                pixel_out <= pixel_in; // Laat andere pixels onveranderd
            end
        end else begin
            pixel_out <= pixel_in; // Laat alles onveranderd als het vierkant niet gedetecteerd is
        end
    end

endmodule
