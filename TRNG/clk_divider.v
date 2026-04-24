module clk_divider(
    input  wire clk_in,
    output reg clk_out
    );
    
    parameter Divider = 2083333;
    reg [$clog2(Divider)-1:0] count =0;
    reg reset =1;
    
    always @(posedge clk_in)begin
      if (reset ==1)begin 
        reset <= 0;
        clk_out<= 0;
        count<= 0;
      end
      else begin
       if (count==Divider)begin
        clk_out=~clk_out;
        count<= 0;
       end
       else begin
        count<= count+1;
       end
      end
    end
endmodule
