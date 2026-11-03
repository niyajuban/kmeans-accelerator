`timescale 1ns / 1ps

module tb_pe;

    // -------------------------------------------------------------------------
    // 1. Create virtual wires to hook up to our chip's pins
    // -------------------------------------------------------------------------
    logic        clk;
    logic        rst_n;
    logic signed [7:0]  p_in;
    logic signed [7:0]  c_in;
    logic        [15:0] diff_sq_out;

    // -------------------------------------------------------------------------
    // 2. Place our chip (pe.sv) on the virtual workbench and wire it up
    // -------------------------------------------------------------------------
    pe uut (
        .clk        (clk),
        .rst_n      (rst_n),
        .p_in       (p_in),
        .c_in       (c_in),
        .diff_sq_out(diff_sq_out)
    );

    // -------------------------------------------------------------------------
    // 3. The Clock Generator (Oscillator)
    // Toggles every 5 nanoseconds -> 10ns clock cycle = 100 MHz clock
    // -------------------------------------------------------------------------
    always begin
        #5 clk = ~clk;
    end

    // -------------------------------------------------------------------------
    // 4. The Test Procedure (Feeding numbers and watching outputs)
    // -------------------------------------------------------------------------
    initial begin
        // Tell the simulator to record all wires into a waveform file
        $dumpfile("pe_waves.vcd");
        $dumpvars(0, tb_pe);

        // --- STEP A: Initialize wires & Reset the chip ---
        clk   = 0;
        rst_n = 0;   // Reset active (0)
        p_in  = 0;
        c_in  = 0;

        #15;         // Wait 15 nanoseconds
        rst_n = 1;   // Release reset (chip starts running!)

        // --- STEP B: Feed Test Case 1 ---
        // Point = 12, Center = 10 -> Expected: (12 - 10)^2 = (2)^2 = 4
        #10;
        p_in = 8'd12;
        c_in = 8'd10;

        // --- STEP C: Feed Test Case 2 ---
        // Point = 20, Center = 10 -> Expected: (20 - 10)^2 = (10)^2 = 100
        #10;
        p_in = 8'd20;
        c_in = 8'd10;

        // --- STEP D: Feed Test Case 3 ---
        // Point = 5, Center = 10 -> Expected: (5 - 10)^2 = (-5)^2 = 25
        #10;
        p_in = 8'd5;
        c_in = 8'd10;

        // Wait a few clock cycles for the pipeline to finish
        #30;

        $display("Simulation finished successfully!");
        $finish;
    end

endmodule
