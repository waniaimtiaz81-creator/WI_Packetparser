(* dont_touch = "true" *)
module ro(
    input wire en,
    output wire out
);
    wire and1, not1, not2;
    (* keep = "true" *) assign and1 = en & ~not2;
    (* keep = "true" *) assign not1 = ~and1;
    (* keep = "true" *) assign not2 = ~not1;
    (* keep = "true" *) assign out = ~not2;
endmodule
