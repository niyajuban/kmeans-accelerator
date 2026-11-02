/*
 * Copyright (c) 2026 Niyaz
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_niyajuban_kmeans (
    input  wire [7:0] ui_in,    // Dedicated inputs:  Point X coordinate (px_in)
    output wire [7:0] uo_out,   // Dedicated outputs: uo_out[0] = cluster_out, uo_out[1] = valid_out
    input  wire [7:0] uio_in,   // Bidirectional in:  Point Y coordinate (py_in)
    output wire [7:0] uio_out,  // Bidirectional out: Unused
    output wire [7:0] uio_oe,   // Pin direction:     0 = all inputs
    input  wire       ena,      // 1 when powered
    input  wire       clk,      // System clock
    input  wire       rst_n     // Active-low reset
);

    wire valid_out;
    wire cluster_out;
    wire [16:0] dist0_out;
    wire [16:0] dist1_out;

    // Instantiate your K-Means Accelerator
    kmeans_top u_kmeans (
        .clk        (clk),
        .rst_n      (rst_n),
        .valid_in   (ena),          // Active when chip is enabled
        .px_in      (ui_in),        // Point X from Input pins
        .py_in      (uio_in),       // Point Y from Bi-dir pins
        .valid_out  (valid_out),
        .cluster_out(cluster_out),
        .dist0_out  (dist0_out),
        .dist1_out  (dist1_out)
    );

    // Map outputs to chip pins
    assign uo_out[0]   = cluster_out;       // Pin 0: Cluster (0 or 1)
    assign uo_out[1]   = valid_out;         // Pin 1: Result Valid Strobe
    assign uo_out[7:2] = dist0_out[5:0];    // Pins 2-7: Lower bits of distance (debug)

    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;                  // Set all uio pins as inputs

    // Unused wire cleanup
    wire _unused = &{dist0_out[16:6], dist1_out, 1'b0};

endmodule
