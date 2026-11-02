// =============================================================================
// Module: dist_unit
// Description: Computes (Px - Cx)^2 + (Py - Cy)^2
// Latency: 3 clock cycles
// =============================================================================

module dist_unit (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        valid_in,
    
    // Point coordinates (Px, Py)
    input  logic signed [7:0] px_in,
    input  logic signed [7:0] py_in,
    
    // Center coordinates (Cx, Cy)
    input  logic signed [7:0] cx_in,
    input  logic signed [7:0] cy_in,
    
    // Output: 17-bit sum of squared distances
    output logic        valid_out,
    output logic [16:0] dist_sq_out
);

    // Wires from PEs
    logic [15:0] x_sq;
    logic [15:0] y_sq;

    // Shift register to track validity across the 3 clock cycles
    logic [2:0] valid_pipe;

    // -------------------------------------------------------------------------
    // Hardware Instance 1: Calculate (Px - Cx)^2 (Latency: 2 cycles)
    // -------------------------------------------------------------------------
    pe pe_x (
        .clk        (clk),
        .rst_n      (rst_n),
        .p_in       (px_in),
        .c_in       (cx_in),
        .diff_sq_out(x_sq)
    );

    // -------------------------------------------------------------------------
    // Hardware Instance 2: Calculate (Py - Cy)^2 (Latency: 2 cycles)
    // -------------------------------------------------------------------------
    pe pe_y (
        .clk        (clk),
        .rst_n      (rst_n),
        .p_in       (py_in),
        .c_in       (cy_in),
        .diff_sq_out(y_sq)
    );

    // -------------------------------------------------------------------------
    // Pipeline & Adder (Cycle 3: Add x_sq + y_sq)
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            dist_sq_out <= 17'd0;
            valid_pipe  <= 3'b0;
        end else begin
            valid_pipe  <= {valid_pipe[1:0], valid_in};
            dist_sq_out <= x_sq + y_sq;
        end
    end

    assign valid_out = valid_pipe[2];

endmodule
