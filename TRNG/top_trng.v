module top_trng(
    input clk_in,    // FPGA ka master clock
    input en,        // Enable switch
    input rst,       // Reset button
    input load,      // Load enable (Keep high to see continuous randomness)
    output [7:0] leds // FPGA ki 8 LEDs
);

    wire clk_slow;
    wire [31:0] full_shift_reg;

    // 1. Clock Divider (Taake LEDs ki speed human eye dekh sakay)
    // Aapne jo divider diya tha wahi use ho raha hai
    clk_divider #( .Divider(5000000) ) div1 ( // Thora divider barhaya hai taake flicker dikhayi de
        .clk_in(clk_in),
        .clk_out(clk_slow)
    );

    // 2. Aapka TRNG Core (comb_d)
    comb_d trng_inst (
        .clk(clk_slow),
        .en(en),
        .rst(rst),
        .load(load),
        .shift_reg(full_shift_reg)
    );

    // 3. Output to LEDs
    // Hum shift register ke aakhri 8 bits LEDs par dikha rahe hain
    assign leds = full_shift_reg[7:0];

endmodule