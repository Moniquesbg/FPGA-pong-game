module VGA_Controller(
    input               iCLK,
    input               iRST_N,
    input       [7:0]   iRed,
    input       [7:0]   iGreen,
    input       [7:0]   iBlue,
    output              oRequest,
    output      [7:0]   oVGA_R,
    output      [7:0]   oVGA_G,
    output      [7:0]   oVGA_B,
    output              oVGA_H_SYNC,
    output              oVGA_V_SYNC,
    output              oVGA_SYNC,
    output              oVGA_BLANK,
    output  reg [12:0]  H_Cont,
    output  reg [12:3]  V_Cont                      
);

//=======================================================
// declarations
//=======================================================
parameter H_MARK   = 17; // MAX 17
parameter H_MARK1  = 10; // MAX 10
parameter V_MARK   = 9;  // MAX 9

// Horizontal Parameter 
parameter H_SYNC_CYC   = 96;
parameter H_SYNC_BACK  = 48;
parameter H_SYNC_ACT   = 640; 
parameter H_SYNC_FRONT = 16;
parameter H_SYNC_TOTAL = 800;

parameter V_SYNC_CYC   = 2;
parameter V_SYNC_BACK  = 33;
parameter V_SYNC_ACT   = 480; 
parameter V_SYNC_FRONT = 10;
parameter V_SYNC_TOTAL = 525;

// Horizontal Parameter for drawing
parameter hori_back = 144;    // Horizontal back porch
parameter vert_back = 34;     // Vertical back porch

// Start Offset
parameter X_START      = H_SYNC_CYC + H_SYNC_BACK;
parameter Y_START      = V_SYNC_CYC + V_SYNC_BACK;
parameter H_BLANK      = H_SYNC_FRONT + H_SYNC_CYC + H_SYNC_BACK;
parameter V_BLANK      = V_SYNC_FRONT + V_SYNC_CYC + V_SYNC_BACK;

// Position middle line
parameter LINE_OFFSET  = 145; 

// Parameters for the right paddle
parameter PADDLE_WIDTH      = 20; // Width of the paddle
parameter PADDLE_HEIGHT     = 80; // Height of the paddle
parameter PADDLE_X          = 744; // X-position of the paddle 
parameter PADDLE_Y          = 244; 
parameter PADDLE_COLOR_R    = 8'hFF; // Red component of the paddle color
parameter PADDLE_COLOR_G    = 8'hFF; // Green component of the paddle color
parameter PADDLE_COLOR_B    = 8'hFF; // Blue component of the paddle color

// Parameters for the left paddle
parameter PADDLE_LEFT_WIDTH = 20; // Width of the paddle
parameter PADDLE_LEFT_HEIGHT= 80; // Height of the paddle
parameter PADDLE_LEFT_X     = 195; // X-position of the paddle 
parameter PADDLE_LEFT_Y     = 244; 
parameter PADDLE_LEFT_COLOR_R = 8'hFF; // Red component of the paddle color
parameter PADDLE_LEFT_COLOR_G = 8'hFF; // Green component of the paddle color
parameter PADDLE_LEFT_COLOR_B = 8'hFF; // Blue component of the paddle color

// Ball parameters
parameter ball_size = 10;
reg [10:0] ball_x = 461;  // Initial x-position of the ball
reg [9:0] ball_y = 240;   // Initial y-position of the ball
reg ball_dir_x = 1;       // Ball movement direction (1: right, 0: left)
reg ball_dir_y = 1;       // Ball movement direction (1: down, 0: up)

reg [16:0] ball_counter;  // Counter to adjust down ball movement speed

// Score parameters
reg [3:0] score_left = 0; // Score for the left player (0 to 10)
reg [3:0] score_right = 0; // Score for the left player (0 to 10)

reg [28:0] delay_counter; // 29-bit counter for 10 seconds delay at 50 MHz
reg delay_done;           // Flag to indicate the delay is complete

//=======================================================
// Structural coding
//=======================================================

// Horizontal counter
always@(posedge iCLK or negedge iRST_N)
begin
    if(!iRST_N)
    begin
        H_Cont <= 0;
    end
    else
    begin
        if(H_Cont < H_SYNC_TOTAL)
            H_Cont <= H_Cont + 1;
        else
            H_Cont <= 0;
    end
end

// Vertical counter
always@(posedge iCLK or negedge iRST_N)
begin
    if(!iRST_N)
    begin
        V_Cont <= 0;
    end
    else
    begin
        if(H_Cont == 0)
        begin
            if(V_Cont < V_SYNC_TOTAL)
                V_Cont <= V_Cont + 1;
            else
                V_Cont <= 0;
        end
    end
end

// Ball movement
always @(posedge iCLK or negedge iRST_N) begin
    if (!iRST_N) begin
        ball_x <= 461;
        ball_y <= 240;
        ball_dir_x <= 1;
        ball_dir_y <= 1;
        ball_counter <= 0;
        delay_counter <= 0;  // Initialize delay counter
        delay_done <= 0;     // Initialize delay flag
        score_left <= 0;     // Reset score_left
        score_right <= 0;    // Reset score_right
    end else begin
        // Increment the delay counter if delay is not done
        if (!delay_done) begin
            if (delay_counter < 250000000) begin
                delay_counter <= delay_counter + 1;
            end else begin
                delay_done <= 1; // Set delay_done flag when the counter reaches 10 seconds
            end
        end else begin
            // Increment ball counter
            ball_counter <= ball_counter + 1;
        
            // Update ball position based on counter
            if (ball_counter == 0) begin
                // Update horizontal position
                if (ball_dir_x) begin
                    if (ball_x + ball_size >= H_SYNC_ACT + 149) begin // Check right edge 
                        ball_dir_x <= 0; // Change direction to left
                        if (score_left < 10)
                            score_left <= score_left + 1;
                    end else begin
                        ball_x <= ball_x + 1;
                    end
                end else begin
                    if (ball_x <= 170) begin // Check left edge 
                        ball_dir_x <= 1; // Change direction to right
                        if (score_right < 10) // Check if score_right is less than 10
                            score_right <= score_right + 1; // Increment score_right
                    end else begin
                        ball_x <= ball_x - 1;
                    end
                end
            
                // Update vertical position
                if (ball_dir_y) begin
                    if (ball_y + ball_size >= V_SYNC_ACT + 45) begin // Check bottom edge 
                        ball_dir_y <= 0; // Change direction to up
                    end else begin
                        ball_y <= ball_y + 1;
                    end
                end else begin
                    if (ball_y <= 50) begin // Check top edge 
                        ball_dir_y <= 1; // Change direction to down
                    end else begin
                        ball_y <= ball_y - 1;
                    end
                end
            end
        end
    end
end

// Function to draw score for left player 
function draw_number;
    input [3:0] number;
    input [10:0] h;
    input [9:0] v;
    begin
        case (number)
				// number 0
            4'd0: draw_number = ((h >= (hori_back + 220) && h < (hori_back + 240) && (v == (vert_back + 135) || v == (vert_back + 165))) || // Top and bottom horizontal lines for 0
                                 (h == (hori_back + 220) && v >= (vert_back + 135) && v < (vert_back + 165)) || // Left vertical line for 0
                                 (h == (hori_back + 240) && v >= (vert_back + 135) && v < (vert_back + 165))); // Right vertical line for 0
            // number 1
				4'd1: draw_number = ((h == (hori_back + 240) && v >= (vert_back + 135) && v < (vert_back + 165))); // Vertical line for 1
            // number 2
				4'd2: draw_number = ((h >= (hori_back + 220) && h < (hori_back + 240) && (v == (vert_back + 135) || v == (vert_back + 150) || v == (vert_back + 165))) || // Top, middle, and bottom horizontal lines for 2
                                 (h == (hori_back + 240) && v >= (vert_back + 135) && v < (vert_back + 150)) || // Top right vertical line for 2
                                 (h == (hori_back + 220) && v >= (vert_back + 150) && v < (vert_back + 165))); // Bottom left vertical line for 2
            // number 3
				4'd3: draw_number = ((h >= (hori_back + 220) && h < (hori_back + 240) && (v == (vert_back + 135) || v == (vert_back + 150) || v == (vert_back + 165))) || // Top, middle, and bottom horizontal lines for 3
                                 (h == (hori_back + 240) && v >= (vert_back + 135) && v < (vert_back + 165))); // Right vertical line for 3
            // number 4
             4'd4: draw_number = ((h == (hori_back + 240) && v >= (vert_back + 135) && v < (vert_back + 165)) || // Right vertical line for 4
                                 (h == (hori_back + 220) && v >= (vert_back + 135) && v < (vert_back + 150)) || // Left vertical line for upper half of 4
                                 (h >= (hori_back + 220) && h < (hori_back + 240) && v == (vert_back + 150))); // Middle horizontal line for 4
            // number 5
				4'd5: draw_number = ((h >= (hori_back + 220) && h < (hori_back + 240) && (v == (vert_back + 135) || v == (vert_back + 150) || v == (vert_back + 165))) || // Top, middle, and bottom horizontal lines for 5
                                 (h == (hori_back + 220) && v >= (vert_back + 135) && v < (vert_back + 150)) || // Top left vertical line for 5
                                 (h == (hori_back + 240) && v >= (vert_back + 150) && v < (vert_back + 165))); // Bottom right vertical line for 5
            // number 6
				4'd6: draw_number = ((h >= (hori_back + 220) && h < (hori_back + 240) && (v == (vert_back + 135) || v == (vert_back + 150) || v == (vert_back + 165))) || // Top, middle, and bottom horizontal lines for 6
                                 (h == (hori_back + 220) && v >= (vert_back + 135) && v < (vert_back + 165)) || // Left vertical line for 6
                                 (h == (hori_back + 240) && v >= (vert_back + 150) && v < (vert_back + 165))); // Bottom right vertical line for 6
            // number 7
				4'd7: draw_number = ((h >= (hori_back + 220) && h < (hori_back + 240) && v == (vert_back + 135)) || // Top horizontal line for 7
                                 (h == (hori_back + 240) && v >= (vert_back + 135) && v < (vert_back + 165))); // Right vertical line for 7
            // number 8
				4'd8: draw_number = ((h >= (hori_back + 220) && h < (hori_back + 240) && (v == (vert_back + 135) || v == (vert_back + 150) || v == (vert_back + 165))) || // Top, middle, and bottom horizontal lines for 8
                                 (h == (hori_back + 220) && v >= (vert_back + 135) && v < (vert_back + 165)) || // Left vertical line for 8
                                 (h == (hori_back + 240) && v >= (vert_back + 135) && v < (vert_back + 165))); // Right vertical line for 8
            // number 9
				4'd9: draw_number = ((h >= (hori_back + 220) && h < (hori_back + 240) && (v == (vert_back + 135) || v == (vert_back + 150) || v == (vert_back + 165))) || // Top, middle, and bottom horizontal lines for 9
											(h == (hori_back + 240) && v >= (vert_back + 135) && v < (vert_back + 165)) || // Right vertical line for 9
											(h == (hori_back + 220) && v >= (vert_back + 135) && v < (vert_back + 150))); // Top left vertical line for 9

				default: draw_number = 0;
        endcase
    end
endfunction

// Function to draw score for right player 
function draw_number_right;
input [3:0] number;
input [10:0] h;
input [9:0] v;
begin
    case (number)
		  // number 0
        4'd0: draw_number_right = ((h >= (hori_back + 390) && h < (hori_back + 410) && (v == (vert_back + 135) || v == (vert_back + 165))) || // Top en bottom horizontale lijnen voor 0
                                   (h == (hori_back + 390) && v >= (vert_back + 135) && v < (vert_back + 165)) || // Linker verticale lijn voor 0
                                   (h == (hori_back + 410) && v >= (vert_back + 135) && v < (vert_back + 165))); // Rechter verticale lijn voor 0
        // number 1
		  4'd1: draw_number_right = (h == (hori_back + 400) && v >= (vert_back + 135) && v < (vert_back + 165)); // Verticale lijn voor 1
		  // number 2
		  4'd2: draw_number_right = ((h >= (hori_back + 390) && h < (hori_back + 410) && (v == (vert_back + 135) || v == (vert_back + 150) || v == (vert_back + 165))) || // Top, middle en bottom horizontale lijnen voor 2
											 (h == (hori_back + 410) && v >= (vert_back + 135) && v < (vert_back + 150)) || // Rechter verticale lijn (bovenste helft) voor 2
										    (h == (hori_back + 390) && v >= (vert_back + 150) && v < (vert_back + 165))); // Linker verticale lijn (onderste helft) voor 2
        // number 3
		  4'd3: draw_number_right = ((h >= (hori_back + 390) && h < (hori_back + 410) && (v == (vert_back + 135) || v == (vert_back + 150) || v == (vert_back + 165))) || // Top, middle en bottom horizontale lijnen voor 3
                                   (h == (hori_back + 410) && v >= (vert_back + 135) && v < (vert_back + 165))); // Rechter verticale lijn voor 3
        // number 4
		  4'd4: draw_number_right = ((h == (hori_back + 390) && v >= (vert_back + 135) && v < (vert_back + 150)) || // Linker verticale lijn (bovenste helft) voor 4
                                   (h == (hori_back + 410) && v >= (vert_back + 135) && v < (vert_back + 165)) || // Rechter verticale lijn (onderste helft) voor 4
                                   (h >= (hori_back + 390) && h < (hori_back + 410) && v == (vert_back + 150))); // Horizontale lijn voor 
		  // number 5
		  4'd5: draw_number_right = ((h >= (hori_back + 390) && h < (hori_back + 410) && (v == (vert_back + 135) || v == (vert_back + 150) || v == (vert_back + 165))) || // Top en middenhorizontale lijnen voor 5
                                   (h == (hori_back + 390) && v >= (vert_back + 135) && v < (vert_back + 150)) || // Linker verticale lijn (bovenste helft) voor 5
                                   (h == (hori_back + 410) && v >= (vert_back + 150) && v < (vert_back + 165))); // Rechter verticale lijn (onderste helft) voor 5
        // number 6
		  4'd6: draw_number_right = ((h >= (hori_back + 390) && h < (hori_back + 410) && (v == (vert_back + 135) || v == (vert_back + 150) || v == (vert_back + 165))) || // Top en bottom horizontale lijnen voor 6
                                   (h == (hori_back + 390) && v >= (vert_back + 135) && v < (vert_back + 165)) || // Linker verticale lijn voor 6
                                   (h == (hori_back + 410) && v >= (vert_back + 150) && v < (vert_back + 165))); // Rechter verticale lijn (onderste helft) voor 6
        // number 7
		  4'd7: draw_number_right = ((h >= (hori_back + 390) && h < (hori_back + 410) && v == (vert_back + 135)) || // Top horizontale lijn voor 7
                                   (h == (hori_back + 410) && v >= (vert_back + 135) && v < (vert_back + 165))); // Rechter verticale lijn voor 7
        // number 8
		  4'd8: draw_number_right = ((h >= (hori_back + 390) && h < (hori_back + 410) && (v == (vert_back + 135) || v == (vert_back + 150) || v == (vert_back + 165))) || // Top en bottom horizontale lijnen voor 8
                                   (h == (hori_back + 390) && v >= (vert_back + 135) && v < (vert_back + 165)) || // Linker verticale lijn voor 8
                                   (h == (hori_back + 410) && v >= (vert_back + 135) && v < (vert_back + 165))); // Rechter verticale lijn voor 8
        // number 9
		  4'd9: draw_number_right = ((h >= (hori_back + 390) && h < (hori_back + 410) && (v == (vert_back + 135) || v == (vert_back + 150) || v == (vert_back + 165))) || // Top en bottom horizontale lijnen voor 9
                                   (h == (hori_back + 410) && v >= (vert_back + 135) && v < (vert_back + 165)) || // Rechter verticale lijn voor 9
											  (h == (hori_back + 390) && v >= (vert_back + 135) && v < (vert_back + 150))); // Top left vertical line for 9

        default: draw_number_right = 0;
    endcase
end
endfunction

// Output signals
assign oVGA_BLANK = ~((H_Cont < H_BLANK ) || (V_Cont < V_BLANK));
assign oVGA_H_SYNC = ((H_Cont > (H_SYNC_FRONT - H_MARK1)) && (H_Cont <= (H_SYNC_CYC + H_SYNC_FRONT - H_MARK1))) ? 0 : 1;
assign oVGA_V_SYNC = ((V_Cont > (V_SYNC_FRONT)) && (V_Cont <= (V_SYNC_CYC + V_SYNC_FRONT))) ? 0 : 1;

assign oRequest = (H_Cont >= X_START + H_MARK && H_Cont < X_START + H_SYNC_ACT + H_MARK &&
                   V_Cont >= Y_START + V_MARK && V_Cont < Y_START + V_SYNC_ACT + V_MARK) ? 1 : 0;

assign oVGA_SYNC = 1'b0;

// Reduce the intensity of the RGB signals to add a darker black glow effect
wire [7:0] reducedRed = iRed >> 1;
wire [7:0] reducedGreen = iGreen >> 1;
wire [7:0] reducedBlue = iBlue >> 1;

// draw middle line
wire lineActive = (H_Cont == (H_SYNC_ACT / 2) + LINE_OFFSET) && (V_Cont[5] == 1'b0); 

// draw right paddle
wire paddleRightActive = (H_Cont >= PADDLE_X && H_Cont < PADDLE_X + PADDLE_WIDTH) &&
                         (V_Cont >= PADDLE_Y && V_Cont < PADDLE_Y + PADDLE_HEIGHT);
                          
// draw left paddle
wire paddleLeftActive = (H_Cont >= PADDLE_LEFT_X && H_Cont < PADDLE_LEFT_X + PADDLE_LEFT_WIDTH) &&
                        (V_Cont >= PADDLE_LEFT_Y && V_Cont < PADDLE_LEFT_Y + PADDLE_LEFT_HEIGHT);

// draw ball
wire ballActive = (H_Cont >= ball_x && H_Cont < ball_x + ball_size) &&
                  (V_Cont >= ball_y && V_Cont < ball_y + ball_size);

// Add the paddles, ball, and the score to the output
assign oVGA_R = oVGA_BLANK ? 
                ((paddleRightActive || paddleLeftActive || ballActive || draw_number(score_left, H_Cont, V_Cont) || draw_number_right(score_right, H_Cont, V_Cont)) 
                 ? PADDLE_COLOR_R : (lineActive ? 8'hFF : reducedRed)) 
                : 0;

assign oVGA_G = oVGA_BLANK ? 
                ((paddleRightActive || paddleLeftActive || ballActive || draw_number(score_left, H_Cont, V_Cont) || draw_number_right(score_right, H_Cont, V_Cont)) 
                 ? PADDLE_COLOR_G : (lineActive ? 8'hFF : reducedGreen)) 
                : 0;

assign oVGA_B = oVGA_BLANK ? 
                ((paddleRightActive || paddleLeftActive || ballActive || draw_number(score_left, H_Cont, V_Cont) || draw_number_right(score_right, H_Cont, V_Cont)) 
                 ? PADDLE_COLOR_B : (lineActive ? 8'hFF : reducedBlue)) 
                : 0;

endmodule