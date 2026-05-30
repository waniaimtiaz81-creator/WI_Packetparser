module ro_synthesis #(parameter ODD_NO = 5) (
  input  wire en ,
  output wire out
);
  (* keep *) wire no[ODD_NO-1:0];
  (* keep *) assign no[0]          = (en)? ~no[ODD_NO-1] : 1'b0;
  // (* keep *) assign #1 no[ODD_NO-1:1] = ~no[ODD_NO-2:0];

  genvar i;
  generate
    for (i = 1; i < ODD_NO; i = i + 2) begin : inv_chain
      (* keep *)assign no[i  ] = ~no[i-1];
      (* keep *)assign no[i+1] = ~no[i  ];
    end
  endgenerate

  (* keep *) assign out            = no[ODD_NO-1];

endmodule


