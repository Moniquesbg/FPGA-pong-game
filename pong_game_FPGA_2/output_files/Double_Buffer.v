module Double_Buffer(
    input wire clk,                  // Kloksignaal
    input wire reset,                // Reset signaal
    input wire [7:0] iRed,           // Inkomende rood component
    input wire [7:0] iGreen,         // Inkomende groen component
    input wire [7:0] iBlue,          // Inkomende blauw component
    input wire [9:0] iX,             // X-coördinaat voor schrijven
    input wire [9:0] iY,             // Y-coördinaat voor schrijven
    input wire write_enable,         // Schrijf-enable signaal
    input wire read_buffer_select,   // Selectie van buffer om te lezen
    output reg [7:0] oRed,           // Uitgang rood component
    output reg [7:0] oGreen,         // Uitgang groen component
    output reg [7:0] oBlue,          // Uitgang blauw component
    input wire [9:0] vgaX,           // X-coördinaat voor lezen
    input wire [9:0] vgaY            // Y-coördinaat voor lezen
);

    // Definieer twee framebuffers
    reg [7:0] buffer0_red [0:479][0:639];
    reg [7:0] buffer0_green [0:479][0:639];
    reg [7:0] buffer0_blue [0:479][0:639];
    reg [7:0] buffer1_red [0:479][0:639];
    reg [7:0] buffer1_green [0:479][0:639];
    reg [7:0] buffer1_blue [0:479][0:639];

    // Schrijf naar de geselecteerde buffer
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset logica: Initialiseer beide buffers naar zwart (0)
            integer i, j;
            for (i = 0; i < 480; i = i + 1) begin
                for (j = 0; j < 640; j = j + 1) begin
                    buffer0_red[i][j] <= 8'd0;
                    buffer0_green[i][j] <= 8'd0;
                    buffer0_blue[i][j] <= 8'd0;
                    buffer1_red[i][j] <= 8'd0;
                    buffer1_green[i][j] <= 8'd0;
                    buffer1_blue[i][j] <= 8'd0;
                end
            end
        end else if (write_enable) begin
            if (read_buffer_select) begin
                // Schrijf naar buffer1
                buffer1_red[iY][iX] <= iRed;
                buffer1_green[iY][iX] <= iGreen;
                buffer1_blue[iY][iX] <= iBlue;
            end else begin
                // Schrijf naar buffer0
                buffer0_red[iY][iX] <= iRed;
                buffer0_green[iY][iX] <= iGreen;
                buffer0_blue[iY][iX] <= iBlue;
            end
        end
    end

    // Lees uit de geselecteerde buffer
    always @(*) begin
        if (read_buffer_select) begin
            // Lees uit buffer1
            oRed = buffer1_red[vgaY][vgaX];
            oGreen = buffer1_green[vgaY][vgaX];
            oBlue = buffer1_blue[vgaY][vgaX];
        end else begin
            // Lees uit buffer0
            oRed = buffer0_red[vgaY][vgaX];
            oGreen = buffer0_green[vgaY][vgaX];
            oBlue = buffer0_blue[vgaY][vgaX];
        end
    end
endmodule
