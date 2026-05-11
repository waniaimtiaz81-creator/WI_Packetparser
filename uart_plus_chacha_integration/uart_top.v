module uart_top (
  input  wire clk      ,
  input  wire raw_reset,
  input  wire rx       ,
  output wire tx
);

  // Internal Wires (Correctly Declared)
  wire         tick                 ;
  wire         reset                ;
  wire [  7:0] rx_data_out          ;
  wire         rx_data_ready        ;
  wire [511:0] chacha_data_out      ;
  wire         chacha_data_out_valid;
  wire         tx_busy              ; // Declaration added here
  wire         tx_done              ; // Declaration added here

  wire         chacha_ready   ;
  wire [511:0] chacha_data_in ;
  wire         chacha_data_vld;

  // Controller Registers
  reg [5:0] byte_count   ;
  reg       chacha_init  ;
  reg       tx_start     ;
  reg [7:0] tx_data_in   ;
  reg [2:0] master_state ;
  reg [5:0] tx_byte_count;

  assign reset = ~raw_reset;

  // FSM State Definitions
  localparam S_IDLE     = 3'd0;
  localparam S_COLLECT  = 3'd1;
  localparam S_ENCRYPT  = 3'd2;
  localparam S_TRANSMIT = 3'd3;
  localparam S_WAIT_TX  = 3'd4;

  wire data_in_vld ;
  wire data_out_vld;
  uart_rx_to_chacha i_uart_rx_to_chacha (
    .clk         (clk            ),
    .raw_reset   (reset          ),
    .data_in     (rx_data_out    ),
    .data_in_vld (rx_data_ready  ),
    .data_out    (chacha_data_in ),
    .data_out_vld(chacha_data_vld)
  );

  chacha_to_uart_tx i_chacha_to_uart_tx (
    .clk         (clk                  ),
    .reset       (reset                ),
    .data_in     (chacha_data_out      ),
    .data_in_vld (chacha_data_out_valid),
    .uart_tx_busy(tx_busy              ),
    .uart_done   (tx_done              ),
    .data_out    (tx_data_in           ),
    .data_out_vld(tx_start             ),
    .busy        (                     )
  );


  // Module Instantiations
  baud_gen #(.BAUD_DIV(5208)) baud_inst (.clk(clk), .reset(reset), .tick(tick));

  uart_rx rx_inst (
    .clk       (clk          ),
    .reset     (reset        ),
    .tick      (tick         ),
    .rx        (rx           ),
    .data_out  (rx_data_out  ),
    .data_ready(rx_data_ready),
    .busy      (             )
  );

  uart_tx tx_inst (
    .clk    (clk       ),
    .reset  (reset     ),
    .tick   (tick      ),
    .start  (tx_start  ),
    .data_in(tx_data_in),
    .tx     (tx        ),
    .busy   (tx_busy   ),
    .done   (tx_done   )
  );

  chacha_core chacha_inst (
    .clk           (clk                                                                  ),
    .reset_n       (~reset                                                               ),
    .data_in       (chacha_data_in                                                       ),
    .init          (chacha_data_vld                                                      ),
    .next          (1'b0                                                                 ),
    .key           (256'h03020100070605040b0a09080f0e0d0c13121110171615141b1a19181f1e1d1c),
    .keylen        (1'b1                                                                 ),
    .iv            (64'h0                                                                ),
    .ctr           (64'h0                                                                ),
    .rounds        (5'd20                                                                ),
    .ready         (                                                                     ),
    .data_out      (chacha_data_out                                                      ),
    .data_out_valid(chacha_data_out_valid                                                )
  );

endmodule