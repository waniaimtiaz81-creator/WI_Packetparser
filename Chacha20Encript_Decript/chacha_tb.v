`timescale 1ns / 1ps
module chacha_tb();
    reg clk;
    reg reset_n;
    reg cs;
	 
    reg we;
    reg [7:0]  addr;
    reg [31:0] write_data;
    wire [31:0] read_data;
    integer i;

    // Ciphertext store karne ke liye
    reg [31:0] cipher_store [0:15];

    chacha uut (
        .clk(clk), .reset_n(reset_n),
        .cs(cs), .we(we),
        .addr(addr), .write_data(write_data),
        .read_data(read_data)
    );

    always #5 clk = ~clk;

    // Write task
    task reg_write(input [7:0] a, input [31:0] d);
        begin
            addr = a;
            write_data = d;
            cs = 1; we = 1;
            @(posedge clk);
            #1;
            cs = 0; we = 0;
            @(posedge clk);
        end
    endtask

    // Ready polling task
    task wait_ready;
        integer timeout;
        begin
            timeout = 0;
            cs = 1; we = 0; addr = 8'h09;
            @(posedge clk);
            #1;
            while (read_data[0] == 0) begin
                @(posedge clk);
                #1;
                timeout = timeout + 1;
                if (timeout > 500) begin
                    $display("ERROR: Timeout!");
                    $finish;
                end
            end
            cs = 0;
            $display("Core Ready after %0d cycles", timeout);
        end
    endtask

    initial begin
        clk = 0; reset_n = 0;
        cs = 0; we = 0;
        addr = 0; write_data = 0;

        repeat(4) @(posedge clk);
        reset_n = 1;
        repeat(2) @(posedge clk);

        // =============================================
        // STEP 1: ENCRYPTION
        // Plaintext = "I AM WANIA" (64 bytes, zero padded)
        // =============================================
        $display("=========================================");
        $display("   STEP 1: ENCRYPTION");
        $display("   Plaintext = I AM WANIA");
        $display("=========================================");

        // Key length: 256-bit
        reg_write(8'h0a, 32'h00000001);
        // Rounds: 20
        reg_write(8'h0b, 32'h00000014);

        // Key
        reg_write(8'h10, 32'h03020100);
        reg_write(8'h11, 32'h07060504);
        reg_write(8'h12, 32'h0b0a0908);
        reg_write(8'h13, 32'h0f0e0d0c);
        reg_write(8'h14, 32'h13121110);
        reg_write(8'h15, 32'h17161514);
        reg_write(8'h16, 32'h1b1a1918);
        reg_write(8'h17, 32'h1f1e1d1c);

        // IV
        reg_write(8'h20, 32'h00000000);
        reg_write(8'h21, 32'h00000009);

        // ------------------------------------------------
        // Plaintext = "I AM WANIA" + zero padding
        // I=49 space=20 A=41 M=4d space=20 W=57 A=41 N=4e I=49 A=41
        // Word[00] = 0x4d412049  ("I AM")
        // Word[01] = 0x4e415720  (" WAN")
        // Word[02] = 0x00004149  ("IA\0\0")
        // Word[03..15] = 0x00000000
        // ------------------------------------------------
        $display("Plaintext Words:");
        $display("  Word[00] = 0x4d412049  (I AM)");
        $display("  Word[01] = 0x4e415720  ( WAN)");
        $display("  Word[02] = 0x00004149  (IA)  ");
        $display("  Word[03-15] = 0x00000000 (padding)");

        reg_write(8'h40, 32'h4d412049);  // "I AM"
        reg_write(8'h41, 32'h4e415720);  // " WAN"
        reg_write(8'h42, 32'h00004149);  // "IA"
        reg_write(8'h43, 32'h00000000);
        reg_write(8'h44, 32'h00000000);
        reg_write(8'h45, 32'h00000000);
        reg_write(8'h46, 32'h00000000);
        reg_write(8'h47, 32'h00000000);
        reg_write(8'h48, 32'h00000000);
        reg_write(8'h49, 32'h00000000);
        reg_write(8'h4a, 32'h00000000);
        reg_write(8'h4b, 32'h00000000);
        reg_write(8'h4c, 32'h00000000);
        reg_write(8'h4d, 32'h00000000);
        reg_write(8'h4e, 32'h00000000);
        reg_write(8'h4f, 32'h00000000);

        // Init
        reg_write(8'h08, 32'h00000001);
        reg_write(8'h08, 32'h00000000);

        wait_ready;

        // Ciphertext read + store
        $display("--- Ciphertext Output ---");
        for (i = 0; i < 16; i = i+1) begin
            addr = 8'h80 + i[7:0];
            cs = 1; we = 0;
            @(posedge clk);
            #1;
            cipher_store[i] = read_data;
            $display("  cipher[%02d] = 0x%08h", i, read_data);
        end
        cs = 0;

        // =============================================
        // STEP 2: DECRYPTION
        // Ciphertext wapis data_in mein → plaintext milega
        // =============================================
        $display("\n=========================================");
        $display("   STEP 2: DECRYPTION");
        $display("   (Same Key + Same IV + Ciphertext In)");
        $display("=========================================");

        // Reset core
        reset_n = 0;
        repeat(4) @(posedge clk);
        reset_n = 1;
        repeat(2) @(posedge clk);

        // Same Key
        reg_write(8'h0a, 32'h00000001);
        reg_write(8'h0b, 32'h00000014);
        reg_write(8'h10, 32'h03020100);
        reg_write(8'h11, 32'h07060504);
        reg_write(8'h12, 32'h0b0a0908);
        reg_write(8'h13, 32'h0f0e0d0c);
        reg_write(8'h14, 32'h13121110);
        reg_write(8'h15, 32'h17161514);
        reg_write(8'h16, 32'h1b1a1918);
        reg_write(8'h17, 32'h1f1e1d1c);

        // Same IV
        reg_write(8'h20, 32'h00000000);
        reg_write(8'h21, 32'h00000009);

        // Data_in = Ciphertext
        $display("Ciphertext ko data_in mein dal rahe hain...");
        for (i = 0; i < 16; i = i+1)
            reg_write(8'h40 + i[7:0], cipher_store[i]);

        // Init
        reg_write(8'h08, 32'h00000001);
        reg_write(8'h08, 32'h00000000);

        wait_ready;

        // Decrypted output
        $display("--- Decrypted Output ---");
        $display("(Expected: I AM WANIA + zeros)");
        for (i = 0; i < 16; i = i+1) begin
            addr = 8'h80 + i[7:0];
            cs = 1; we = 0;
            @(posedge clk);
            #1;
            $display("  plain[%02d] = 0x%08h", i, read_data);
        end
        cs = 0;

        $display("\n=========================================");
        $display("  plain[00] = 0x4d412049 → I AM");
        $display("  plain[01] = 0x4e415720 →  WAN");
        $display("  plain[02] = 0x00004149 → IA  ");
        $display("  plain[03-15] = 0x00000000");
        $display("  Agar ye match kare to SUCCESS! ✅");
        $display("=========================================");
        $finish;
    end
endmodule