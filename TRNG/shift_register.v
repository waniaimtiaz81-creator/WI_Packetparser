module shift_register (
  input  logic        clk                ,
  input  logic        rst                ,
  input  logic        load               ,
  input  logic        processed_bit_valid,
  input  logic        processed_bit      ,
  output logic [31:0] shift_reg_out      ,
  output logic        shift_reg_out_vld
);

  reg [4:0] bit_count;

  always_ff @(posedge clk) begin
    if(rst)
      bit_count <= 0;
    else if (shift_reg_out_vld && processed_bit_valid)
      bit_count <= 1;
    else if (shift_reg_out_vld)
      bit_count <= 0;
    else if (processed_bit_valid)
      bit_count <= bit_count + 1;
  end

  always_ff @(posedge clk) begin
    if(rst)
      shift_reg_out_vld <= 0;
    else if (processed_bit_valid && load && (bit_count == 31))
      shift_reg_out_vld <= 1;
    else
      shift_reg_out_vld <= 0;
  end

  always_ff @(posedge clk) begin
    if(rst)
      shift_reg_out <= 0;
    else if(processed_bit_valid)
      shift_reg_out <= {shift_reg_out[30:0], processed_bit};
  end

endmodule