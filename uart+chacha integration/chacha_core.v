`default_nettype none

module chacha_core(
                   input wire            clk,
                   input wire            reset_n,

                   input wire            init,
                   input wire            next,

                   input wire [255 : 0]  key,
                   input wire            keylen,
                   input wire [63 : 0]   iv,
                   input wire [63 : 0]   ctr,
                   input wire [4 : 0]    rounds,

                   input wire [511 : 0]  data_in,

                   output wire           ready,

                   output wire [511 : 0] data_out,
                   output wire           data_out_valid
                  );

  // Parameters
  localparam QR0 = 0;
  localparam QR1 = 1;
  localparam CTRL_IDLE     = 3'h0;
  localparam CTRL_INIT     = 3'h1;
  localparam CTRL_ROUNDS   = 3'h2;
  localparam CTRL_FINALIZE = 3'h3;
  localparam CTRL_DONE     = 3'h4;

  localparam TAU0 = 32'h61707865;
  localparam TAU1 = 32'h3120646e;
  localparam TAU2 = 32'h79622d36;
  localparam TAU3 = 32'h6b206574;

  localparam SIGMA0 = 32'h61707865;
  localparam SIGMA1 = 32'h3320646e;
  localparam SIGMA2 = 32'h79622d32;
  localparam SIGMA3 = 32'h6b206574;

  function [31 : 0] l2b(input [31 : 0] op);
    begin
      l2b = {op[7 : 0], op[15 : 8], op[23 : 16], op[31 : 24]};
    end
  endfunction 

  // Registers
  reg [31 : 0]  state_reg [0 : 15];
  reg [31 : 0]  state_new [0 : 15];
  reg           state_we;
  reg [511 : 0] data_out_reg;
  reg [511 : 0] data_out_new;
  reg           data_out_valid_reg;
  reg           data_out_valid_new;
  reg           data_out_valid_we;
  reg           qr_ctr_reg;
  reg           qr_ctr_new;
  reg           qr_ctr_we;
  reg           qr_ctr_inc;
  reg           qr_ctr_rst;
  reg [3 : 0]   dr_ctr_reg;
  reg [3 : 0]   dr_ctr_new;
  reg           dr_ctr_we;
  reg           dr_ctr_inc;
  reg           dr_ctr_rst;
  reg [31 : 0]  block0_ctr_reg;
  reg [31 : 0]  block0_ctr_new;
  reg           block0_ctr_we;
  reg [31 : 0]  block1_ctr_reg;
  reg [31 : 0]  block1_ctr_new;
  reg           block1_ctr_we;
  reg           block_ctr_inc;
  reg           block_ctr_set;
  reg           ready_reg;
  reg           ready_new;
  reg           ready_we;
  reg [2 : 0]   chacha_ctrl_reg;
  reg [2 : 0]   chacha_ctrl_new;
  reg           chacha_ctrl_we;

  reg [31 : 0] init_state_word [0 : 15];
  reg init_state;
  reg update_state;
  reg update_output;

  // Wires for Quarter Round
  reg [31 : 0] qr0_a, qr0_b, qr0_c, qr0_d;
  wire [31 : 0] qr0_a_prim, qr0_b_prim, qr0_c_prim, qr0_d_prim;
  reg [31 : 0] qr1_a, qr1_b, qr1_c, qr1_d;
  wire [31 : 0] qr1_a_prim, qr1_b_prim, qr1_c_prim, qr1_d_prim;
  reg [31 : 0] qr2_a, qr2_b, qr2_c, qr2_d;
  wire [31 : 0] qr2_a_prim, qr2_b_prim, qr2_c_prim, qr2_d_prim;
  reg [31 : 0] qr3_a, qr3_b, qr3_c, qr3_d;
  wire [31 : 0] qr3_a_prim, qr3_b_prim, qr3_c_prim, qr3_d_prim;

  // Instantiations
  chacha_qr qr0(.a(qr0_a), .b(qr0_b), .c(qr0_c), .d(qr0_d), .a_prim(qr0_a_prim), .b_prim(qr0_b_prim), .c_prim(qr0_c_prim), .d_prim(qr0_d_prim));
  chacha_qr qr1(.a(qr1_a), .b(qr1_b), .c(qr1_c), .d(qr1_d), .a_prim(qr1_a_prim), .b_prim(qr1_b_prim), .c_prim(qr1_c_prim), .d_prim(qr1_d_prim));
  chacha_qr qr2(.a(qr2_a), .b(qr2_b), .c(qr2_c), .d(qr2_d), .a_prim(qr2_a_prim), .b_prim(qr2_b_prim), .c_prim(qr2_c_prim), .d_prim(qr2_d_prim));
  chacha_qr qr3(.a(qr3_a), .b(qr3_b), .c(qr3_c), .d(qr3_d), .a_prim(qr3_a_prim), .b_prim(qr3_b_prim), .c_prim(qr3_c_prim), .d_prim(qr3_d_prim));

  assign data_out = data_out_reg;
  assign data_out_valid = data_out_valid_reg;
  assign ready = ready_reg;

  // reg_update logic with FIX
  always @ (posedge clk) begin : reg_update
    integer i;
    if (!reset_n) begin
      for (i = 0 ; i < 16 ; i = i + 1) state_reg[i] <= 32'h0;
      data_out_reg <= 512'h0;
      data_out_valid_reg <= 0;
      qr_ctr_reg <= 0;
      dr_ctr_reg <= 0;
      block0_ctr_reg <= 32'h0;
      block1_ctr_reg <= 32'h0;
      chacha_ctrl_reg <= CTRL_IDLE;
      ready_reg <= 1; // FIX: Ready after reset
    end else begin
      if (state_we) begin
        for (i = 0 ; i < 16 ; i = i + 1) state_reg[i] <= state_new[i];
      end
      if (update_output) data_out_reg <= data_out_new;
      if (data_out_valid_we) data_out_valid_reg <= data_out_valid_new;
      if (qr_ctr_we) qr_ctr_reg <= qr_ctr_new;
      if (dr_ctr_we) dr_ctr_reg <= dr_ctr_new;
      if (block0_ctr_we) block0_ctr_reg <= block0_ctr_new;
      if (block1_ctr_we) block1_ctr_reg <= block1_ctr_new;
      if (ready_we) ready_reg <= ready_new;
      if (chacha_ctrl_we) chacha_ctrl_reg <= chacha_ctrl_new;
    end
  end

  // init_state_logic
  always @* begin : init_state_logic
    reg [31 : 0] k0, k1, k2, k3, k4, k5, k6, k7;
    k0 = l2b(key[255:224]); k1 = l2b(key[223:192]); k2 = l2b(key[191:160]); k3 = l2b(key[159:128]);
    k4 = l2b(key[127:96]); k5 = l2b(key[95:64]); k6 = l2b(key[63:32]); k7 = l2b(key[31:0]);
    init_state_word[04] = k0; init_state_word[05] = k1; init_state_word[06] = k2; init_state_word[07] = k3;
    init_state_word[12] = block0_ctr_reg; init_state_word[13] = block1_ctr_reg;
    init_state_word[14] = l2b(iv[63:32]); init_state_word[15] = l2b(iv[31:0]);
    if (keylen) begin
      init_state_word[00] = SIGMA0; init_state_word[01] = SIGMA1; init_state_word[02] = SIGMA2; init_state_word[03] = SIGMA3;
      init_state_word[08] = k4; init_state_word[09] = k5; init_state_word[10] = k6; init_state_word[11] = k7;
    end else begin
      init_state_word[00] = TAU0; init_state_word[01] = TAU1; init_state_word[02] = TAU2; init_state_word[03] = TAU3;
      init_state_word[08] = k0; init_state_word[09] = k1; init_state_word[10] = k2; init_state_word[11] = k3;
    end
  end

  // state_logic
  always @* begin : state_logic
    integer i;
    for (i = 0 ; i < 16 ; i = i + 1) state_new[i] = 32'h0;
    state_we = 0; qr0_a = 0; qr0_b = 0; qr0_c = 0; qr0_d = 0;
    qr1_a = 0; qr1_b = 0; qr1_c = 0; qr1_d = 0;
    qr2_a = 0; qr2_b = 0; qr2_c = 0; qr2_d = 0;
    qr3_a = 0; qr3_b = 0; qr3_c = 0; qr3_d = 0;
    if (init_state) begin
      for (i = 0 ; i < 16 ; i = i + 1) state_new[i] = init_state_word[i];
      state_we = 1;
    end
    if (update_state) begin
      state_we = 1;
      case (qr_ctr_reg)
        QR0: begin
          qr0_a = state_reg[00]; qr0_b = state_reg[04]; qr0_c = state_reg[08]; qr0_d = state_reg[12];
          qr1_a = state_reg[01]; qr1_b = state_reg[05]; qr1_c = state_reg[09]; qr1_d = state_reg[13];
          qr2_a = state_reg[02]; qr2_b = state_reg[06]; qr2_c = state_reg[10]; qr2_d = state_reg[14];
          qr3_a = state_reg[03]; qr3_b = state_reg[07]; qr3_c = state_reg[11]; qr3_d = state_reg[15];
          state_new[00] = qr0_a_prim; state_new[04] = qr0_b_prim; state_new[08] = qr0_c_prim; state_new[12] = qr0_d_prim;
          state_new[01] = qr1_a_prim; state_new[05] = qr1_b_prim; state_new[09] = qr1_c_prim; state_new[13] = qr1_d_prim;
          state_new[02] = qr2_a_prim; state_new[06] = qr2_b_prim; state_new[10] = qr2_c_prim; state_new[14] = qr2_d_prim;
          state_new[03] = qr3_a_prim; state_new[07] = qr3_b_prim; state_new[11] = qr3_c_prim; state_new[15] = qr3_d_prim;
        end
        QR1: begin
          qr0_a = state_reg[00]; qr0_b = state_reg[05]; qr0_c = state_reg[10]; qr0_d = state_reg[15];
          qr1_a = state_reg[01]; qr1_b = state_reg[06]; qr1_c = state_reg[11]; qr1_d = state_reg[12];
          qr2_a = state_reg[02]; qr2_b = state_reg[07]; qr2_c = state_reg[08]; qr2_d = state_reg[13];
          qr3_a = state_reg[03]; qr3_b = state_reg[04]; qr3_c = state_reg[09]; qr3_d = state_reg[14];
          state_new[00] = qr0_a_prim; state_new[05] = qr0_b_prim; state_new[10] = qr0_c_prim; state_new[15] = qr0_d_prim;
          state_new[01] = qr1_a_prim; state_new[06] = qr1_b_prim; state_new[11] = qr1_c_prim; state_new[12] = qr1_d_prim;
          state_new[02] = qr2_a_prim; state_new[07] = qr2_b_prim; state_new[08] = qr2_c_prim; state_new[13] = qr2_d_prim;
          state_new[03] = qr3_a_prim; state_new[04] = qr3_b_prim; state_new[09] = qr3_c_prim; state_new[14] = qr3_d_prim;
        end
      endcase
    end
  end

  // data_out_logic
  always @* begin : data_out_logic
    integer i;
    reg [31 : 0] msb_s [0 : 15];
    reg [31 : 0] lsb_s [0 : 15];
    for (i = 0 ; i < 16 ; i = i + 1) begin
      msb_s[i] = init_state_word[i] + state_reg[i];
      lsb_s[i] = l2b(msb_s[i]); // Note: In original it was msb_block_state
    end
    // Simpler XOR logic for output
    data_out_new = data_in ^ {lsb_s[0],lsb_s[1],lsb_s[2],lsb_s[3],lsb_s[4],lsb_s[5],lsb_s[6],lsb_s[7],lsb_s[8],lsb_s[9],lsb_s[10],lsb_s[11],lsb_s[12],lsb_s[13],lsb_s[14],lsb_s[15]};
  end

  // Counters
  always @* begin : qr_ctr
    qr_ctr_new = 0; qr_ctr_we = 0;
    if (qr_ctr_rst) begin qr_ctr_new = 0; qr_ctr_we = 1; end
    if (qr_ctr_inc) begin qr_ctr_new = qr_ctr_reg + 1; qr_ctr_we = 1; end
  end
  always @* begin : dr_ctr
    dr_ctr_new = 0; dr_ctr_we = 0;
    if (dr_ctr_rst) begin dr_ctr_new = 0; dr_ctr_we = 1; end
    if (dr_ctr_inc) begin dr_ctr_new = dr_ctr_reg + 1; dr_ctr_we = 1; end
  end
  always @* begin : block_ctr
    block0_ctr_new = 0; block1_ctr_new = 0; block0_ctr_we = 0; block1_ctr_we = 0;
    if (block_ctr_set) begin block0_ctr_new = ctr[31:0]; block1_ctr_new = ctr[63:32]; block0_ctr_we = 1; block1_ctr_we = 1; end
    if (block_ctr_inc) begin block0_ctr_new = block0_ctr_reg + 1; block0_ctr_we = 1; if (block0_ctr_reg == 32'hffffffff) begin block1_ctr_new = block1_ctr_reg+1; block1_ctr_we=1; end end
  end

  // FSM Control
  always @* begin : chacha_ctrl_fsm
    init_state = 0; update_state = 0; update_output = 0; qr_ctr_inc = 0; qr_ctr_rst = 0;
    dr_ctr_inc = 0; dr_ctr_rst = 0; block_ctr_inc = 0; block_ctr_set = 0;
    ready_new = 0; ready_we = 0; data_out_valid_new = 0; data_out_valid_we = 0;
    chacha_ctrl_new = CTRL_IDLE; chacha_ctrl_we = 0;
    case (chacha_ctrl_reg)
      CTRL_IDLE: if (init) begin block_ctr_set = 1; ready_new = 0; ready_we = 1; chacha_ctrl_new = CTRL_INIT; chacha_ctrl_we = 1; end
      CTRL_INIT: begin init_state = 1; qr_ctr_rst = 1; dr_ctr_rst = 1; chacha_ctrl_new = CTRL_ROUNDS; chacha_ctrl_we = 1; end
      CTRL_ROUNDS: begin update_state = 1; qr_ctr_inc = 1; if (qr_ctr_reg == QR1) begin dr_ctr_inc = 1; if (dr_ctr_reg == (rounds[4:1] - 1)) begin chacha_ctrl_new = CTRL_FINALIZE; chacha_ctrl_we = 1; end end end
      CTRL_FINALIZE: begin ready_new = 1; ready_we = 1; update_output = 1; data_out_valid_new = 1; data_out_valid_we = 1; chacha_ctrl_new = CTRL_DONE; chacha_ctrl_we = 1; end
      CTRL_DONE: if (init) begin ready_new = 0; ready_we = 1; data_out_valid_new = 0; data_out_valid_we = 1; block_ctr_set = 1; chacha_ctrl_new = CTRL_INIT; chacha_ctrl_we = 1; end
                 else if (next) begin ready_new = 0; ready_we = 1; data_out_valid_new = 0; data_out_valid_we = 1; block_ctr_inc = 1; chacha_ctrl_new = CTRL_INIT; chacha_ctrl_we = 1; end
    endcase
  end

endmodule