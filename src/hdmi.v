module hdmi(
    input wire clk,
    input wire rst,
    input wire [7:0] r,g,b,
    input hSync, vSync, DrawArea,

    input wire clk_TMDS,

    output wire rp,
    output wire rn,
    output wire gp,
    output wire gn,
    output wire bp,
    output wire bn,
    output wire clkp,
    output wire clkn
);

wire [9:0] TMDS_r;
wire [9:0] TMDS_g;
wire [9:0] TMDS_b;

svo_tmds encode_R(.clk(clk), .resetn(~rst),.din(r), .ctrl(2'b00)        , .de(DrawArea), .dout(TMDS_r));
svo_tmds encode_G(.clk(clk), .resetn(~rst),.din(g), .ctrl(2'b00)        , .de(DrawArea), .dout(TMDS_g));
svo_tmds encode_B(.clk(clk), .resetn(~rst),.din(b), .ctrl({vSync,hSync}), .de(DrawArea), .dout(TMDS_b));

wire tmds_clk;
wire [2:0] tmds_bit;
OSER10 tmds_serdes [2:0] (
    .Q(tmds_bit),
    .D0({TMDS_b[0], TMDS_g[0], TMDS_r[0]}),
    .D1({TMDS_b[1], TMDS_g[1], TMDS_r[1]}),
    .D2({TMDS_b[2], TMDS_g[2], TMDS_r[2]}),
    .D3({TMDS_b[3], TMDS_g[3], TMDS_r[3]}),
    .D4({TMDS_b[4], TMDS_g[4], TMDS_r[4]}),
    .D5({TMDS_b[5], TMDS_g[5], TMDS_r[5]}),
    .D6({TMDS_b[6], TMDS_g[6], TMDS_r[6]}),
    .D7({TMDS_b[7], TMDS_g[7], TMDS_r[7]}),
    .D8({TMDS_b[8], TMDS_g[8], TMDS_r[8]}),
    .D9({TMDS_b[9], TMDS_g[9], TMDS_r[9]}),
    .PCLK(clk),
    .FCLK(clk_TMDS),
    .RESET(rst)
);
ELVDS_OBUF elvds [3:0] (
    .I({clk,tmds_bit[2],tmds_bit[1],tmds_bit[0]}),
    .O({clkp,bp,gp,rp}),
    .OB({clkn,bn,gn,rn})
);
endmodule