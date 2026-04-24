module uart_top (
    input  wire       clk,
    input  wire       raw_reset,
    input  wire       rx,
    output wire       tx
);

    wire       tick;
    wire       reset;
    wire [7:0] data_out;
    wire       data_ready;
    wire       tx_done;
    wire       tx_busy;
    reg        start;
    reg  [7:0] data_in;

    assign reset = ~raw_reset;

    // +1 Logic remains exactly the same
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_in <= 8'b0;
            start   <= 0;
        end else if (data_ready && !tx_busy) begin
            data_in <= data_out + 1'b1;
            start   <= 1;
        end else begin
            start   <= 0;
        end
    end

    baud_gen #(.BAUD_DIV(5208)) baud_inst (
        .clk(clk),
        .reset(reset),
        .tick(tick)
    );

    uart_tx tx_inst (
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .start(start),
        .data_in(data_in),
        .tx(tx),
        .done(tx_done),
        .busy(tx_busy)
    );

    uart_rx rx_inst (
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .rx(rx),
        .data_out(data_out),
        .data_ready(data_ready),
        .busy()
    );

endmodule