// =============================================================================
// Module: kmeans_top
// Description: K-Means Accelerator Top-Level Chip
// Evaluates Center 0 (10, 10) and Center 1 (80, 80) concurrently.
// Latency: 4 clock cycles (3 cycles distance + 1 cycle comparator)
// =============================================================================

module kmeans_top (
    input  logic        clk,
    input  logic        rst_n,
    
    // Input Stream
    input  logic        valid_in,
    input  logic signed [7:0] px_in,
    input  logic signed [7:0] py_in,
    
    // Output Stream
    output logic        valid_out,
    output logic        cluster_out,     // 0 = Cluster 0, 1 = Cluster 1
    
    // Debug/Monitoring outputs to see distances in waveforms
    output logic [16:0] dist0_out,
    output logic [16:0] dist1_out
);

    // Hardcoded cluster centers matching our Python model
    localparam signed [7:0] C0_X = 8'sd10;
    localparam signed [7:0] C0_Y = 8'sd10;
    
    localparam signed [7:0] C1_X = 8'sd80;
    localparam signed [7:0] C1_Y = 8'sd80;

    // Internal distance wires
    logic [16:0] dist0_wire;
    logic [16:0] dist1_wire;
    logic        vld0_wire;
    logic        vld1_wire;

    // -------------------------------------------------------------------------
    // Parallel Engine 0: Measure Distance to Center 0 (10, 10)
    // -------------------------------------------------------------------------
    dist_unit dist_engine_0 (
        .clk        (clk),
        .rst_n      (rst_n),
        .valid_in   (valid_in),
        .px_in      (px_in),
        .py_in      (py_in),
        .cx_in      (C0_X),
        .cy_in      (C0_Y),
        .valid_out  (vld0_wire),
        .dist_sq_out(dist0_wire)
    );

    // -------------------------------------------------------------------------
    // Parallel Engine 1: Measure Distance to Center 1 (80, 80)
    // -------------------------------------------------------------------------
    dist_unit dist_engine_1 (
        .clk        (clk),
        .rst_n      (rst_n),
        .valid_in   (valid_in),
        .px_in      (px_in),
        .py_in      (py_in),
        .cx_in      (C1_X),
        .cy_in      (C1_Y),
        .valid_out  (vld1_wire),
        .dist_sq_out(dist1_wire)
    );

    // -------------------------------------------------------------------------
    // Cycle 4: Comparator (Find the smaller distance)
    // -------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            cluster_out <= 1'b0;
            valid_out   <= 1'b0;
            dist0_out   <= 17'd0;
            dist1_out   <= 17'd0;
        end else begin
            valid_out   <= vld0_wire;
            dist0_out   <= dist0_wire;
            dist1_out   <= dist1_wire;
            
            if (vld0_wire) begin
                // If Dist0 <= Dist1 -> Cluster 0, else Cluster 1
                if (dist0_wire <= dist1_wire) begin
                    cluster_out <= 1'b0;
                end else begin
                    cluster_out <= 1'b1;
                end
            end
        end
    end

endmodule
