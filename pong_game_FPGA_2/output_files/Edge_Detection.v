module Edge_Detection(
    input wire clk,
    input wire rst,
    input wire [9:0] mCCD_R,
    input wire [9:0] mCCD_G,
    input wire [9:0] mCCD_B,
    output reg edge_detected
);

    // Parameters for Sobel filters
    parameter signed SOBEL_X0 = 1, SOBEL_X1 = 0, SOBEL_X2 = -1;
    parameter signed SOBEL_X3 = 1, SOBEL_X4 = 0, SOBEL_X5 = -1;
    parameter signed SOBEL_X6 = 1, SOBEL_X7 = 0, SOBEL_X8 = -1;

    parameter signed SOBEL_Y0 = 1, SOBEL_Y1 = 1, SOBEL_Y2 = 1;
    parameter signed SOBEL_Y3 = 0, SOBEL_Y4 = 0, SOBEL_Y5 = 0;
    parameter signed SOBEL_Y6 = -1, SOBEL_Y7 = -1, SOBEL_Y8 = -1;

    // Intermediate registers for gradients
    reg signed [15:0] Gx, Gy;
    reg signed [15:0] magnitude;

    // Calculate gradients using Sobel filters
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Gx <= 0;
            Gy <= 0;
            edge_detected <= 0;
        end else begin
            // Apply Sobel filter to calculate Gx and Gy
            Gx <= (SOBEL_X0 * mCCD_R + SOBEL_X1 * mCCD_R + SOBEL_X2 * mCCD_R +
                   SOBEL_X3 * mCCD_R + SOBEL_X4 * mCCD_R + SOBEL_X5 * mCCD_R +
                   SOBEL_X6 * mCCD_R + SOBEL_X7 * mCCD_R + SOBEL_X8 * mCCD_R);

            Gy <= (SOBEL_Y0 * mCCD_G + SOBEL_Y1 * mCCD_G + SOBEL_Y2 * mCCD_G +
                   SOBEL_Y3 * mCCD_G + SOBEL_Y4 * mCCD_G + SOBEL_Y5 * mCCD_G +
                   SOBEL_Y6 * mCCD_G + SOBEL_Y7 * mCCD_G + SOBEL_Y8 * mCCD_G);

            // Compute the magnitude of the gradient
            magnitude <= Gx * Gx + Gy * Gy;
            edge_detected <= (magnitude > 16'd10000); // Adjust threshold as needed
        end
    end

endmodule
