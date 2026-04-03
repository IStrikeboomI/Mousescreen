module mousescreen#(
    parameter FREQ = 25_000_000
)(
    input wire clk,
    input wire rst,
    
    input wire button_s1,
    input wire button_s2,

    // DONE LED
    output wire done,

    //For USB
    //inout wire usb_dp,
    //inout wire usb_dn,

    //For HDMI/DVI, pmod should be the one closest to usb c port
    output wire rp,
    output wire rn,
    output wire gp,
    output wire gn,
    output wire bp,
    output wire bn,
    output wire clkp,
    output wire clkn

    // For Additional LED PMOD
    //output wire [15:0] led
);
wire clk_TMDS;
wire lock;
Gowin_PLL pll_inst(
    .clkin(clk), //input  clkin
    .clkout0(clk_TMDS), //output  clkout0
    .lock(lock),
    .mdclk(clk)
);
wire clk_p;
 Gowin_CLKDIV clk_div(
    .clkout(clk_p), //output clkout
    .hclkin(clk_TMDS), //input hclkin
    .resetn(lock) //input resetn
 );
reg [10:0] CounterX = 0; // Increased to 11 bits for 1649
reg [10:0] CounterY = 0; // Increased to 11 bits for 749
reg hSync, vSync, DrawArea;
reg [7:0] red, green, blue;

always @(posedge clk_p) begin
    // 1. Counters for 720p (Total Horizontal: 1650, Total Vertical: 750)
    CounterX <= (CounterX == 1649) ? 0 : CounterX + 1;
    if (CounterX == 1649)
        CounterY <= (CounterY == 749) ? 0 : CounterY + 1;

    // 2. Control Signals (Registered to avoid glitches)
    // Limits: Active(1280) + FrontPorch(110) + Sync(40) + BackPorch(220)
    DrawArea <= (CounterX < 1280) && (CounterY < 720);
    
    // 720p uses Positive Syncs
    hSync <= (CounterX >= 1390) && (CounterX < 1430); 
    vSync <= (CounterY >= 725) && (CounterY < 730);
end

always @(posedge clk) begin
    if (DrawArea) begin
        red   <= CounterX[6:0] + CounterY[6:0];
        blue  <= 8'hA9;
        green <= 8'hA9;
    end else begin
        {red, green, blue} <= 24'h000000;
    end
end

hdmi hdmi_inst(
    .clk(clk_p),
    .rst(button_s1),
    .r(red),.g(green),.b(blue),
    .hSync(hSync), .vSync(vSync), .DrawArea(DrawArea),
    .clk_TMDS(clk_TMDS),
    .rp(rp),
    .rn(rn),
    .gp(gp),
    .gn(gn),
    .bp(bp),
    .bn(bn),
    .clkp(clkp),
    .clkn(clkn)
);
assign done = vSync;
endmodule