(* dont_touch = "true" *)
module ro_synthesis #(parameter ODD_NO = 5) (
  input  wire en ,
  output wire out
);
  wire no[ODD_NO-1:0];
  (* keep = "true", dont_touch = "true" *) assign no[0]          = (en)? ~no[ODD_NO-1] : 1'b0;
  // (* keep = "true", dont_touch = "true" *) assign #1 no[ODD_NO-1:1] = ~no[ODD_NO-2:0];

  genvar i;
  generate
    for (i = 1; i < ODD_NO; i = i + 2) begin : inv_chain
      (* keep = "true", dont_touch = "true" *)assign no[i  ] = ~no[i-1];
      (* keep = "true", dont_touch = "true" *)assign no[i+1] = ~no[i  ];
    end
  endgenerate

  (* keep = "true", dont_touch = "true" *) assign out            = no[ODD_NO-1];

endmodule
