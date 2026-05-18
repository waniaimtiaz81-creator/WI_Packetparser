module top_module (
	input  logic       clk      ,
	input  logic       reset    ,
	input  logic       en       ,
	input  logic       load     ,
	input  logic [1:0] mux_slect,
	output logic [6:0] HEX_0    ,
	output logic [6:0] HEX_1    ,
	output logic [6:0] HEX_2    ,
	output logic [6:0] HEX_3    ,
	output logic [6:0] HEX_4    ,
	output logic [6:0] HEX_5    ,
	output logic [6:0] HEX_6    ,
	output logic [6:0] HEX_7    ,
	input  logic       rx       ,
	output logic       tx
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

	logic [31:0]      hex_value;
	logic [ 7:0][6:0] segment  ;

	logic [511:0] chacha_data_in               ;
	logic         chacha_data_in_vld           ;
	logic [511:0] chacha_data_out_encrypt      ;
	logic         chacha_data_out_valid_encrypt;
	logic [511:0] chacha_data_out              ;
	logic         chacha_data_out_valid        ;
	logic         chacha_ready_en              ;
	logic         chacha_ready_de              ;

	logic       uart_tx_busy        ;
	logic       uart_tx_done        ;
	logic [7:0] uart_tx_data_out    ;
	logic       uart_tx_data_out_vld;
	logic       chacha_to_uart_busy ;

	logic [512:0] status_data           ;
	logic         status_data_vld       ;
	logic [512:0] mux_out_data_to_tx    ;
	logic         mux_out_data_to_tx_vld;

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

// `ifdef WITH_VONNEUMAN
	// comb_d trng (
	// .clk          (clk             ),
	// .en           (en              ),
	// .rst          (reset           ),
	// .load         (load            ),
	// .shift_reg    (trng_data_in    ),
	// .shift_reg_vld(trng_data_in_vld)
	// );
// `elsif
	comb_d_without_von trng (
		.clk          (clk             ),
		.en           (en              ),
		.rst          (reset           ),
		.load         (load            ),
		.shift_reg    (trng_data_in    ),
		.shift_reg_vld(trng_data_in_vld)
	);
// `endif

	always_ff @(posedge clk) begin
		if(reset)
			hex_value <= 0;
		else if(trng_data_in_vld)
			hex_value <= trng_data_in;
	end

	genvar i;
	generate
		for (i = 0; i < 8; i++) begin
			seven_seg_display i_seven_seg_display (
				.hex_value(hex_value[i*4+:4]),
				.segments (segment[i]       )
			);
		end
	endgenerate

	assign HEX_0 = segment[0];
	assign HEX_1 = segment[1];
	assign HEX_2 = segment[2];
	assign HEX_3 = segment[3];
	assign HEX_4 = segment[4];
	assign HEX_5 = segment[5];
	assign HEX_6 = segment[6];
	assign HEX_7 = segment[7];

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
		.chacha_ready      (chacha_ready_en      ),
		.load              (load                 ),
		.trng_data_in      (trng_data_out        ),
		.trng_data_in_vld  (trng_data_out_vld    ),
		.uart_data_in      (uarts_rx_data_out    ),
		.uart_data_in_vld  (uarts_rx_data_out_vld),
		.chacha_data_in    (chacha_data_in       ),
		.chacha_data_in_vld(chacha_data_in_vld   )
	);

	chacha_core i_chacha_core_en (
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
		.data_out      (chacha_data_out_encrypt                                              ),
		.data_out_valid(chacha_data_out_valid_encrypt                                        ),
		.ready         (chacha_ready_en                                                      )
	);

	chacha_core i_chacha_core_de (
		.clk           (clk                                                                  ),
		.reset_n       (!reset                                                               ),
		.data_in       (chacha_data_out_encrypt                                              ),
		.init          (chacha_data_out_valid_encrypt                                        ),
		.next          (1'b0                                                                 ),
		.key           (256'h03020100070605040b0a09080f0e0d0c13121110171615141b1a19181f1e1d1c),
		.keylen        (1'b1                                                                 ),
		.iv            (64'h0                                                                ),
		.ctr           (64'h0                                                                ),
		.rounds        (5'd20                                                                ),
		.data_out      (chacha_data_out                                                      ),
		.data_out_valid(chacha_data_out_valid                                                ),
		.ready         (chacha_ready_de                                                      )
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

	status_counter i_status_counter (
		.clk                (clk                          ),
		.reset              (reset                        ),
		.uart_rx_vld        (uarts_rx_data_out_vld        ),
		.trng_data_vld      (trng_data_out_vld            ),
		.plain_text         (chacha_data_in               ),
		.plain_text_vld     (chacha_data_in_vld           ),
		.encrypted_data_vld (chacha_data_out_valid_encrypt),
		.decrypted_data     (chacha_data_out              ),
		.decrypted_data_vld (chacha_data_out_valid        ),
		.status_data_out    (status_data                  ),
		.status_data_out_vld(status_data_vld              )
	);

	mux_to_uart_tx i_mux_to_uart_tx (
		.clk                   (clk                          ),
		.reset                 (reset                        ),
		.mux_slect             (mux_slect                    ),
		.plain_text            (chacha_data_in               ),
		.plain_text_vld        (chacha_data_in_vld           ),
		.encrypted_data        (chacha_data_out_encrypt      ),
		.encrypted_data_vld    (chacha_data_out_valid_encrypt),
		.decrypted_data        (uart_tx_data_out             ),
		.decrypted_data_vld    (uart_tx_data_out_vld         ),
		.status_data           (status_data                  ),
		.status_data_vld       (status_data_vld              ),
		.mux_out_data_to_tx    (mux_out_data_to_tx           ),
		.mux_out_data_to_tx_vld(mux_out_data_to_tx_vld       )
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