module uart_tx (
    input  wire       clk,
    input  wire       tick,
    input  wire       start,
    input  wire [7:0] data_in,
    input  wire       reset,

    output reg        tx,
    output reg        busy,
    output reg        done
);

// FSM States
parameter IDLE    = 2'b00;
parameter START   = 2'b01;
parameter SHIFT   = 2'b10;
parameter CLEANUP = 2'b11;

reg [1:0] state, next_state;
reg [9:0] shift_reg;
reg [3:0] bit_count;

always @(posedge clk) begin
    if (reset) begin
        state      <= IDLE;
        next_state <= IDLE;
        busy       <= 0;
        done       <= 0;
        tx         <= 1;
        shift_reg  <= 10'b0;
        bit_count  <= 0;
    end else begin
        state <= next_state;

        if (tick) begin
            case (state)
                IDLE: begin
                    done <= 0;
                    busy <= 0;
                    tx   <= 1;
                    if (start) begin
                        shift_reg <= {1'b1, data_in, 1'b0};
                        bit_count <= 0;
                        next_state <= START;
                        busy <= 1;
                    end else begin
                        next_state <= IDLE;
                    end
                end

                START: begin
                    tx <= shift_reg[0];
                    shift_reg <= shift_reg >> 1;
                    bit_count <= bit_count + 1;
                    next_state <= SHIFT;
                end

                SHIFT: begin
                    tx <= shift_reg[0];
                    shift_reg <= shift_reg >> 1;
                    bit_count <= bit_count + 1;
                    if (bit_count == 9)
                        next_state <= CLEANUP;
                    else
                        next_state <= SHIFT;
                end

                CLEANUP: begin
                    done <= 1;
                    busy <= 0;
                    tx   <= 1;
                    next_state <= IDLE;
                end
            endcase
        end
    end
end

endmodule