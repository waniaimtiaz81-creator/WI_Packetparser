`default_nettype none
`timescale 1ns/1ps

module tb_chacha_decrypt ();

  //--------------------------------------------------------------------------
  // Parameters
  //--------------------------------------------------------------------------
  localparam CLK_PERIOD = 10   ; // 100 MHz
  localparam ROUNDS     = 5'd20;

  //--------------------------------------------------------------------------
  // DUT signals
  //--------------------------------------------------------------------------
  reg clk, reset_n;

  // Encryption side
  reg          enc_init, enc_next;
  reg  [255:0] key           ;
  reg          keylen        ;
  reg  [ 63:0] iv, ctr;
  reg  [511:0] plaintext_in  ;
  wire [511:0] ciphertext_out;
  wire         enc_valid, enc_ready;

  // Decryption side
  reg          dec_init, dec_next;
  wire [511:0] plaintext_recovered;
  wire         dec_valid, dec_ready;

  //--------------------------------------------------------------------------
  // DUT Instantiation — Encryptor
  //--------------------------------------------------------------------------
  chacha_core enc_inst (
    .clk           (clk           ),
    .reset_n       (reset_n       ),
    .init          (enc_init      ),
    .next          (enc_next      ),
    .key           (key           ),
    .keylen        (keylen        ),
    .iv            (iv            ),
    .ctr           (ctr           ),
    .rounds        (ROUNDS        ),
    .data_in       (plaintext_in  ),
    .data_out      (ciphertext_out),
    .data_out_valid(enc_valid     ),
    .ready         (enc_ready     )
  );

  //--------------------------------------------------------------------------
  // DUT Instantiation — Decryptor
  //--------------------------------------------------------------------------
  chacha_core dec_inst (
    .clk           (clk                ),
    .reset_n       (reset_n            ),
    .init          (dec_init           ),
    .next          (dec_next           ),
    .key           (key                ),   // Same key
    .keylen        (keylen             ),
    .iv            (iv                 ),   // Same IV
    .ctr           (ctr                ),   // Same counter
    .rounds        (ROUNDS             ),
    .data_in       (ciphertext_out     ),   // Feed encrypted output in
    .data_out      (plaintext_recovered),
    .data_out_valid(dec_valid          ),
    .ready         (dec_ready          )
  );

  //--------------------------------------------------------------------------
  // Clock Generation
  //--------------------------------------------------------------------------
  initial clk = 0;
  always #(CLK_PERIOD/2) clk = ~clk;

  //--------------------------------------------------------------------------
  // Task: pulse a single-cycle signal
  //--------------------------------------------------------------------------
  task pulse(inout reg sig);
    begin
      @(posedge clk); #1;
      sig = 1'b1;
      @(posedge clk); #1;
      sig = 1'b0;
    end
  endtask

  //--------------------------------------------------------------------------
  // Task: wait for valid output
  //--------------------------------------------------------------------------
  task wait_valid(input valid_sig);
    begin
      wait(valid_sig == 1'b1);
      @(posedge clk);
    end
  endtask

  //--------------------------------------------------------------------------
  // Test Stimulus
  //--------------------------------------------------------------------------
  integer pass_count = 0;
  integer fail_count = 0;

  initial begin
    // Initialize signals
    reset_n      = 1'b0;
    enc_init     = 1'b0;
    enc_next     = 1'b0;
    dec_init     = 1'b0;
    dec_next     = 1'b0;
    key          = 256'h0;
    keylen       = 1'b1;   // 256-bit key
    iv           = 64'h0;
    ctr          = 64'h0;
    plaintext_in = 512'h0;

    // Hold reset for 5 cycles
    repeat(5) @(posedge clk);
    #1; reset_n = 1'b1;
    repeat(2) @(posedge clk);

    //------------------------------------------------------------------------
    // Test 1: Known-vector — all-zero key, IV, counter, plaintext
    //------------------------------------------------------------------------
    $display("\n--- Test 1: All-zero inputs ---");
    key          = 256'h0;
    iv           = 64'h0;
    ctr          = 64'h0;
    plaintext_in = 512'h0;
    run_roundtrip_test("Test 1");

    //------------------------------------------------------------------------
    // Test 2: Random-looking key and plaintext
    //------------------------------------------------------------------------
    $display("\n--- Test 2: Non-zero key and plaintext ---");
    key          = 256'hDEADBEEF_CAFEBABE_12345678_9ABCDEF0_FEDCBA98_76543210_0F1E2D3C_4B5A6978;
    iv           = 64'hAABBCCDD_EEFF0011;
    ctr          = 64'h0000_0000_0000_0001;
    plaintext_in = 512'hA5A5A5A5_5A5A5A5A_FFFFFFFF_00000000_12345678_DEADBEEF_CAFEBABE_ABCDEF01_10203040_50607080_90A0B0C0_D0E0F000_11223344_55667788_99AABBCC_DDEEFF00;
    run_roundtrip_test("Test 2");

    //------------------------------------------------------------------------
    // Test 3: Second block (next block counter)
    //------------------------------------------------------------------------
    $display("\n--- Test 3: Sequential blocks (next) ---");
    key          = 256'h0102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F20;
    iv           = 64'h0102030405060708;
    ctr          = 64'h0;
    plaintext_in = 512'hFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF;
    run_sequential_block_test("Test 3");

    //------------------------------------------------------------------------
    // Summary
    //------------------------------------------------------------------------
    $display("\n========================================");
    $display("RESULTS: %0d passed, %0d failed", pass_count, fail_count);
    $display("========================================\n");

    if (fail_count == 0)
      $display("ALL TESTS PASSED");
    else
      $display("SOME TESTS FAILED");

    $finish;
  end

  //--------------------------------------------------------------------------
  // Task: Single-block encrypt then decrypt, check recovery
  //--------------------------------------------------------------------------
  task run_roundtrip_test(input [63:0] test_name);
    reg [511:0] captured_cipher;
    reg [511:0] captured_plain;
    begin
      // --- Encrypt ---
      @(posedge clk); #1;
      enc_init = 1'b1;
      @(posedge clk); #1;
      enc_init = 1'b0;

      // Wait for encryption result
      @(posedge enc_valid);
      @(posedge clk); #1;
      captured_cipher = ciphertext_out;
      $display("[%s] Plaintext : %h", test_name, plaintext_in);
      $display("[%s] Ciphertext: %h", test_name, captured_cipher);

      // Verify ciphertext differs from plaintext (unless keystream is zero,
      // which is astronomically unlikely for non-trivial inputs)
      if (captured_cipher === plaintext_in && plaintext_in !== 512'h0)
        $display("[%s] WARNING: Ciphertext == Plaintext (check core)", test_name);

      // --- Decrypt ---
      repeat(2) @(posedge clk);
      @(posedge clk); #1;
      dec_init = 1'b1;
      @(posedge clk); #1;
      dec_init = 1'b0;

      // Wait for decryption result
      @(posedge dec_valid);
      @(posedge clk); #1;
      captured_plain = plaintext_recovered;
      $display("[%s] Recovered : %h", test_name, captured_plain);

      // Verify round-trip
      if (captured_plain === plaintext_in) begin
        $display("[%s] PASS: Decryption matches original plaintext", test_name);
        pass_count = pass_count + 1;
      end else begin
        $display("[%s] FAIL: Decryption mismatch!", test_name);
        $display("[%s]   Expected: %h", test_name, plaintext_in);
        $display("[%s]   Got     : %h", test_name, captured_plain);
        fail_count = fail_count + 1;
      end

      repeat(5) @(posedge clk);
    end
  endtask

  //--------------------------------------------------------------------------
  // Task: Multi-block sequential encrypt then decrypt
  //--------------------------------------------------------------------------
  task run_sequential_block_test(input [63:0] test_name);
    reg [511:0] cipher_blk0, cipher_blk1;
    reg [511:0] plain_blk0,  plain_blk1;
    begin
      //--- Encrypt block 0 ---
      @(posedge clk); #1; enc_init = 1'b1;
      @(posedge clk); #1; enc_init = 1'b0;
      @(posedge enc_valid); @(posedge clk); #1;
      cipher_blk0 = ciphertext_out;
      $display("[%s] Block0 cipher: %h", test_name, cipher_blk0);

      //--- Encrypt block 1 (next) ---
      @(posedge clk); #1; enc_next = 1'b1;
      @(posedge clk); #1; enc_next = 1'b0;
      @(posedge enc_valid); @(posedge clk); #1;
      cipher_blk1 = ciphertext_out;
      $display("[%s] Block1 cipher: %h", test_name, cipher_blk1);

      // Verify the two cipher blocks differ (different counter values)
      if (cipher_blk0 === cipher_blk1)
        $display("[%s] WARNING: Both cipher blocks identical — counter may not increment", test_name);

      repeat(5) @(posedge clk);

      //--- Decrypt block 0 ---
      // Override ciphertext_in for decryptor — driven by enc output,
      // so we use a simple two-step approach: init dec with block 0
      // (enc_inst output is still cipher_blk1 at this point, so we
      //  rely on plaintext_in trick: set plaintext_in to cipher block
      //  and re-encrypt, which equals decrypt)
      // For the testbench, we directly check that enc(dec(x)) = x
      // by feeding cipher_blk0 back through enc with same params.
      plaintext_in = cipher_blk0;
      @(posedge clk); #1; enc_init = 1'b1;
      @(posedge clk); #1; enc_init = 1'b0;
      @(posedge enc_valid); @(posedge clk); #1;
      plain_blk0 = ciphertext_out;

      // Restore original plaintext and check
      if (plain_blk0 === {512{1'b1}}) begin // original plaintext_in was all-F
        $display("[%s] Block0 PASS: Decrypt matches original", test_name);
        pass_count = pass_count + 1;
      end else begin
        $display("[%s] Block0 FAIL: Got %h", test_name, plain_blk0);
        fail_count = fail_count + 1;
      end

      repeat(5) @(posedge clk);
    end
  endtask

endmodule