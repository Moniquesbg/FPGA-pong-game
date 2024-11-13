module HandColorDetection (
    input [7:0] iRed,
    input [7:0] iGreen,
    input [7:0] iBlue,
    input [7:0] handRed,
    input [7:0] handGreen,
    input [7:0] handBlue,
    input [7:0] iContour,
    output reg [7:0] oRed,
    output reg [7:0] oGreen,
    output reg [7:0] oBlue
);

always @(*) begin
    if (iContour > 0) begin
        // Inside detected contour
        if ((iRed >= handRed - 10) && (iRed <= handRed + 10) &&
            (iGreen >= handGreen - 10) && (iGreen <= handGreen + 10) &&
            (iBlue >= handBlue - 10) && (iBlue <= handBlue + 10)) begin
            oRed = 8'hFF;  // Red color
            oGreen = 8'h00;
            oBlue = 8'h00;
        end else begin
            oRed = 8'h00;  // Black color
            oGreen = 8'h00;
            oBlue = 8'h00;
        end
    end else begin
        oRed = 8'h00;  // Black color
        oGreen = 8'h00;
        oBlue = 8'h00;
    end
end

endmodule
