module baud_gen (
    input  wire clk,
    input  wire reset,
    output reg  tick
);

    parameter BAUD_DIV = 5208;
    // Calculation for width: $clog2(5208) is 13
    reg [12:0] count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
            tick  <= 0;
        end else if (count == BAUD_DIV - 1) begin
            count <= 0;
            tick  <= 1;
        end else begin
            count <= count + 1;
            tick  <= 0;
        end
    end

endmodule