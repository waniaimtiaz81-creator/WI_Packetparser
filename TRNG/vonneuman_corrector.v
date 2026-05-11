module vonneuman_corrector(
    input  logic A,        
    input  logic B,        
    output logic F,       
    output logic valid  
);

    assign valid = A ^ B;      // Valid only when A != B
    assign F     = A ? 1'b0 : 1'b1;  // When A=1,B=0 → output 0; A=0,B=1 → output 1

endmodule