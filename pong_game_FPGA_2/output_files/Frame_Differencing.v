module Frame_Differencing(
    input wire clk,             // Clock signal
    input wire reset,           // Reset signal
    input wire [7:0] iRed,      // Current frame Red channel from RAW2RGB
    input wire [7:0] iGreen,    // Current frame Green channel from RAW2RGB
    input wire [7:0] iBlue,     // Current frame Blue channel from RAW2RGB
    input wire [7:0] prevRed,   // Previous frame Red channel
    input wire [7:0] prevGreen, // Previous frame Green channel
    input wire [7:0] prevBlue,  // Previous frame Blue channel
    output reg motion_detected   // Output indicating if motion is detected
);

    reg [7:0] diffRed, diffGreen, diffBlue;
    parameter [7:0] THRESHOLD = 8'd20; // Threshold for motion detection

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            motion_detected <= 0;
        end else begin
            // Calculate the difference between current and previous frame values
            diffRed = (iRed > prevRed) ? (iRed - prevRed) : (prevRed - iRed);
            diffGreen = (iGreen > prevGreen) ? (iGreen - prevGreen) : (prevGreen - iGreen);
            diffBlue = (iBlue > prevBlue) ? (iBlue - prevBlue) : (prevBlue - iBlue);

            // Detect motion if any of the differences exceed the threshold
            if (diffRed > THRESHOLD || diffGreen > THRESHOLD || diffBlue > THRESHOLD) begin
                motion_detected <= 1;
            end else begin
                motion_detected <= 0;
            end
        end
    end
endmodule
