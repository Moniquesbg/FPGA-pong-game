module HandMasking(
    input wire VGA_CLK,
    input wire RST,
    input wire [7:0] pixel_in,   // Ingangspixelwaarde van de afbeelding (niet meer gebruikt voor de hand)
    input wire [10:0] hand_x,    // X-coördinaat van de hand
    input wire [10:0] hand_y,    // Y-coördinaat van de hand
    input wire [10:0] hand_width,  // Variabele breedte van de handregio
    input wire [10:0] hand_height, // Variabele hoogte van de handregio
    input wire hand_detected,    // Vlag die aangeeft of de hand gedetecteerd is
    input wire [12:0] VGA_H_CNT, // Horizontale telling van de VGA-controller
    input wire [12:3] VGA_V_CNT, // Verticale telling van de VGA-controller
    output reg [7:0] pixel_out   // Uitgangspixelwaarde na maskering
);

    always @(posedge VGA_CLK or posedge RST) begin
        if (RST) begin
            pixel_out <= 8'd0; // Reset naar zwart
        end else if (hand_detected) begin
            // Controleer of de huidige pixel binnen de handregio valt
            if ((VGA_H_CNT >= hand_x) && (VGA_H_CNT < (hand_x + hand_width)) &&
                (VGA_V_CNT >= hand_y) && (VGA_V_CNT < (hand_y + hand_height))) begin
                pixel_out <= 8'd255;  // Zet de hand op wit
            end else begin
                pixel_out <= 8'd0;    // Zet de rest van het scherm op zwart
            end
        end else begin
            pixel_out <= 8'd0;        // Zet alles op zwart als de hand niet gedetecteerd is
        end
    end

endmodule
