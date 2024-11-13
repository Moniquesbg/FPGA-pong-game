module RAW2RGB_J(
    //--- ccd 
    input    [9:0]   iDATA,
    input            RST,
    input            VGA_CLK, 
    input            READ_Request,
    input            VGA_VS,    
    input            VGA_HS,
    input            motion_detected, // Input van bewegingsdetectie module
    
    output   [7:0]   oRed,
    output   [7:0]   oGreen,
    output   [7:0]   oBlue,
	 output   [9:0]   LEDR
);

parameter D8M_VAL_LINE_MAX  = 637; 
parameter D8M_VAL_LINE_MIN  = 3; 

//----- WIRE /REG 
wire    [9:0]    mDAT0_0;
wire    [9:0]    mDAT0_1;
wire    [9:0]    mCCD_R;
wire    [9:0]    mCCD_G; 
wire    [9:0]    mCCD_B;
wire    [10:0]   mX_Cont;
wire    [10:0]   mY_Cont;

reg [3:0] motion_counter; // Counts frames where motion is detected

// Parameters for skin color detection
parameter [7:0] threshold_min_r = 8'd100;
parameter [7:0] threshold_max_r = 8'd255;
parameter [7:0] threshold_min_g = 8'd50;
parameter [7:0] threshold_max_g = 8'd180;
parameter [7:0] threshold_min_b = 8'd20;
parameter [7:0] threshold_max_b = 8'd130;

// Detect skin color based on the RGB values
wire skin_detected = (mCCD_R[9:2] >= threshold_min_r && mCCD_R[9:2] <= threshold_max_r) &&
                     (mCCD_G[9:2] >= threshold_min_g && mCCD_G[9:2] <= threshold_max_g) &&
                     (mCCD_B[9:2] >= threshold_min_b && mCCD_B[9:2] <= threshold_max_b);

// Combine skin color detection, motion detection
wire hand_detected = skin_detected;

wire handmotion_detected = skin_detected && motion_detected;

//------Combinatie van handherkenning en bewegingsdetectie, lamp gaat aan alleen als de hand beweegt  --
assign LEDR[0] = handmotion_detected;

//------Lamp gaat aan als er beweging is in het camera beeld  --
//assign LEDR[0] = motion_detected;

//------Lamp gaat aan als de hand wordt herkend  --
//assign LEDR[0] = hand_detected;

// Assign RGB values for output based on hand detection
assign oRed   = hand_detected ? 8'hFF : 8'h00;
assign oGreen = hand_detected ? 8'hFF : 8'h00;
assign oBlue  = hand_detected ? 8'hFF : 8'h00;

// VGA_RD_COUNTER and Line_Buffer_J instantiations
VGA_RD_COUNTER  tr( 
    .VGA_CLK      (VGA_CLK     ),
    .VGA_VS       (VGA_VS      ), 
    .READ_Request (READ_Request), 
    .X_Cont       (mX_Cont      ),
    .Y_Cont       (mY_Cont      )
); 

Line_Buffer_J u0 (    
    .CCD_PIXCLK  ( VGA_CLK ),
    .mCCD_FVAL   ( VGA_VS) ,
    .mCCD_LVAL   ( VGA_HS) ,     
    .X_Cont      ( mX_Cont), 
    .mCCD_DATA   ( iDATA),
    .VGA_CLK     ( VGA_CLK), 
    .READ_Request( READ_Request),
    .VGA_VS      ( VGA_VS),    
    .READ_Cont   ( mX_Cont ),
    .V_Cont      ( mY_Cont ),
    .taps0x      ( mDAT0_0),
    .taps1x      ( mDAT0_1)
);                    

reg    RD_EN; 
always @(posedge VGA_CLK) 
    RD_EN <= ((mX_Cont > D8M_VAL_LINE_MIN) && (mX_Cont < D8M_VAL_LINE_MAX)) ? 1 : 0;         
                        
RAW_RGB_BIN bin(
    .CLK       (VGA_CLK), 
    .RESET_N   (RD_EN), 
    .D0        (mDAT0_0),
    .D1        (mDAT0_1),
    .X         (mX_Cont[0]),
    .Y         (mY_Cont[0]),
    .R         (mCCD_R),
    .G         (mCCD_G), 
    .B         (mCCD_B)
); 

endmodule
