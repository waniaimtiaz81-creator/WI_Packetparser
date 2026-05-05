module dff (
    input      in  ,
    input      clk ,
    output reg outd
);

reg out[1:0];

    always @(posedge clk)
        begin
            out[0] <= in    ;
            out[1] <= out[0]; 
            outd   <= out[1];
        end

endmodule
