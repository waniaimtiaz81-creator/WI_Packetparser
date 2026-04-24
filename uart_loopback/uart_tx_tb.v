`timescale 1ns/1ps

module uart_tx_tb;

    reg clk;
    reg reset;
    reg start;
    reg [7:0] data_in;
    wire tx;        
    wire busy;
    wire done;
    wire tick;

    wire rx;        
    wire [7:0] data_out;
    wire data_ready;
    wire rx_busy;

    // Baud Generator
    baud_gen #(.BAUD_DIV(10)) baud_inst (
        .clk(clk),
        .reset(reset),
        .tick(tick)
    );

    // UART Transmitter
    uart_tx tx_inst (
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .start(start),
        .data_in(data_in),
        .tx(tx),
        .busy(busy),
        .done(done)
    );

    // UART Receiver
    uart_rx rx_inst (
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .rx(rx),
        .data_out(data_out),
        .data_ready(data_ready),
        .busy(rx_busy)
    );

    // Clock Generation
    always #5 clk = ~clk;  // 100 MHz clock

    // Connect tx -> rx line
    assign rx = tx;

    // Test Sequence
    initial begin
        clk     = 0;
        reset   = 1;
        start   = 0;
        data_in = 8'b10101011;  // Example data (0xAB)

        #10 reset = 0;

        #50 start = 1;
        #60 start = 0;

        // Wait for signals (Standard Verilog wait)
        @(posedge done);
        @(posedge data_ready);

        $display("Time %0t: RECEIVER GOT DATA: %b", $time, data_out);

        #50 $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, uart_tx_tb);
    end

    initial begin
        #100000 $finish;
    end

endmodule