module FrameBuffer(
    input [7:0] pixel_in,
    input VGA_CLK,
    input RST,
    input write_enable,
    input [11:0] address, // 12-bit address for 640x480 resolution
    output reg [7:0] pixel_out
);

    // Declare memory for storing the frame
    reg [7:0] frame_memory [0:307199]; // For 640x480 resolution

    // Process for handling read and write operations
    always @(posedge VGA_CLK or posedge RST) begin
        if (RST) begin
            // Use a synchronous reset or initialize in another way
            pixel_out <= 8'h00;
        end else if (write_enable) begin
            // Write pixel data to the frame buffer
            frame_memory[address] <= pixel_in;
        end else begin
            // Read pixel data from the frame buffer
            pixel_out <= frame_memory[address];
        end
    end
endmodule
