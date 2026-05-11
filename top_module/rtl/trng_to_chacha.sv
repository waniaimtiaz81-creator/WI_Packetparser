module trng_to_chacha (
	input  logic         clk             ,
	input  logic         reset           ,
	input  logic [ 31:0] trng_data_in    ,
	input  logic         trng_data_in_vld,
	output logic [511:0] data_out        ,
	output logic         data_out_vld
);

	reg [3:0] word_count    ;

	always_ff @(posedge clk) begin
		if(reset) 
			word_count <= 0;
		else if (data_out_vld && trng_data_in_vld) 
			word_count <= 1;
		else if (data_out_vld) 
			word_count <= 0;
		else if (trng_data_in_vld) 
			word_count <= word_count + 1;
	end

	always_ff @(posedge clk) begin
		if(reset)
			data_out_vld <= 0;
		else if (trng_data_in_vld && (word_count == 15))
			data_out_vld <= 1;
		else 
			data_out_vld <= 0;
	end

	always_ff @(posedge clk) begin
		if(reset)
			data_out <= 0;
		else if(trng_data_in_vld)
			data_out <= {data_out[479:0], trng_data_in};
	end

endmodule