`timescale 1ns/1ns
module tb_top_module ();

	logic clk   = 0;
	logic reset = 1;
	logic en    = 0;
	logic load  = 0;
	logic rx    = 0;
	logic tx       ;

	logic [1:0] mux_slect = 0;
	logic [6:0] HEX_0        ;
	logic [6:0] HEX_1        ;
	logic [6:0] HEX_2        ;
	logic [6:0] HEX_3        ;
	logic [6:0] HEX_4        ;
	logic [6:0] HEX_5        ;
	logic [6:0] HEX_6        ;
	logic [6:0] HEX_7        ;

	top_module i_top_module (
		.clk      (clk      ),
		.reset    (reset    ),
		.en       (en       ),
		.load     (load     ),
		.mux_slect(mux_slect),
		.HEX_0    (HEX_0    ),
		.HEX_1    (HEX_1    ),
		.HEX_2    (HEX_2    ),
		.HEX_3    (HEX_3    ),
		.HEX_4    (HEX_4    ),
		.HEX_5    (HEX_5    ),
		.HEX_6    (HEX_6    ),
		.HEX_7    (HEX_7    ),
		.rx       (rx       ),
		.tx       (tx       )
	);

	always #10 clk <= ~clk;

	task send_byte(input [7:0] d);
		integer j;
		begin
			rx = 0; #52080; // Start
			for (j=0; j<8; j=j+1) begin
				rx = d[j]; #52080;
			end
			rx = 1; #52080; // Stop
		end
	endtask

	initial begin
		#200 reset = 0; // Release reset
		#1000;
		en = 1;

		$display("Sending 64 bytes of Plaintext...");
		repeat(150) send_byte($urandom_range(0,255));

		$display("Waiting for Encrypted Output...");
		// Simulation time barha dein taake output nazar aaye
		repeat(1000000) @(posedge clk);

		load = 1;

		$display("Sending 64 bytes of Plaintext...");
		repeat(65) send_byte($urandom_range(0,255));
		repeat(5000000) @(posedge clk);

		$finish;
	end

endmodule