module comb_d(
    input clk,
    input en,
    input rst,
    input load,
    output [31:0] shift_reg 
);
   
    wire [31:0] out_;
    ro ro1(en,out_[0]);
    ro ro2(en,out_[1]);
    ro ro3(en,out_[2]);
    ro ro4(en,out_[3]);
    ro ro5(en,out_[4]);
    ro ro6(en,out_[5]);
    ro ro7(en,out_[6]);
    ro ro8(en,out_[7]);
    ro ro9(en,out_[8]);
    ro ro10(en,out_[9]);
    ro ro11(en,out_[10]);
    ro ro12(en,out_[11]);
    ro ro13(en,out_[12]);
    ro ro14(en,out_[13]);
    ro ro15(en,out_[14]);
    ro ro16(en,out_[15]);
    ro ro17(en,out_[16]);
    ro ro18(en,out_[17]);
    ro ro19(en,out_[18]);
    ro ro20(en,out_[19]);
    ro ro21(en,out_[20]);
    ro ro22(en,out_[21]);
    ro ro23(en,out_[22]);
    ro ro24(en,out_[23]);
    ro ro25(en,out_[24]);
    ro ro26(en,out_[25]);
    ro ro27(en,out_[26]);
    ro ro28(en,out_[27]);
    ro ro29(en,out_[28]);
    ro ro30(en,out_[29]);
    ro ro31(en,out_[30]);
    ro ro32(en,out_[31]);
    
    wire [31:0] out;
    
    dff dff1(out_[0],clk,out[0]);
    dff dff2(out_[1],clk,out[1]);
    dff dff3(out_[2],clk,out[2]);
    dff dff4(out_[3],clk,out[3]);
    dff dff5(out_[4],clk,out[4]);
    dff dff6(out_[5],clk,out[5]);
    dff dff7(out_[6],clk,out[6]);
    dff dff8(out_[7],clk,out[7]);
    dff dff9(out_[8],clk,out[8]);
    dff dff10(out_[9],clk,out[9]);
    dff dff11(out_[10],clk,out[10]);
    dff dff12(out_[11],clk,out[11]);
    dff dff13(out_[12],clk,out[12]);
    dff dff14(out_[13],clk,out[13]);
    dff dff15(out_[14],clk,out[14]);
    dff dff16(out_[15],clk,out[15]);
    dff dff17(out_[16],clk,out[16]);
    dff dff18(out_[17],clk,out[17]);
    dff dff19(out_[18],clk,out[18]);
    dff dff20(out_[19],clk,out[19]);
    dff dff21(out_[20],clk,out[20]);
    dff dff22(out_[21],clk,out[21]);
    dff dff23(out_[22],clk,out[22]);
    dff dff24(out_[23],clk,out[23]);
    dff dff25(out_[24],clk,out[24]);
    dff dff26(out_[25],clk,out[25]);
    dff dff27(out_[26],clk,out[26]);
    dff dff28(out_[27],clk,out[27]);
    dff dff29(out_[28],clk,out[28]);
    dff dff30(out_[29],clk,out[29]);
    dff dff31(out_[30],clk,out[30]);
    dff dff32(out_[31],clk,out[31]);
    
    wire xor_;
    assign xor_ = ^out;
    wire mux_in;
    dff dff33(xor_,clk,mux_in);
    
    reg prev_bit,mux_in_delayed;
    
always @(posedge clk) begin
    if (en) begin
        mux_in_delayed <= mux_in;
        prev_bit <= mux_in_delayed; 
    end
end

wire final_entropy; 
wire entropy_valid;  

vonneuman_corrector vnc(
    .A(prev_bit),
    .B(mux_in),
    .F(final_entropy),
    .valid(entropy_valid)
);

wire [31:0] shift_reg_out;
shift_register sh1(clk,rst,load,entropy_valid,final_entropy,shift_reg_out);
assign shift_reg = shift_reg_out;

endmodule
