`default_nettype none

//==============================================================================
// ChaCha Stream Cipher Core
//==============================================================================
// Implements the ChaCha stream cipher for encryption/decryption operations
// Supports both 128-bit and 256-bit keys with configurable number of rounds
//==============================================================================

module chacha_core (
  // Clock and reset
  input  wire         clk           ,
  input  wire         reset_n       ,
  // Control signals
  input  wire         init          , // Initialize new block
  input  wire         next          , // Request next block
  // Key and configuration
  input  wire [255:0] key           , // Encryption key (256-bit)
  input  wire         keylen        , // 0: 128-bit, 1: 256-bit
  input  wire [ 63:0] iv            , // Initialization vector
  input  wire [ 63:0] ctr           , // Initial block counter
  input  wire [  4:0] rounds        , // Number of rounds (must be even)
  // Data interface
  input  wire [511:0] data_in       , // Input data block (512 bits)
  output wire [511:0] data_out      , // Output data block (XOR with keystream)
  output wire         data_out_valid, // Output data valid flag
  output wire         ready           // Ready for next operation
);

//==============================================================================
// Constants
//==============================================================================

// Quarter-round state encoding
  localparam QR_STATE_0 = 0; // Column rounds
  localparam QR_STATE_1 = 1; // Diagonal rounds

// ChaCha constants (little-endian format)
// "expand 32-byte k" for 256-bit key
  localparam SIGMA0 = 32'h61707865,
    SIGMA1 = 32'h3320646e,
    SIGMA2 = 32'h79622d32,
    SIGMA3 = 32'h6b206574;

// "expand 16-byte k" for 128-bit key
  localparam TAU0   = 32'h61707865,
    TAU1   = 32'h3120646e,
    TAU2   = 32'h79622d36,
    TAU3   = 32'h6b206574;

// FSM states
  localparam ST_IDLE     = 3'h0,
    ST_INIT     = 3'h1,
    ST_ROUNDS   = 3'h2,
    ST_FINALIZE = 3'h3,
    ST_DONE     = 3'h4;

//==============================================================================
// Helper Functions
//==============================================================================

// Convert from little-endian to big-endian byte order
  function [31:0] le_to_be(input [31:0] word);
    le_to_be = {word[7:0], word[15:8], word[23:16], word[31:24]};
  endfunction

//==============================================================================
// Internal Registers
//==============================================================================

// ChaCha state matrix (16 x 32-bit words)
  reg [31:0] state             [0:15];
  reg [31:0] state_next        [0:15];
  reg        state_write_enable      ;

// Output data buffer
  reg [511:0] data_out_reg ;
  reg [511:0] data_out_next;

// Output valid flag
  reg data_out_valid_reg  ;
  reg data_out_valid_next ;
  reg data_out_valid_write;

// Quarter-round counter (0 or 1)
  reg qr_counter_reg      ;
  reg qr_counter_next     ;
  reg qr_counter_write    ;
  reg qr_counter_increment;
  reg qr_counter_reset    ;

// Double-round counter (0 to rounds/2 - 1)
  reg [3:0] dr_counter_reg      ;
  reg [3:0] dr_counter_next     ;
  reg       dr_counter_write    ;
  reg       dr_counter_increment;
  reg       dr_counter_reset    ;

// Block counter (64-bit split into two 32-bit halves)
  reg [31:0] block_counter_low_reg   ;
  reg [31:0] block_counter_low_next  ;
  reg        block_counter_low_write ;
  reg [31:0] block_counter_high_reg  ;
  reg [31:0] block_counter_high_next ;
  reg        block_counter_high_write;
  reg        block_counter_increment ;
  reg        block_counter_set       ;

// Ready flag
  reg ready_reg  ;
  reg ready_next ;
  reg ready_write;

// FSM control register
  reg [2:0] fsm_state_reg  ;
  reg [2:0] fsm_state_next ;
  reg       fsm_state_write;

// Quarter-round input signals
  reg [31:0] qr0_a_in, qr0_b_in, qr0_c_in, qr0_d_in;
  reg [31:0] qr1_a_in, qr1_b_in, qr1_c_in, qr1_d_in;
  reg [31:0] qr2_a_in, qr2_b_in, qr2_c_in, qr2_d_in;
  reg [31:0] qr3_a_in, qr3_b_in, qr3_c_in, qr3_d_in;

//==============================================================================
// Quarter-round Module Instantiation (4 parallel instances)
//==============================================================================

// Column round 0
  wire [31:0] qr0_a_out, qr0_b_out, qr0_c_out, qr0_d_out;
  chacha_qr qr0_inst (
    .a     (qr0_a_in ),
    .b     (qr0_b_in ),
    .c     (qr0_c_in ),
    .d     (qr0_d_in ),
    .a_prim(qr0_a_out),
    .b_prim(qr0_b_out),
    .c_prim(qr0_c_out),
    .d_prim(qr0_d_out)
  );

// Column round 1
  wire [31:0] qr1_a_out, qr1_b_out, qr1_c_out, qr1_d_out;
  chacha_qr qr1_inst (
    .a     (qr1_a_in ),
    .b     (qr1_b_in ),
    .c     (qr1_c_in ),
    .d     (qr1_d_in ),
    .a_prim(qr1_a_out),
    .b_prim(qr1_b_out),
    .c_prim(qr1_c_out),
    .d_prim(qr1_d_out)
  );

// Column round 2
  wire [31:0] qr2_a_out, qr2_b_out, qr2_c_out, qr2_d_out;
  chacha_qr qr2_inst (
    .a     (qr2_a_in ),
    .b     (qr2_b_in ),
    .c     (qr2_c_in ),
    .d     (qr2_d_in ),
    .a_prim(qr2_a_out),
    .b_prim(qr2_b_out),
    .c_prim(qr2_c_out),
    .d_prim(qr2_d_out)
  );

// Column round 3
  wire [31:0] qr3_a_out, qr3_b_out, qr3_c_out, qr3_d_out;
  chacha_qr qr3_inst (
    .a     (qr3_a_in ),
    .b     (qr3_b_in ),
    .c     (qr3_c_in ),
    .d     (qr3_d_in ),
    .a_prim(qr3_a_out),
    .b_prim(qr3_b_out),
    .c_prim(qr3_c_out),
    .d_prim(qr3_d_out)
  );


//==============================================================================
// Output Assignments
//==============================================================================

  assign data_out       = data_out_reg;
  assign data_out_valid = data_out_valid_reg;
  assign ready          = ready_reg;

//==============================================================================
// Register Update Logic
//==============================================================================

  always @(posedge clk) begin
    integer i;

    if (!reset_n) begin
      // Reset all registers
      for (i = 0; i < 16; i = i + 1)
        state[i] <= 32'h0;

      data_out_reg           <= 512'h0;
      data_out_valid_reg     <= 1'b0;
      qr_counter_reg         <= QR_STATE_0;
      dr_counter_reg         <= 4'h0;
      block_counter_low_reg  <= 32'h0;
      block_counter_high_reg <= 32'h0;
      fsm_state_reg          <= ST_IDLE;
      ready_reg              <= 1'b1;
    end 
    else begin
      // State matrix update
      if (state_write_enable) begin
        for (i = 0; i < 16; i = i + 1)
          state[i] <= state_next[i];
      end

      // Output data update
      data_out_reg <= data_out_next;

      // Output valid flag update
      if (data_out_valid_write)
        data_out_valid_reg <= data_out_valid_next;
      else 
        data_out_valid_reg <= 0;

      // Quarter-round counter update
      if (qr_counter_write)
        qr_counter_reg <= qr_counter_next;

      // Double-round counter update
      if (dr_counter_write)
        dr_counter_reg <= dr_counter_next;

      // Block counter update
      if (block_counter_low_write)
        block_counter_low_reg <= block_counter_low_next;
      if (block_counter_high_write)
        block_counter_high_reg <= block_counter_high_next;

      // Ready flag update
      if (ready_write)
        ready_reg <= ready_next;

      // FSM state update
      if (fsm_state_write)
        fsm_state_reg <= fsm_state_next;
    end
  end

//==============================================================================
// Initial State Generation
//==============================================================================

// Generate the initial state matrix based on key length
  reg [31:0] init_state_words[0:15];

  always @* begin
    integer i;
    reg [31:0] key_words[0:7];

    // Convert key from big-endian to little-endian format
    key_words[0] = le_to_be(key[255:224]);
    key_words[1] = le_to_be(key[223:192]);
    key_words[2] = le_to_be(key[191:160]);
    key_words[3] = le_to_be(key[159:128]);
    key_words[4] = le_to_be(key[127:96]);
    key_words[5] = le_to_be(key[95:64]);
    key_words[6] = le_to_be(key[63:32]);
    key_words[7] = le_to_be(key[31:0]);

    // Set key-dependent words based on key length
    if (keylen) begin
      // 256-bit key
      init_state_words[0]  = SIGMA0;
      init_state_words[1]  = SIGMA1;
      init_state_words[2]  = SIGMA2;
      init_state_words[3]  = SIGMA3;
      init_state_words[8]  = key_words[4];
      init_state_words[9]  = key_words[5];
      init_state_words[10] = key_words[6];
      init_state_words[11] = key_words[7];
    end else begin
      // 128-bit key
      init_state_words[0]  = TAU0;
      init_state_words[1]  = TAU1;
      init_state_words[2]  = TAU2;
      init_state_words[3]  = TAU3;
      init_state_words[8]  = key_words[0];
      init_state_words[9]  = key_words[1];
      init_state_words[10] = key_words[2];
      init_state_words[11] = key_words[3];
    end

    // Set common words
    init_state_words[4]  = key_words[0];
    init_state_words[5]  = key_words[1];
    init_state_words[6]  = key_words[2];
    init_state_words[7]  = key_words[3];
    init_state_words[12] = block_counter_low_reg;
    init_state_words[13] = block_counter_high_reg;
    init_state_words[14] = le_to_be(iv[63:32]);
    init_state_words[15] = le_to_be(iv[31:0]);
  end

//==============================================================================
// State Matrix Update Logic (Quarter Rounds)
//==============================================================================

// Control signals
  reg init_state_trigger   ;
  reg update_state_trigger ;
  reg update_output_trigger;

  always @* begin
    integer i;

    // Default assignments
    for (i = 0; i < 16; i = i + 1)
      state_next[i] = 32'h0;
    state_write_enable = 1'b0;

    qr0_a_in = 32'h0; qr0_b_in = 32'h0; qr0_c_in = 32'h0; qr0_d_in = 32'h0;
    qr1_a_in = 32'h0; qr1_b_in = 32'h0; qr1_c_in = 32'h0; qr1_d_in = 32'h0;
    qr2_a_in = 32'h0; qr2_b_in = 32'h0; qr2_c_in = 32'h0; qr2_d_in = 32'h0;
    qr3_a_in = 32'h0; qr3_b_in = 32'h0; qr3_c_in = 32'h0; qr3_d_in = 32'h0;

    // Initialize state from initial values
    if (init_state_trigger) begin
      for (i = 0; i < 16; i = i + 1)
        state_next[i] = init_state_words[i];
      state_write_enable = 1'b1;
    end

    // Update state using quarter rounds
    if (update_state_trigger) begin
      state_write_enable = 1'b1;

      case (qr_counter_reg)
        QR_STATE_0 : begin  // Column rounds
          // Column 0
          qr0_a_in = state[0];  qr0_b_in = state[4];
          qr0_c_in = state[8];  qr0_d_in = state[12];

          // Column 1
          qr1_a_in = state[1];  qr1_b_in = state[5];
          qr1_c_in = state[9];  qr1_d_in = state[13];

          // Column 2
          qr2_a_in = state[2];  qr2_b_in = state[6];
          qr2_c_in = state[10]; qr2_d_in = state[14];

          // Column 3
          qr3_a_in = state[3];  qr3_b_in = state[7];
          qr3_c_in = state[11]; qr3_d_in = state[15];

          // Store results
          state_next[0]  = qr0_a_out; state_next[4] = qr0_b_out;
          state_next[8]  = qr0_c_out; state_next[12] = qr0_d_out;
          state_next[1]  = qr1_a_out; state_next[5] = qr1_b_out;
          state_next[9]  = qr1_c_out; state_next[13] = qr1_d_out;
          state_next[2]  = qr2_a_out; state_next[6] = qr2_b_out;
          state_next[10] = qr2_c_out; state_next[14] = qr2_d_out;
          state_next[3]  = qr3_a_out; state_next[7] = qr3_b_out;
          state_next[11] = qr3_c_out; state_next[15] = qr3_d_out;
        end

        QR_STATE_1 : begin  // Diagonal rounds
          // Diagonal 0
          qr0_a_in = state[0];  qr0_b_in = state[5];
          qr0_c_in = state[10]; qr0_d_in = state[15];

          // Diagonal 1
          qr1_a_in = state[1];  qr1_b_in = state[6];
          qr1_c_in = state[11]; qr1_d_in = state[12];

          // Diagonal 2
          qr2_a_in = state[2];  qr2_b_in = state[7];
          qr2_c_in = state[8];  qr2_d_in = state[13];

          // Diagonal 3
          qr3_a_in = state[3];  qr3_b_in = state[4];
          qr3_c_in = state[9];  qr3_d_in = state[14];

          // Store results
          state_next[0]  = qr0_a_out; state_next[5] = qr0_b_out;
          state_next[10] = qr0_c_out; state_next[15] = qr0_d_out;
          state_next[1]  = qr1_a_out; state_next[6] = qr1_b_out;
          state_next[11] = qr1_c_out; state_next[12] = qr1_d_out;
          state_next[2]  = qr2_a_out; state_next[7] = qr2_b_out;
          state_next[8]  = qr2_c_out; state_next[13] = qr2_d_out;
          state_next[3]  = qr3_a_out; state_next[4] = qr3_b_out;
          state_next[9]  = qr3_c_out; state_next[14] = qr3_d_out;
        end
      endcase
    end
  end

//==============================================================================
// Output Data Generation
//==============================================================================

  always @* begin
    integer i;
    reg [31:0] temp_state[0:15];
    reg [31:0] be_state[0:15];
    reg [511:0] keystream;

    // Add initial state to final state
    for (i = 0; i < 16; i = i + 1)
      temp_state[i] = init_state_words[i] + state[i];

    // Convert to big-endian format
    for (i = 0; i < 16; i = i + 1)
      be_state[i] = le_to_be(temp_state[i]);

    // Combine into 512-bit keystream block
    keystream = {be_state[0],  be_state[1],  be_state[2],  be_state[3],
      be_state[4],  be_state[5],  be_state[6],  be_state[7],
      be_state[8],  be_state[9],  be_state[10], be_state[11],
      be_state[12], be_state[13], be_state[14], be_state[15]};

    // XOR with input data to produce output
    data_out_next = data_in ^ keystream;
  end

//==============================================================================
// Counter Logic
//==============================================================================

// Quarter-round counter (toggles between 0 and 1)
  always @* begin
    qr_counter_next  = 1'b0;
    qr_counter_write = 1'b0;

    if (qr_counter_reset) begin
      qr_counter_next  = QR_STATE_0;
      qr_counter_write = 1'b1;
    end

    if (qr_counter_increment) begin
      qr_counter_next  = ~qr_counter_reg;
      qr_counter_write = 1'b1;
    end
  end

// Double-round counter (increments after each complete round)
  always @* begin
    dr_counter_next  = 4'h0;
    dr_counter_write = 1'b0;

    if (dr_counter_reset) begin
      dr_counter_next  = 4'h0;
      dr_counter_write = 1'b1;
    end

    if (dr_counter_increment) begin
      dr_counter_next  = dr_counter_reg + 1'b1;
      dr_counter_write = 1'b1;
    end
  end

// Block counter (64-bit counter for generating multiple blocks)
  always @* begin
    block_counter_low_next   = 32'h0;
    block_counter_low_write  = 1'b0;
    block_counter_high_next  = 32'h0;
    block_counter_high_write = 1'b0;

    // Set initial counter value
    if (block_counter_set) begin
      block_counter_low_next   = ctr[31:0];
      block_counter_low_write  = 1'b1;
      block_counter_high_next  = ctr[63:32];
      block_counter_high_write = 1'b1;
    end

    // Increment counter (handle carry from low to high)
    if (block_counter_increment) begin
      block_counter_low_next  = block_counter_low_reg + 1;
      block_counter_low_write = 1'b1;

      if (block_counter_low_reg == 32'hFFFFFFFF) begin
        block_counter_high_next  = block_counter_high_reg + 1;
        block_counter_high_write = 1'b1;
      end
    end
  end

//==============================================================================
// Main FSM Control Logic
//==============================================================================

  always @* begin
    // Default assignments
    init_state_trigger      = 1'b0;
    update_state_trigger    = 1'b0;
    update_output_trigger   = 1'b0;
    qr_counter_increment    = 1'b0;
    qr_counter_reset        = 1'b0;
    dr_counter_increment    = 1'b0;
    dr_counter_reset        = 1'b0;
    block_counter_increment = 1'b0;
    block_counter_set       = 1'b0;
    ready_next              = 1'b0;
    ready_write             = 1'b0;
    data_out_valid_next     = 1'b0;
    data_out_valid_write    = 1'b0;
    fsm_state_next          = ST_IDLE;
    fsm_state_write         = 1'b0;

    if (!reset_n) begin
      fsm_state_next  = ST_IDLE;
      fsm_state_write = 1'b1;
    end else begin
      case (fsm_state_reg)
        ST_IDLE : begin
          if (init) begin
            block_counter_set = 1'b1;
            ready_next        = 1'b0;
            ready_write       = 1'b1;
            fsm_state_next    = ST_INIT;
            fsm_state_write   = 1'b1;
          end
        end

        ST_INIT : begin
          init_state_trigger = 1'b1;
          qr_counter_reset   = 1'b1;
          dr_counter_reset   = 1'b1;
          fsm_state_next     = ST_ROUNDS;
          fsm_state_write    = 1'b1;
        end

        ST_ROUNDS : begin
          update_state_trigger = 1'b1;
          qr_counter_increment = 1'b1;

          // After completing both quarter-rounds (column + diagonal)
          if (qr_counter_reg == QR_STATE_1) begin
            dr_counter_increment = 1'b1;

            // Check if all rounds are complete
            if (dr_counter_reg == (rounds[4:1] - 1)) begin
              fsm_state_next  = ST_FINALIZE;
              fsm_state_write = 1'b1;
            end
          end
        end

        ST_FINALIZE : begin
          ready_next            = 1'b1;
          ready_write           = 1'b1;
          update_output_trigger = 1'b1;
          data_out_valid_next   = 1'b1;
          data_out_valid_write  = 1'b1;
          fsm_state_next        = ST_DONE;
          fsm_state_write       = 1'b1;
        end

        ST_DONE : begin
          if (init) begin
            // New block requested immediately
            ready_next           = 1'b0;
            ready_write          = 1'b1;
            data_out_valid_next  = 1'b0;
            data_out_valid_write = 1'b1;
            block_counter_set    = 1'b1;
            fsm_state_next       = ST_INIT;
            fsm_state_write      = 1'b1;
          end else if (next) begin
            // Generate next block
            ready_next              = 1'b0;
            ready_write             = 1'b1;
            data_out_valid_next     = 1'b0;
            data_out_valid_write    = 1'b1;
            block_counter_increment = 1'b1;
            fsm_state_next          = ST_INIT;
            fsm_state_write         = 1'b1;
          end
        end
      endcase
    end
  end

endmodule