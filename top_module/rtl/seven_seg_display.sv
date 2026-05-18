module seven_seg_display (
  input  logic [3:0] hex_value, // 4-bit input (0 to 15)
  output logic [6:0] segments   // 7-segment output: {g,f,e,d,c,b,a}
);

  // 7-segment encoding for 0-F (Common Cathode: 1 = ON)
  always_comb begin
    case (hex_value)
      4'h0    : segments = 7'b0111111;  // 0
      4'h1    : segments = 7'b0000110;  // 1
      4'h2    : segments = 7'b1011011;  // 2
      4'h3    : segments = 7'b1001111;  // 3
      4'h4    : segments = 7'b1100110;  // 4
      4'h5    : segments = 7'b1101101;  // 5
      4'h6    : segments = 7'b1111101;  // 6
      4'h7    : segments = 7'b0000111;  // 7
      4'h8    : segments = 7'b1111111;  // 8
      4'h9    : segments = 7'b1101111;  // 9
      4'hA    : segments = 7'b1110111;  // A
      4'hB    : segments = 7'b1111100;  // b
      4'hC    : segments = 7'b0111001;  // C
      4'hD    : segments = 7'b1011110;  // d
      4'hE    : segments = 7'b1111001;  // E
      4'hF    : segments = 7'b1110001;  // F
      default : segments = 7'b0000000; // Blank
    endcase
  end

endmodule