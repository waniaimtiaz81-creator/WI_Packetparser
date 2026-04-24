module dff(
    input in,
    input clk,
    output reg outd
    );
    always @(posedge clk)
    begin
    outd <= in;
    end
         
endmodule
