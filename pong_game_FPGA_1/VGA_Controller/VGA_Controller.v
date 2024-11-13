module VGA_Controller(
    input               iCLK,
    input               iRST_N,
    input       [7:0]   iRed,
    input       [7:0]   iGreen,
    input       [7:0]   iBlue,
    input       [11:0]  hand_x_min,  // Input for hand bounding box coordinates
    input       [11:0]  hand_x_max,
    input       [11:0]  hand_y_min,
    input       [11:0]  hand_y_max,
    output              oRequest,
    output      [7:0]   oVGA_R,
    output      [7:0]   oVGA_G,
    output      [7:0]   oVGA_B,
    output              oVGA_H_SYNC,
    output              oVGA_V_SYNC,
    output              oVGA_SYNC,
    output              oVGA_BLANK,
    output reg  [12:0]  H_Cont,
    output reg  [12:0]  V_Cont
);

//=======================================================
// REG/WIRE declarations
//=======================================================
parameter H_MARK   = 17; // These should be adjusted based on actual VGA parameters
parameter H_MARK1  = 10;
parameter V_MARK   = 9;
parameter BORDER_THICKNESS = 8; // Define the border thickness here
`include "VGA_Param.h"

//=======================================================
// Structural coding
//=======================================================

// Horizontal counter
always @(posedge iCLK or negedge iRST_N) begin
    if (!iRST_N)
        H_Cont <= 0;
    else
        H_Cont <= (H_Cont < H_SYNC_TOTAL) ? H_Cont + 1 : 0;
end

// Vertical counter
always @(posedge iCLK or negedge iRST_N) begin
    if (!iRST_N)
        V_Cont <= 0;
    else if (H_Cont == 0)
        V_Cont <= (V_Cont < V_SYNC_TOTAL) ? V_Cont + 1 : 0;
end

// VGA sync and blanking signals
assign oVGA_BLANK = ~((H_Cont < H_BLANK) || (V_Cont < V_BLANK));
assign oVGA_H_SYNC = ((H_Cont > (H_SYNC_FRONT - H_MARK1)) && (H_Cont <= (H_SYNC_CYC + H_SYNC_FRONT - H_MARK1))) ? 0 : 1;
assign oVGA_V_SYNC = ((V_Cont > (V_SYNC_FRONT)) && (V_Cont <= (V_SYNC_CYC + V_SYNC_FRONT))) ? 0 : 1;
assign oVGA_SYNC = 1'b0;

// Determine if the current pixel is within the border region
wire is_in_border = (
    (H_Cont >= hand_x_min - BORDER_THICKNESS && H_Cont <= hand_x_max + BORDER_THICKNESS && 
     (V_Cont < hand_y_min || V_Cont > hand_y_max)) ||
    (V_Cont >= hand_y_min - BORDER_THICKNESS && V_Cont <= hand_y_max + BORDER_THICKNESS && 
     (H_Cont < hand_x_min || H_Cont > hand_x_max))
);

// Request signal to determine if we are in the display area
assign oRequest = (H_Cont >= X_START && H_Cont < X_START + 640 && // Adjust if necessary
                   V_Cont >= Y_START && V_Cont < Y_START + 480) ? 1 : 0;

// Output pixel color based on whether it's inside the border
assign oVGA_R = oVGA_BLANK ? (is_in_border ? 8'hFF : iRed) : 0;
assign oVGA_G = oVGA_BLANK ? (is_in_border ? 8'h00 : iGreen) : 0;
assign oVGA_B = oVGA_BLANK ? (is_in_border ? 8'h00 : iBlue) : 0;

endmodule
