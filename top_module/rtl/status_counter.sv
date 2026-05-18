module status_counter (
	input  logic         clk                ,
	input  logic         reset              ,
	input  logic         uart_rx_vld        ,
	input  logic         trng_data_vld      ,
	input  logic [511:0] plain_text         ,
	input  logic         plain_text_vld     ,
	input  logic         encrypted_data_vld ,
	input  logic [511:0] decrypted_data     ,
	input  logic         decrypted_data_vld ,
	output logic [511:0] status_data_out    ,
	output logic         status_data_out_vld
);

	logic [63:0] uart_rx_data_in_cnt;
	logic [63:0] trng_data_in_cnt   ;
	logic [63:0] plain_text_cnt     ;
	logic [63:0] encrypted_data_cnt ;
	logic [63:0] decrypted_data_cnt ;
	logic [63:0] data_match_cnt     ;
	logic [63:0] data_errro_cnt     ;

	logic [511:0] decrypted_data_d    ;
	logic         decrypted_data_vld_d;

	logic [3:0][511:0] plain_text_data_buffer;

	always_ff @(posedge clk) begin
		if(reset)
			plain_text_data_buffer[3:0] <= 0;
		else if(plain_text_vld)
			case (plain_text_cnt[1:0])
				2'b00   : plain_text_data_buffer[0] 	<= plain_text;
				2'b01   : plain_text_data_buffer[1] 	<= plain_text;
				2'b10   : plain_text_data_buffer[2] 	<= plain_text;
				2'b11   : plain_text_data_buffer[3] 	<= plain_text;
				default : plain_text_data_buffer[3:0] <= 0;
			endcase
	end

	always_ff @(posedge clk) begin
		if(reset) begin
			decrypted_data_d     <= 0;
			decrypted_data_vld_d <= 0;
		end
		else begin
			decrypted_data_d     <= decrypted_data    ;
			decrypted_data_vld_d <= decrypted_data_vld;
		end
	end

	always_ff @(posedge clk) begin
		if(reset)
			status_data_out <= 0;
		else
			status_data_out <= {64'b0             , uart_rx_data_in_cnt, trng_data_in_cnt, plain_text_cnt,
				encrypted_data_cnt, decrypted_data_cnt,  data_match_cnt,   data_errro_cnt};
	end

	always_ff @(posedge clk) begin
		if(reset) begin
			data_match_cnt <= 0;
			data_errro_cnt <= 0;
		end
		else if (decrypted_data_vld_d) begin
			data_match_cnt <= (plain_text_data_buffer[decrypted_data_cnt[1:0]] == decrypted_data_d)? data_match_cnt+1 : data_match_cnt;
			data_errro_cnt <= (plain_text_data_buffer[decrypted_data_cnt[1:0]] == decrypted_data_d)? data_match_cnt : data_match_cnt+1;
		end
	end

	assign status_data_out_vld = (reset)? 1'b0 : 1'b1;

	always_ff @(posedge clk) begin
		if(reset)
			uart_rx_data_in_cnt <= 0;
		else if (uart_rx_vld)
			uart_rx_data_in_cnt <= uart_rx_data_in_cnt + 1;
	end

	always_ff @(posedge clk) begin
		if(reset)
			trng_data_in_cnt <= 0;
		else if (trng_data_vld)
			trng_data_in_cnt <= trng_data_in_cnt + 1;
	end

	always_ff @(posedge clk) begin
		if(reset)
			plain_text_cnt <= 0;
		else if (plain_text_vld)
			plain_text_cnt <= plain_text_cnt + 1;
	end

	always_ff @(posedge clk) begin
		if(reset)
			encrypted_data_cnt <= 0;
		else if (encrypted_data_vld)
			encrypted_data_cnt <= encrypted_data_cnt + 1;
	end

	always_ff @(posedge clk) begin
		if(reset)
			decrypted_data_cnt <= 0;
		else if (decrypted_data_vld)
			decrypted_data_cnt <= decrypted_data_cnt + 1;
	end

endmodule