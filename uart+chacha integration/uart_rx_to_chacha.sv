module uart_rx_to_chacha (
	input  logic         clk         ,
	input  logic         raw_reset   ,
	input  logic [  7:0] data_in     ,
	input  logic         data_in_vld ,
	output logic [511:0] data_out    ,
	output logic         data_out_vld
);

	logic [511:0] data_intm;
  logic [  6:0] data_count;
  logic         data_in_vld_d;

	always_ff @(posedge clk) begin
		if(raw_reset)
			data_in_vld_d <= 0;
		else 
			data_in_vld_d <= data_in_vld;
	end

	always_ff @(posedge clk) begin 
		if(raw_reset) 
			data_out <= '0;
		else if(data_count == 64) 
			data_out <= data_intm;
	end

  always_ff @(posedge clk ) begin
  	if(raw_reset) 
  		data_count <= 0;
  	else if(data_count == 64) 
  		if (data_in_vld && !data_in_vld_d) 
	  		data_count <= 1;
	  	else 
	  		data_count <= 0;
  	else if(data_in_vld && !data_in_vld_d) 
  		data_count <= data_count + 1;
  end

  always_ff @(posedge clk) begin
  	if(raw_reset) 
  		data_intm <= 0;
  	else if(data_in_vld && !data_in_vld_d)
  		data_intm <= {data_intm[503:0],data_in};
  end

  always_ff @(posedge clk) begin
  	if(raw_reset) 
  		data_out_vld <= 0;
  	else if(data_count == 64) 
  		data_out_vld <= 1;
  	else 
  		data_out_vld <= 0;
  end

endmodule