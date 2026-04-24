module shift_register(
    input  wire        clk,                 
    input  wire        rst, 
    input  wire        load,                
    input  wire        processed_bit_valid, 
    input  wire        processed_bit,       
    output reg  [31:0] shift_reg            
);

always @(posedge clk or posedge rst) 
begin
    if (rst) begin
        shift_reg <= 32'b0;                              // async reset
    end else if (load && processed_bit_valid) begin
        shift_reg <= {shift_reg[30:0], processed_bit};  // shift only when load AND valid
    end
end

endmodule