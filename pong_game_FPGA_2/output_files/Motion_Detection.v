module Motion_Detection #(
    parameter WIDTH = 640,
    parameter HEIGHT = 480,
    parameter THRESHOLD = 50
) (
    input wire clk,
    input wire rst,
    input wire frame_start,
    input wire [9:0] pixel_x,
    input wire [9:0] pixel_y,
    input wire [7:0] current_pixel_red,
    input wire [7:0] current_pixel_green,
    input wire [7:0] current_pixel_blue,
    input wire [7:0] previous_pixel_red,
    input wire [7:0] previous_pixel_green,
    input wire [7:0] previous_pixel_blue,
    output wire[9:0] LEDR,
	 
    output reg motion_detected
);

    reg [31:0] diff_sum;
    reg [31:0] pixel_count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            diff_sum <= 0;
            pixel_count <= 0;
            motion_detected <= 0;
				
        end else if (frame_start) begin

            if (pixel_count > 0 && (diff_sum / pixel_count) > THRESHOLD) begin
                motion_detected <= 1;

            end else begin
                motion_detected <= 0;

            end

            diff_sum <= 0;
            pixel_count <= 0;
        end else begin

            diff_sum <= diff_sum + (
                abs_diff(current_pixel_red, previous_pixel_red) +
                abs_diff(current_pixel_green, previous_pixel_green) +
                abs_diff(current_pixel_blue, previous_pixel_blue)
            );
            pixel_count <= pixel_count + 1;
        end
    end

    function [7:0] abs_diff;
        input [7:0] a, b;
        begin
            abs_diff = (a > b) ? (a - b) : (b - a);
        end
    endfunction
	 
assign LEDR[2] = (current_pixel_red != previous_pixel_red) || (current_pixel_green != previous_pixel_green) || (current_pixel_blue != previous_pixel_blue);


endmodule