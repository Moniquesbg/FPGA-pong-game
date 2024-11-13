module FrameDifferencing_RAW (
    input [9:0] currFrame_RAW,   // Huidige frame data (RAW)
    input [9:0] prevFrame_RAW,   // Vorige frame data (RAW)
    output reg motion_detected  // Output: 1 als er beweging is
);

    parameter MOTION_THRESHOLD = 10'd400; // Maximale drempel voor beweging

    wire [9:0] difference;

    // Bereken het verschil tussen de huidige frame en de vorige frame
    assign difference = (currFrame_RAW > prevFrame_RAW) ? (currFrame_RAW - prevFrame_RAW) : (prevFrame_RAW - currFrame_RAW);

    always @(*) begin
        // Beweging detecteren op basis van het verschil
        if (difference > MOTION_THRESHOLD) begin
            motion_detected = 1; // Beweging gedetecteerd
        end else begin
            motion_detected = 0; // Geen beweging gedetecteerd
        end
    end

endmodule
