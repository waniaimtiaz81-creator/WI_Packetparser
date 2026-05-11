module top_module (
	input       clk  ,
	input       reset,
	input       en   ,
	input       load ,
	input  wire rx   ,
	output wire tx
);

	logic         tick                 ;
	logic         uart_rx_busy         ;
	logic [  7:0] uarts_rx_data_in     ;
	logic         uarts_rx_data_in_vld ;
	logic [511:0] uarts_rx_data_out    ;
	logic         uarts_rx_data_out_vld;

	logic [ 31:0] trng_data_in     ;
	logic         trng_data_in_vld ;
	logic [511:0] trng_data_out    ;
	logic         trng_data_out_vld;

	logic [511:0] chacha_data_in    ;
	logic         chacha_data_in_vld;

	logic [511:0] chacha_data_out      ;
	logic         chacha_data_out_valid;
	logic         chacha_ready         ;

	logic       uart_tx_busy        ;
	logic       uart_tx_done        ;
	logic [7:0] uart_tx_data_out    ;
	logic       uart_tx_data_out_vld;
	logic       chacha_to_uart_busy ;

	baud_gen #(.BAUD_DIV(5208)) i_baud_gen (
		.clk  (clk  ),
		.reset(reset),
		.tick (tick )
	);

	uart_rx i_uart_rx (
		.clk       (clk                 ),
		.reset     (reset               ),
		.tick      (tick                ),
		.rx        (rx                  ),
		.data_out  (uarts_rx_data_in    ),
		.data_ready(uarts_rx_data_in_vld),
		.busy      (uart_rx_busy        )
	);

	uart_rx_to_chacha i_uart_rx_to_chacha (
		.clk         (clk                  ),
		.raw_reset   (reset                ),
		.data_in     (uarts_rx_data_in     ),
		.data_in_vld (uarts_rx_data_in_vld ),
		.data_out    (uarts_rx_data_out    ),
		.data_out_vld(uarts_rx_data_out_vld)
	);

`ifdef WITH_VONNEUMAN
	comb_d_without_von trng (
		.clk          (clk             ),
		.en           (en              ),
		.rst          (reset           ),
		.load         (load            ),
		.shift_reg    (trng_data_in    ),
		.shift_reg_vld(trng_data_in_vld)
	);
`elsif 
	comb_d trng (
		.clk          (clk             ),
		.en           (en              ),
		.rst          (reset           ),
		.load         (load            ),
		.shift_reg    (trng_data_in    ),
		.shift_reg_vld(trng_data_in_vld)
	);
`endif
	trng_to_chacha i_trng_to_chacha (
		.clk             (clk              ),
		.reset           (reset            ),
		.trng_data_in    (trng_data_in     ),
		.trng_data_in_vld(trng_data_in_vld ),
		.data_out        (trng_data_out    ),
		.data_out_vld    (trng_data_out_vld)
	);

	trng_or_uart_to_chacha i_trng_or_uart_to_chacha (
		.clk               (clk                  ),
		.reset             (reset                ),
		.chacha_ready      (chacha_ready         ),
		.trng_data_in      (trng_data_out        ),
		.trng_data_in_vld  (trng_data_out_vld    ),
		.uart_data_in      (uarts_rx_data_out    ),
		.uart_data_in_vld  (uarts_rx_data_out_vld),
		.chacha_data_in    (chacha_data_in       ),
		.chacha_data_in_vld(chacha_data_in_vld   )
	);


	chacha_core i_chacha_core (
		.clk           (clk                                                                  ),
		.reset_n       (!reset                                                               ),
		.init          (chacha_data_in_vld                                                   ),
		.data_in       (chacha_data_in                                                       ),
		.next          (1'b0                                                                 ),
		.key           (256'h03020100070605040b0a09080f0e0d0c13121110171615141b1a19181f1e1d1c),
		.keylen        (1'b1                                                                 ),
		.iv            (64'h0                                                                ),
		.ctr           (64'h0                                                                ),
		.rounds        (5'd20                                                                ),
		.data_out      (chacha_data_out                                                      ),
		.data_out_valid(chacha_data_out_valid                                                ),
		.ready         (chacha_ready                                                         )
	);

	chacha_to_uart_tx i_chacha_to_uart_tx (
		.clk         (clk                  ),
		.reset       (reset                ),
		.data_in     (chacha_data_out      ),
		.data_in_vld (chacha_data_out_valid),
		.uart_tx_busy(uart_tx_busy         ),
		.uart_done   (uart_tx_done         ),
		.data_out    (uart_tx_data_out     ),
		.data_out_vld(uart_tx_data_out_vld ),
		.busy        (chacha_to_uart_busy  )
	);

	uart_tx i_uart_tx (
		.clk    (clk                 ),
		.reset  (reset               ),
		.tick   (tick                ),
		.data_in(uart_tx_data_out    ),
		.start  (uart_tx_data_out_vld),
		.tx     (tx                  ),
		.busy   (uart_tx_busy        ),
		.done   (uart_tx_done        )
	);

endmodule