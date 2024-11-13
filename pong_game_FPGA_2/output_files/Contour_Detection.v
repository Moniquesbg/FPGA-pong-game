module Contour_Detection(
    input wire clk,
    input wire rst,
    input wire [9:0] iRed,    // Incoming red components from edge detection
    input wire [9:0] iGreen,  // Incoming green components from edge detection
    input wire [9:0] iBlue,   // Incoming blue components from edge detection
    output reg [9:0] oContour // Single output for contour detection
);

    // Internal signals
    reg [9:0] buffer [0:2][0:2];  // 3x3 buffer for pixels
    integer i, j;

    // Buffer update and contour detection
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset buffer
            for (i = 0; i < 3; i = i + 1) begin
                for (j = 0; j < 3; j = j + 1) begin
                    buffer[i][j] <= 0;
                end
            end
            oContour <= 0;
        end else begin
            // Shift buffer
            for (i = 0; i < 2; i = i + 1) begin
                for (j = 0; j < 3; j = j + 1) begin
                    buffer[i][j] <= buffer[i+1][j];
                end
            end
            for (j = 0; j < 2; j = j + 1) begin
                buffer[2][j] <= buffer[2][j+1];
            end
            buffer[2][2] <= {iRed, iGreen, iBlue};

            // Contour detection: Basic check if a pixel is on an edge
            if (buffer[1][1] == 10'b1 && (buffer[0][1] == 10'b1 || buffer[2][1] == 10'b1 || buffer[1][0] == 10'b1 || buffer[1][2] == 10'b1)) begin
                oContour <= 10'd255; // Set color to indicate part of contour
            end else begin
                oContour <= 10'd0;   // No contour
            end
        end
    end

endmodule
