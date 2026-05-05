module chacha_to_uart_tx (
	input  logic         clk         ,
	input  logic         reset       ,
	input  logic [511:0] data_in     ,
	input  logic         data_in_vld ,
	input  logic         uart_tx_busy,
	input  logic         uart_done   ,
	output logic [  7:0] data_out    ,
	output logic         data_out_vld,
	output logic         busy
);

logic [511:0] data_in_stored;
logic [  6:0] counter       ;
logic         uart_done_d   ;

always_ff @(posedge clk) begin 
	if(reset) begin
		uart_done_d <= 0;
	end else begin
		uart_done_d <= uart_done;
	end
end

always_ff @(posedge clk) begin 
	if(reset) begin
		data_in_stored <= 0;
	end 
	else if(data_in_vld && ~busy) begin
		data_in_stored <= {8'b0,data_in[511:8]};
	end
	else if (uart_done && ~uart_done_d) begin
		data_in_stored <= {8'b0,data_in_stored[511:8]};
	end
end

always_ff @(posedge clk) begin
	if(reset) begin
		counter <= 0;
	end 
	else if(data_in_vld && !busy && !uart_tx_busy) begin
		counter <= 1;
	end
	else if (busy && uart_done && ~uart_done_d) begin
		counter <= counter + 1;
	end
end

always_ff @(posedge clk) begin
	if(reset) begin
		data_out <= 0;
	end 
	else if(data_in_vld && !busy && !uart_tx_busy) begin
		data_out <= data_in[7:0];
	end
  else if(uart_done && ~uart_done_d) begin
  	data_out <= data_in_stored[7:0];
  end
end

always_ff @(posedge clk) begin
	if(reset) begin
		data_out_vld <= 0;
	end 
	else if(data_in_vld && !busy && !uart_tx_busy) begin
		data_out_vld <= 1;
	end
  else if(busy && uart_done && ~uart_done_d && (counter < 64)) begin
  	data_out_vld <= 1;
  end
  else if (uart_tx_busy) begin
  	data_out_vld <= 0;
  end 
end

always_ff @(posedge clk) begin
	if(reset) begin
		busy <= 0;
	end 
	else if(data_in_vld && !busy && !uart_tx_busy) begin
		busy <= 1;
	end
	else if ((counter > 63) && uart_done && ~uart_done_d) begin
		busy <= 0;
	end
end

endmodule 