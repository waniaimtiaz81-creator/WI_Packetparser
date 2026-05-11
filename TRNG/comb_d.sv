module comb_d (
  input  logic        clk          ,
  input  logic        en           ,
  input  logic        rst          ,
  input  logic        load         ,
  output logic [31:0] shift_reg    ,
  output logic        shift_reg_vld
);

  wire [31:0]       out_pre          ;
  wire [31:0]       out              ;
  wire [31:0][31:0] shift_reg_out    ;
  wire [31:0]       shift_reg_out_vld;

`ifdef SYNTHESIS
  ro_synthesis #(.ODD_NO( 3)) i_ro_0  (.en(en), .out(out_pre[ 0]));
  ro_synthesis #(.ODD_NO( 5)) i_ro_1  (.en(en), .out(out_pre[ 1]));
  ro_synthesis #(.ODD_NO( 7)) i_ro_2  (.en(en), .out(out_pre[ 2]));
  ro_synthesis #(.ODD_NO( 9)) i_ro_3  (.en(en), .out(out_pre[ 3]));
  ro_synthesis #(.ODD_NO(11)) i_ro_4  (.en(en), .out(out_pre[ 4]));
  ro_synthesis #(.ODD_NO(13)) i_ro_5  (.en(en), .out(out_pre[ 5]));
  ro_synthesis #(.ODD_NO(15)) i_ro_6  (.en(en), .out(out_pre[ 6]));
  ro_synthesis #(.ODD_NO(17)) i_ro_7  (.en(en), .out(out_pre[ 7]));
  ro_synthesis #(.ODD_NO(19)) i_ro_8  (.en(en), .out(out_pre[ 8]));
  ro_synthesis #(.ODD_NO(21)) i_ro_9  (.en(en), .out(out_pre[ 9]));
  ro_synthesis #(.ODD_NO(23)) i_ro_10 (.en(en), .out(out_pre[10]));
  ro_synthesis #(.ODD_NO(25)) i_ro_11 (.en(en), .out(out_pre[11]));
  ro_synthesis #(.ODD_NO(27)) i_ro_12 (.en(en), .out(out_pre[12]));
  ro_synthesis #(.ODD_NO(29)) i_ro_13 (.en(en), .out(out_pre[13]));
  ro_synthesis #(.ODD_NO(31)) i_ro_14 (.en(en), .out(out_pre[14]));
  ro_synthesis #(.ODD_NO(33)) i_ro_15 (.en(en), .out(out_pre[15]));
  ro_synthesis #(.ODD_NO(35)) i_ro_16 (.en(en), .out(out_pre[16]));
  ro_synthesis #(.ODD_NO(37)) i_ro_17 (.en(en), .out(out_pre[17]));
  ro_synthesis #(.ODD_NO(39)) i_ro_18 (.en(en), .out(out_pre[18]));
  ro_synthesis #(.ODD_NO(21)) i_ro_19 (.en(en), .out(out_pre[19]));
  ro_synthesis #(.ODD_NO(23)) i_ro_20 (.en(en), .out(out_pre[20]));
  ro_synthesis #(.ODD_NO(25)) i_ro_21 (.en(en), .out(out_pre[21]));
  ro_synthesis #(.ODD_NO(27)) i_ro_22 (.en(en), .out(out_pre[22]));
  ro_synthesis #(.ODD_NO(29)) i_ro_23 (.en(en), .out(out_pre[23]));
  ro_synthesis #(.ODD_NO(11)) i_ro_24 (.en(en), .out(out_pre[24]));
  ro_synthesis #(.ODD_NO(13)) i_ro_25 (.en(en), .out(out_pre[25]));
  ro_synthesis #(.ODD_NO(15)) i_ro_26 (.en(en), .out(out_pre[26]));
  ro_synthesis #(.ODD_NO(17)) i_ro_27 (.en(en), .out(out_pre[27]));
  ro_synthesis #(.ODD_NO(19)) i_ro_28 (.en(en), .out(out_pre[28]));
  ro_synthesis #(.ODD_NO( 9)) i_ro_29 (.en(en), .out(out_pre[29]));
  ro_synthesis #(.ODD_NO( 7)) i_ro_30 (.en(en), .out(out_pre[30]));
  ro_synthesis #(.ODD_NO( 5)) i_ro_31 (.en(en), .out(out_pre[31]));
`else 
  ro_simulation #(.ODD_NO( 3)) i_ro_0  (.en(en), .out(out_pre[ 0]));
  ro_simulation #(.ODD_NO( 5)) i_ro_1  (.en(en), .out(out_pre[ 1]));
  ro_simulation #(.ODD_NO( 7)) i_ro_2  (.en(en), .out(out_pre[ 2]));
  ro_simulation #(.ODD_NO( 9)) i_ro_3  (.en(en), .out(out_pre[ 3]));
  ro_simulation #(.ODD_NO(11)) i_ro_4  (.en(en), .out(out_pre[ 4]));
  ro_simulation #(.ODD_NO(13)) i_ro_5  (.en(en), .out(out_pre[ 5]));
  ro_simulation #(.ODD_NO(15)) i_ro_6  (.en(en), .out(out_pre[ 6]));
  ro_simulation #(.ODD_NO(17)) i_ro_7  (.en(en), .out(out_pre[ 7]));
  ro_simulation #(.ODD_NO(19)) i_ro_8  (.en(en), .out(out_pre[ 8]));
  ro_simulation #(.ODD_NO(21)) i_ro_9  (.en(en), .out(out_pre[ 9]));
  ro_simulation #(.ODD_NO(23)) i_ro_10 (.en(en), .out(out_pre[10]));
  ro_simulation #(.ODD_NO(25)) i_ro_11 (.en(en), .out(out_pre[11]));
  ro_simulation #(.ODD_NO(27)) i_ro_12 (.en(en), .out(out_pre[12]));
  ro_simulation #(.ODD_NO(29)) i_ro_13 (.en(en), .out(out_pre[13]));
  ro_simulation #(.ODD_NO(31)) i_ro_14 (.en(en), .out(out_pre[14]));
  ro_simulation #(.ODD_NO(33)) i_ro_15 (.en(en), .out(out_pre[15]));
  ro_simulation #(.ODD_NO(35)) i_ro_16 (.en(en), .out(out_pre[16]));
  ro_simulation #(.ODD_NO(37)) i_ro_17 (.en(en), .out(out_pre[17]));
  ro_simulation #(.ODD_NO(39)) i_ro_18 (.en(en), .out(out_pre[18]));
  ro_simulation #(.ODD_NO(21)) i_ro_19 (.en(en), .out(out_pre[19]));
  ro_simulation #(.ODD_NO(23)) i_ro_20 (.en(en), .out(out_pre[20]));
  ro_simulation #(.ODD_NO(25)) i_ro_21 (.en(en), .out(out_pre[21]));
  ro_simulation #(.ODD_NO(27)) i_ro_22 (.en(en), .out(out_pre[22]));
  ro_simulation #(.ODD_NO(29)) i_ro_23 (.en(en), .out(out_pre[23]));
  ro_simulation #(.ODD_NO(11)) i_ro_24 (.en(en), .out(out_pre[24]));
  ro_simulation #(.ODD_NO(13)) i_ro_25 (.en(en), .out(out_pre[25]));
  ro_simulation #(.ODD_NO(15)) i_ro_26 (.en(en), .out(out_pre[26]));
  ro_simulation #(.ODD_NO(17)) i_ro_27 (.en(en), .out(out_pre[27]));
  ro_simulation #(.ODD_NO(19)) i_ro_28 (.en(en), .out(out_pre[28]));
  ro_simulation #(.ODD_NO( 9)) i_ro_29 (.en(en), .out(out_pre[29]));
  ro_simulation #(.ODD_NO( 7)) i_ro_30 (.en(en), .out(out_pre[30]));
  ro_simulation #(.ODD_NO( 5)) i_ro_31 (.en(en), .out(out_pre[31]));
`endif

  dff dff1 (out_pre[0],clk,out[0]);
  dff dff2 (out_pre[1],clk,out[1]);
  dff dff3 (out_pre[2],clk,out[2]);
  dff dff4 (out_pre[3],clk,out[3]);
  dff dff5 (out_pre[4],clk,out[4]);
  dff dff6 (out_pre[5],clk,out[5]);
  dff dff7 (out_pre[6],clk,out[6]);
  dff dff8 (out_pre[7],clk,out[7]);
  dff dff9 (out_pre[8],clk,out[8]);
  dff dff10 (out_pre[9],clk,out[9]);
  dff dff11 (out_pre[10],clk,out[10]);
  dff dff12 (out_pre[11],clk,out[11]);
  dff dff13 (out_pre[12],clk,out[12]);
  dff dff14 (out_pre[13],clk,out[13]);
  dff dff15 (out_pre[14],clk,out[14]);
  dff dff16 (out_pre[15],clk,out[15]);
  dff dff17 (out_pre[16],clk,out[16]);
  dff dff18 (out_pre[17],clk,out[17]);
  dff dff19 (out_pre[18],clk,out[18]);
  dff dff20 (out_pre[19],clk,out[19]);
  dff dff21 (out_pre[20],clk,out[20]);
  dff dff22 (out_pre[21],clk,out[21]);
  dff dff23 (out_pre[22],clk,out[22]);
  dff dff24 (out_pre[23],clk,out[23]);
  dff dff25 (out_pre[24],clk,out[24]);
  dff dff26 (out_pre[25],clk,out[25]);
  dff dff27 (out_pre[26],clk,out[26]);
  dff dff28 (out_pre[27],clk,out[27]);
  dff dff29 (out_pre[28],clk,out[28]);
  dff dff30 (out_pre[29],clk,out[29]);
  dff dff31 (out_pre[30],clk,out[30]);
  dff dff32 (out_pre[31],clk,out[31]);

  genvar i;
  generate
    for (i = 0; i < 32; i++) begin : parallel_tasking 

      reg  prev_bit      ;
      reg  mux_in_delayed;
      wire final_entropy ;
      wire entropy_valid ;

      always @(posedge clk) begin
        if (en) begin
          mux_in_delayed <= out[i]        ;
          prev_bit       <= mux_in_delayed;
        end
      end

      vonneuman_corrector vnc (
        .A    (mux_in_delayed),
        .B    (prev_bit      ),
        .F    (final_entropy ),
        .valid(entropy_valid )
      );

      shift_register i_shift_register (
        .clk                (clk                 ),
        .rst                (rst                 ),
        .load               (load                ),
        .processed_bit_valid(entropy_valid       ),
        .processed_bit      (final_entropy       ),
        .shift_reg_out      (shift_reg_out[i]    ),
        .shift_reg_out_vld  (shift_reg_out_vld[i])
      );

    end
  endgenerate

  always_ff @(posedge clk) begin
    if (rst) begin
      shift_reg_vld <= 1'b0 ;
      shift_reg     <= 32'b0;
    end 
    else if(!(|shift_reg_out_vld)) begin
      shift_reg_vld <= 1'b0 ;
      shift_reg     <= 32'b0;  
    end
    else begin
      for (int i = 0; i < 32; i++) begin
        if (shift_reg_out_vld[i]) begin
          shift_reg_vld <= 1'b1                  ;
          shift_reg     <= shift_reg_out[i][31:0];  
          break;
        end
      end
    end
  end

endmodule
