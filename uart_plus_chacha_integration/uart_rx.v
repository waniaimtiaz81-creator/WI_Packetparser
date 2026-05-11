module uart_rx (
    input  wire       clk,
    input  wire       reset,
    input  wire       tick,
    input  wire       rx,
    output reg [7:0]  data_out,
    output reg        data_ready,
    output reg        busy
);

parameter IDLE       = 2'b00;
parameter START_BIT  = 2'b01;
parameter DATA_BITS  = 2'b10;
parameter STOP_BIT   = 2'b11;

reg [1:0] state;
reg [3:0] bit_count;
reg [7:0] shift_reg;

always @(posedge clk) begin
    if (reset) begin
        state      <= IDLE;
        data_ready <= 0;
        busy       <= 0;
        data_out   <= 8'b0;
    end else if (tick) begin
        case (state)
            IDLE: begin
                data_ready <= 0;
                if (rx == 0) begin
                    state <= DATA_BITS;
                    bit_count <= 0;
                    busy <= 1;
                end
            end

            DATA_BITS: begin
                shift_reg <= {rx, shift_reg[7:1]};
                if (bit_count == 7)
                    state <= STOP_BIT;
                else
                    bit_count <= bit_count + 1;
            end

            STOP_BIT: begin
                data_out <= shift_reg;
                data_ready <= 1;
                busy <= 0;
                state <= IDLE;
            end
        endcase
    end
end
endmodule