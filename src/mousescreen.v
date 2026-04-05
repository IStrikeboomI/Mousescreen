module mousescreen#(
    parameter FREQ = 50_000_000,

    parameter WIDTH = 1280,
    parameter HEIGHT = 720,
    parameter BLANKING_WIDTH = 1650,
    parameter BLANKING_HEIGHT = 750,
    parameter HSYNC_MIN = 1390,
    parameter HSYNC_MAX = 1430,
    parameter VSYNC_MIN = 725,
    parameter VSYNC_MAX = 730,

    parameter BOX_COUNTER_MAX = 5_000_00, // how many counter ticks before box moves
    parameter BOX_DIMENSION = 25
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
//counter up to 5_000_00 so 10hz
reg [22:0] counter = 0;
reg [10:0] boxX = 0;
reg [10:0] boxY = 0;
always @(posedge clk) begin
    if (!button_s1) begin
        counter <= (counter == BOX_COUNTER_MAX) ? 0 : counter+1;
        if (counter == BOX_COUNTER_MAX) begin
            boxX <= (boxX == WIDTH) ? 0 : boxX + 1;
            if (boxX == WIDTH) begin
                boxY <= (boxY == HEIGHT) ? 0 : boxY + 1;
            end
        end
    end else begin
        counter <= 0;
        boxX <= 0;
        boxY <= 0;
    end
end
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
//1280 x 720 display, but full resoultion is actually 1650 x 750
reg [10:0] counterX = 0; // Increased to 11 bits for 1649
reg [10:0] counterY = 0; // Increased to 11 bits for 749
always @(posedge clk_p) begin
    if (!button_s1) begin
    // 1. Counters for 720p (Total Horizontal: 1650, Total Vertical: 750)
    counterX <= (counterX == BLANKING_WIDTH) ? 0 : counterX + 1;
    if (counterX == BLANKING_WIDTH) begin
        counterY <= (counterY == BLANKING_HEIGHT) ? 0 : counterY + 1;
    end
    end else begin
        counterX <= 0;
        counterY <= 0;
    end
end
wire hSync = (counterX >= HSYNC_MIN) && (counterX < HSYNC_MAX);
wire vSync = (counterY >= VSYNC_MIN) && (counterY < VSYNC_MAX);
wire DrawArea = (counterX < WIDTH) && (counterY < HEIGHT);
reg [7:0] red, green, blue;
always @(posedge clk_p) begin
    if (DrawArea & ~button_s1) begin
        if (!(counterX >= boxX && counterX <= boxX + BOX_DIMENSION && counterY>= boxY && counterY <= boxY + BOX_DIMENSION)) begin
            red   <= counterX[7:0];
            blue  <= counterY[7:0];
            green <= (counterX[6:0] + counterY[6:0]) & {8{button_s2}};
        end else begin
            {red, green, blue} <= 24'hFFFFFF;
        end
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