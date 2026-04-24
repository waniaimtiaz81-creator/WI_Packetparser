module vonneuman_corrector(
    input A,        
    input B,        
    output F,       
    output valid  
);

    wire xor_out;
    assign xor_out = A ^ B;

    assign valid = xor_out; 
    
    assign F = xor_out ? A : 1'b0;

endmodule
