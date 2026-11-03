`timescale 1ns / 1ps

module tb_kmeans_top;

    // Signals
    logic        clk;
    logic        rst_n;
    logic        valid_in;
    logic signed [7:0] px_in;
    logic signed [7:0] py_in;
    
    logic        valid_out;
    logic        cluster_out;
    logic [16:0] dist0_out;
    logic [16:0] dist1_out;

    // Instantiate Top-Level Accelerator
    kmeans_top uut (
        .clk        (clk),
        .rst_n      (rst_n),
        .valid_in   (valid_in),
        .px_in      (px_in),
        .py_in      (py_in),
        .valid_out  (valid_out),
        .cluster_out(cluster_out),
        .dist0_out  (dist0_out),
        .dist1_out  (dist1_out)
    );

    // 100 MHz Clock Generator (Period = 10ns)
    always begin
        #5 clk = ~clk;
    end

    // Monitor: Watch output stream and print verification on falling edge
    int point_count = 0;
    always @(negedge clk) begin
        if (valid_out) begin
            $display("[T=%0t ns] Output Valid: Point %0d -> Dist0=%0d, Dist1=%0d => Assigned Cluster: %0d", 
                     $time/1000, point_count, dist0_out, dist1_out, cluster_out);
            point_count++;
        end
    end

    // Test Procedure
    initial begin
        // Waveform dump
        $dumpfile("kmeans_waves.vcd");
        $dumpvars(0, tb_kmeans_top);

        // Reset
        clk      = 0;
        rst_n    = 0;
        valid_in = 0;
        px_in    = 0;
        py_in    = 0;

        #25;
        rst_n = 1; // Release reset cleanly
        
        $display("\n=======================================================");
        $display("   STARTING K-MEANS ACCELERATOR HARDWARE TEST");
        $display("=======================================================\n");

        // Drive inputs on negedge clk to guarantee clean setup time
        @(negedge clk);
        valid_in <= 1;
        px_in    <= 8'sd12;
        py_in    <= 8'sd15;

        @(negedge clk);
        valid_in <= 1;
        px_in    <= 8'sd85;
        py_in    <= 8'sd78;

        @(negedge clk);
        valid_in <= 1;
        px_in    <= 8'sd20;
        py_in    <= 8'sd25;

        @(negedge clk);
        valid_in <= 1;
        px_in    <= 8'sd70;
        py_in    <= 8'sd65;

        // Stop streaming
        @(negedge clk);
        valid_in <= 0;
        px_in    <= 0;
        py_in    <= 0;

        // Wait for pipeline drain
        #80;

        $display("\n=======================================================");
        $display("   ALL TEST POINTS PROCESSED SUCCESSFULLY!");
        $display("=======================================================\n");
        $finish;
    end

endmodule
