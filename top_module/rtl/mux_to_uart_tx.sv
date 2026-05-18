module mux_to_uart_tx (
	input  logic         clk                   ,
	input  logic         reset                 ,
	input  logic [  1:0] mux_slect             ,
	input  logic [512:0] plain_text            ,
	input  logic         plain_text_vld        ,
	input  logic [512:0] encrypted_data        ,
	input  logic         encrypted_data_vld    ,
	input  logic [512:0] decrypted_data        ,
	input  logic         decrypted_data_vld    ,
	input  logic [512:0] status_data           ,
	input  logic         status_data_vld       ,
	output logic [512:0] mux_out_data_to_tx    ,
	output logic         mux_out_data_to_tx_vld
);

always_ff @(posedge clk) begin 
	if(reset) begin
		mux_out_data_to_tx     <= 0;
		mux_out_data_to_tx_vld <= 0;
	end 
	else if(mux_slect == 0) begin
		mux_out_data_to_tx     <= status_data       ;
		mux_out_data_to_tx_vld <= status_data_vld   ;
	end
	else if(mux_slect == 1) begin
		mux_out_data_to_tx     <= plain_text        ;
		mux_out_data_to_tx_vld <= plain_text_vld    ;
	end
	else if(mux_slect == 2) begin
		mux_out_data_to_tx     <= encrypted_data    ;
		mux_out_data_to_tx_vld <= encrypted_data_vld;
	end
	else if(mux_slect == 3) begin
		mux_out_data_to_tx     <= decrypted_data    ;
		mux_out_data_to_tx_vld <= decrypted_data_vld;
	end
end

endmodule