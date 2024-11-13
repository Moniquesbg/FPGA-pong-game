module RedBorder(
    input [7:0] pixel_in,      // Ingangspixel (grijswaarden of kleur)
    input [10:0] x,            // Huidige X-coördinaat
    input [10:0] y,            // Huidige Y-coördinaat
    input [10:0] hand_x_min,   // Minimale X-coördinaat van de hand
    input [10:0] hand_x_max,   // Maximale X-coördinaat van de hand
    input [10:0] hand_y_min,   // Minimale Y-coördinaat van de hand
    input [10:0] hand_y_max,   // Maximale Y-coördinaat van de hand
    output reg [7:0] pixel_out // Uitgangspixel (rood indien binnen rand)
);
    always @(*) begin
        if ((x == hand_x_min || x == hand_x_max || y == hand_y_min || y == hand_y_max) && 
            (x >= hand_x_min && x <= hand_x_max) &&
            (y >= hand_y_min && y <= hand_y_max)) begin
            pixel_out = 8'hFF; // Rood voor rand
        end else begin
            pixel_out = pixel_in; // Ongewijzigde pixel
        end
    end
endmodule
