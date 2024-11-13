module ContourDetection(
    input [7:0] pixel_in,       // Pixel input from the previous stage (e.g., edge detection)
    input VGA_CLK,              // VGA Clock
    input RST,                  // Reset signal
    output reg [7:0] contour_out // Output to the VGA controller
);

    // Buffer to store pixels for comparison (3x3 matrix)
    reg [7:0] frame_buffer [0:2][0:2];
    reg [7:0] edge_in; // Register to hold the current pixel value

    // Contour area threshold for filtering
    parameter MIN_CONTOUR_SIZE = 5; // Minimum number of contour pixels needed (adjust as needed)

    // Variables to track contour pixel count
    reg [3:0] contour_pixel_count; // Count of pixels in the detected contour

    integer i, j;

    always @(posedge VGA_CLK or posedge RST) begin
        if (RST) begin
            // Initialize the buffer to zero (black)
            for (i = 0; i < 3; i = i + 1) begin
                for (j = 0; j < 3; j = j + 1) begin
                    frame_buffer[i][j] <= 8'h00; // Set to black
                end
            end
            edge_in <= 8'h00; // Set to black
            contour_out <= 8'h00; // Set background color to black
            contour_pixel_count <= 4'h0; // Reset pixel count
        end else begin
            // Update edge_in with the current pixel value
            edge_in <= pixel_in;

            // Shift pixels in the buffer horizontally and vertically
            for (i = 0; i < 2; i = i + 1) begin
                for (j = 0; j < 3; j = j + 1) begin
                    frame_buffer[i][j] <= frame_buffer[i+1][j];
                end
            end

            for (j = 0; j < 2; j = j + 1) begin
                frame_buffer[2][j] <= frame_buffer[2][j+1];
            end
            frame_buffer[2][2] <= edge_in;

            // Initialize the pixel count for the current frame
            contour_pixel_count = 4'h0;

            // Count the number of non-zero pixels in the 3x3 window
            for (i = 0; i < 3; i = i + 1) begin
                for (j = 0; j < 3; j = j + 1) begin
                    if (frame_buffer[i][j] > 8'h00) begin
                        contour_pixel_count = contour_pixel_count + 1;
                    end
                end
            end

            // Enhanced contour detection
            if (contour_pixel_count >= MIN_CONTOUR_SIZE) begin
                // Check if the center pixel is surrounded by at least some non-zero pixels
                if ((frame_buffer[1][1] > 8'h00) &&
                    ((frame_buffer[0][1] > 8'h00 || frame_buffer[2][1] > 8'h00 || 
                      frame_buffer[1][0] > 8'h00 || frame_buffer[1][2] > 8'h00))) begin
                    contour_out <= 8'hFF; // Set contour to white
                end else begin
                    contour_out <= 8'h00; // Set background to black
                end
            end else begin
                contour_out <= 8'h00; // Set background to black
            end
        end
    end

endmodule
