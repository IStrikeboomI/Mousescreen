module hdmi(
    input wire clk,
    input wire rst,
    input wire times5clk,
    input wire [7:0] r,g,b,
    input hSync, vSync, DrawArea,

    output wire rp,
    output wire rn,
    output wire gp,
    output wire gn,
    output wire bp,
    output wire bn,
    output wire  clkp,
    output wire  clkn
);
wire [9:0] TMDS_red, TMDS_green, TMDS_blue;
TMDS_encoder encode_R(.clk(clk), .VD(r  ), .CD(2'b00)        , .VDE(DrawArea), .TMDS(TMDS_red));
TMDS_encoder encode_G(.clk(clk), .VD(g), .CD(2'b00)        , .VDE(DrawArea), .TMDS(TMDS_green));
TMDS_encoder encode_B(.clk(clk), .VD(b ), .CD({vSync,hSync}), .VDE(DrawArea), .TMDS(TMDS_blue));

wire tmds_clk_bit;
wire tmds_red_bit;
OSER10 red_ser (
    .Q(tmds_red_bit),
    .D0(TMDS_red[0]),
    .D1(TMDS_red[1]),
    .D2(TMDS_red[2]),
    .D3(TMDS_red[3]),
    .D4(TMDS_red[4]),
    .D5(TMDS_red[5]),
    .D6(TMDS_red[6]),
    .D7(TMDS_red[7]),
    .D8(TMDS_red[8]),
    .D9(TMDS_red[9]),
    .PCLK(clk),
    .FCLCK(times5clk),
    .RESET(rst)
)
TLVDS_OBUF tmds_clk_buf(
    .I(clk),
    .O(clkp),
    .OB(clkn)
);
endmodule