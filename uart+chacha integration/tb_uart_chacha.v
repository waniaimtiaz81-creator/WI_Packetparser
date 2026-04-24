`timescale 1ns/1ps
module tb_uart_chacha;
    reg clk, raw_reset, rx;
    wire tx;

    uart_top dut (.clk(clk), .raw_reset(raw_reset), .rx(rx), .tx(tx));

    always #10 clk = ~clk; // 50MHz

    task send_byte(input [7:0] d);
        integer j;
        begin
            rx = 0; #104160; // Start
            for (j=0; j<8; j=j+1) begin
                rx = d[j]; #104160;
            end
            rx = 1; #104160; // Stop
        end
    endtask

    initial begin
        clk = 0; raw_reset = 0; rx = 1;
        #200 raw_reset = 1; // Release reset
        #1000;

        $display("Sending 64 bytes of Plaintext...");
        repeat(64) send_byte(8'h41); // Sending 64 'A' characters

        $display("Waiting for Encrypted Output...");
        // Simulation time barha dein taake output nazar aaye
        #200000000; 
        $finish;
    end
endmodule