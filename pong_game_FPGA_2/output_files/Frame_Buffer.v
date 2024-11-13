module Frame_Buffer(
    input wire clk,                // Clock signal
    input wire reset,              // Reset signal
    input wire [7:0] iRed,         // Incoming red component from RAW2RGB
    input wire [7:0] iGreen,       // Incoming green component from RAW2RGB
    input wire [7:0] iBlue,        // Incoming blue component from RAW2RGB
    input wire [9:0] iX,           // X-coordinate from VGA controller (for framebuffer write)
    input wire [9:0] iY,           // Y-coordinate from VGA controller (for framebuffer write)
    input wire frame_write_enable, // Frame write enable signal
    output reg [7:0] oRed,         // Output red component to VGA controller
    output reg [7:0] oGreen,       // Output green component to VGA controller
    output reg [7:0] oBlue,        // Output blue component to VGA controller
    input wire [9:0] vgaX,         // X-coordinate for VGA display (for framebuffer read)
    input wire [9:0] vgaY          // Y-coordinate for VGA display (for framebuffer read)
);

    // Define a memory array for the framebuffer
    reg [23:0] pixelMem [0:479][0:639];  // 640x480 resolution, 24-bit pixel

    // Write data to framebuffer (based on incoming camera values)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset logic
            oRed <= 8'd0;
            oGreen <= 8'd0;
            oBlue <= 8'd0;
        end else begin
            if (frame_write_enable) begin
                // Combine RGB components into a single 24-bit value
                pixelMem[iY][iX] <= {iRed, iGreen, iBlue};
            end
            // Provide the pixel data to VGA output (based on VGA coordinates)
            {oRed, oGreen, oBlue} <= pixelMem[vgaY][vgaX];
        end
    end
endmodule
