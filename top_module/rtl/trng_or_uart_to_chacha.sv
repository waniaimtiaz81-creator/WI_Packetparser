module trng_or_uart_to_chacha (
	input  logic         clk               ,
	input  logic         reset             ,
	input  logic         chacha_ready      ,
	input  logic         load              ,
	input  logic [511:0] trng_data_in      ,
	input  logic         trng_data_in_vld  ,
	input  logic [511:0] uart_data_in      ,
	input  logic         uart_data_in_vld  ,
	output logic [511:0] chacha_data_in    ,
	output logic         chacha_data_in_vld
);

	always_ff @(posedge clk) begin
		if(reset) begin
			chacha_data_in     <= 0;    
			chacha_data_in_vld <= 0;
		end 
		else if(chacha_ready && !chacha_data_in_vld) begin
			if (trng_data_in_vld && load) begin				
				chacha_data_in     <= trng_data_in;    
				chacha_data_in_vld <= 1;
			end 
			else if (uart_data_in_vld && !load) begin
				chacha_data_in     <= uart_data_in;    
				chacha_data_in_vld <= 1;
			end
			else begin
				chacha_data_in     <= chacha_data_in;    
				chacha_data_in_vld <= 0             ;
			end
		end 
		else begin
			chacha_data_in     <= chacha_data_in;    
			chacha_data_in_vld <= 0             ;
		end 
	end

endmodule 