`timescale 1ns/1ps

module uart_tb;

    reg clk;
    reg reset;
    reg rx;
    wire tx;

    // Test patterns
    reg [7:0] expected_data1 = 8'b10101010; // 'A' (Aapka logic +1 karke 'B' dega)
    reg [7:0] expected_data2 = 8'b11001100;

    // Baud period calculation (9600 baud = ~104160 ns)
    localparam BAUD_PERIOD = 104160;

    // Instantiate uart_top
    uart_top uut (
        .clk(clk),
        .raw_reset(reset),
        .rx(rx),
        .tx(tx)
    );

    // Clock generation
    always #10 clk = ~clk;  // 50 MHz clock

    // Task to send byte serially on rx line (Verilog Task)
    task send_uart_byte;
        input [7:0] data;
        integer i;
        begin
            rx = 1;  // Idle
            #(BAUD_PERIOD);
            rx = 0;  // Start bit
            #(BAUD_PERIOD);
            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #(BAUD_PERIOD);
            end
            rx = 1;  // Stop bit
            #(BAUD_PERIOD);
        end
    endtask

    // Monitor logic
    reg prev_data_ready;
    always @(posedge clk) begin
        prev_data_ready <= uut.data_ready;
        if (uut.data_ready && !prev_data_ready) begin
            $display("[Time %0t] Data received on FPGA: %b (0x%h)", $time, uut.data_out, uut.data_out);
        end
    end

    // Simulation logic
    initial begin
        $dumpfile("uart_tb.vcd");
        $dumpvars(0, uart_tb);

        clk = 0;
        rx = 1;
        reset = 1;
        #200 reset = 0;

        // Sending first byte
        $display("Sending byte to FPGA: %b", expected_data1);
        send_uart_byte(expected_data1);

        // Wait for loopback processing
        #1500000;

        // Sending second byte
        $display("Sending byte to FPGA: %b", expected_data2);
        send_uart_byte(expected_data2);

        #1500000;

        $display("\n✅ Simulation complete.");
        $finish;
    end

endmodule