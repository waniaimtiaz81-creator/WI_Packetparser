`timescale 1ns/1ns

module tb_top_trng ();

// 
	// logic clk_in;
	// logic en;
	// logic rst;
	// logic load;
	// logic [7:0] leds;
// top_trng i_top_trng (.clk_in(clk_in), .en(en), .rst(rst), .load(load), .leds(leds));

	logic        clk       = 0;
	logic        en        = 0;
	logic        rst       = 1;
	logic        load      = 0;
	logic [31:0] shift_reg    ;
	comb_d_without_von i_comb_d (
		.clk      (clk      ),
		.en       (en       ),
		.rst      (rst      ),
		.load     (load     ),
		.shift_reg(shift_reg)
	);

always #5 clk <= ~clk;

initial begin
	repeat(100) @(posedge clk);
  rst = 0;
	repeat(100) @(posedge clk);
  en  = 1;
	repeat(1000) @(posedge clk);
  load= 1;

	repeat(1000) @(posedge clk);
  
  $finish;
 
end

endmodule 