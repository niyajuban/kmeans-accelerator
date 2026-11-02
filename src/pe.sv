module pe (
    input  logic        clk,        // Clock tick
    input  logic        rst_n,      // Reset (Active-Low: 0 means reset, 1 means run)
    
    input  logic signed [7:0]  p_in, // Point coordinate (8-bit signed: -128 to +127)
    input  logic signed [7:0]  c_in, // Center coordinate (8-bit signed)
    
    output logic        [15:0] diff_sq_out // Squared result (16-bit positive number)
);

    // Internal wire/register to hold the difference after Tick 1
    // We use 9 bits ([8:0]) so subtracting doesn't overflow!
    logic signed [8:0] diff_reg;

    // --- CLOCK TICK 1: Subtraction ---
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            diff_reg <= 9'd0;       // Reset to 0
        end else begin
            diff_reg <= p_in - c_in; // Compute difference
        end
    end

    // --- CLOCK TICK 2: Multiplication (Squaring) ---
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            diff_sq_out <= 16'd0;
        end else begin
            diff_sq_out <= diff_reg * diff_reg; // Multiply difference by itself
        end
    end

endmodule
