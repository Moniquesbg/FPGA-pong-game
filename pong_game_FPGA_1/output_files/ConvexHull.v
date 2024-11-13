module ConvexHull(
    input wire clk,
    input wire rst,
    input wire [7:0] pixel_in,
    input wire [10:0] x,
    input wire [10:0] y,
    input wire [15:0] point_count,
    output reg [7:0] hull_out,
    output reg [10:0] hull_x,
    output reg [10:0] hull_y
);

    // Parameters
    parameter MAX_POINTS = 256;
    parameter MAX_LOOP_ITER = MAX_POINTS - 2;
    parameter TOLERANCE = 10;  // Tolerantie voor stabiliteit bij cross_product berekening

    // Memory for contour and hull points
    reg [10:0] contour_x [0:MAX_POINTS-1];
    reg [10:0] contour_y [0:MAX_POINTS-1];
    reg [10:0] hull_stack_x [0:MAX_POINTS-1];
    reg [10:0] hull_stack_y [0:MAX_POINTS-1];

    // Registers
    reg [7:0] state;
    reg [15:0] i, top;
    reg signed [20:0] cross_product;

    // States
    localparam IDLE = 8'd0,
               INIT_HULL = 8'd1,
               PROCESS_POINTS = 8'd2,
               CALC_CROSS = 8'd3,
               POP_POINT = 8'd4,
               PUSH_POINT = 8'd5,
               OUTPUT_HULL = 8'd6,
               DONE = 8'd7;

    // State machine
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            i <= 0;
            top <= 0;
            hull_out <= 8'h00;
        end else begin
            case (state)
                IDLE: begin
                    // Add points to contour when pixel_in is valid
                    if (pixel_in > 0 && point_count < MAX_POINTS) begin
                        contour_x[point_count] <= x;
                        contour_y[point_count] <= y;
                        if (point_count == MAX_POINTS - 1) state <= INIT_HULL;
                    end
                end

                INIT_HULL: begin
                    hull_stack_x[0] <= contour_x[0];
                    hull_stack_y[0] <= contour_y[0];
                    hull_stack_x[1] <= contour_x[1];
                    hull_stack_y[1] <= contour_y[1];
                    top <= 2;
                    i <= 2;
                    state <= PROCESS_POINTS;
                end

                PROCESS_POINTS: begin
                    if (i < point_count && i < MAX_LOOP_ITER) begin
                        state <= CALC_CROSS;
                    end else begin
                        state <= OUTPUT_HULL;
                    end
                end

                CALC_CROSS: begin
                    cross_product <= (hull_stack_x[top-1] - hull_stack_x[top-2]) * (contour_y[i] - hull_stack_y[top-2]) -
                                     (hull_stack_y[top-1] - hull_stack_y[top-2]) * (contour_x[i] - hull_stack_x[top-2]);
                    // Introduce tolerance for cross product calculation
                    if (cross_product < -TOLERANCE && top > 2) begin
                        state <= POP_POINT;
                    end else begin
                        state <= PUSH_POINT;
                    end
                end

                POP_POINT: begin
                    top <= top - 1;
                    state <= CALC_CROSS;
                end

                PUSH_POINT: begin
                    hull_stack_x[top] <= contour_x[i];
                    hull_stack_y[top] <= contour_y[i];
                    top <= top + 1;
                    i <= i + 1;
                    state <= PROCESS_POINTS;
                end

                OUTPUT_HULL: begin
                    if (i < top) begin
                        hull_x <= hull_stack_x[i];
                        hull_y <= hull_stack_y[i];
                        hull_out <= 8'hFF;
                        i <= i + 1;
                    end else begin
                        state <= DONE;
                    end
                end

                DONE: begin
                    // Remain in DONE state, ready for next reset
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
