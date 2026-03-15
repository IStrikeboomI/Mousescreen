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
    inout wire usb_dp,
    inout wire usb_dn,

    //For HDMI/DVI, pmod should be the one closest to usb c port
    output wire rp,
    output wire rn,
    output wire gp,
    output wire gn,
    output wire bp,
    output wire bn,
    output wire clkp,
    output wire clkn,

    // For Additional LED PMOD
    output wire [15:0] led
);
Gowin_PLL pll_inst(

reg [9:0] CounterX=0, CounterY=0;
reg hSync, vSync, DrawArea;
always @(posedge clk) DrawArea <= (CounterX<640) && (CounterY<480);

always @(posedge clk) CounterX <= (CounterX==799) ? 0 : CounterX+1;
always @(posedge clk) if(CounterX==799) CounterY <= (CounterY==524) ? 0 : CounterY+1;

always @(posedge clk) hSync <= (CounterX>=656) && (CounterX<752);
always @(posedge clk) vSync <= (CounterY>=490) && (CounterY<492);

////////////////
wire [7:0] W = {8{CounterX[7:0]==CounterY[7:0]}};
wire [7:0] A = {8{CounterX[7:5]==3'h2 && CounterY[7:5]==3'h2}};
reg [7:0] red, green, blue;
always @(posedge clk) red <= ({CounterX[5:0] & {6{CounterY[4:3]==~CounterX[4:3]}}, 2'b00} | W) & ~A;
always @(posedge clk) green <= (CounterX[7:0] & {8{CounterY[6]}} | W) & ~A;
always @(posedge clk) blue <= CounterY[7:0] | W | A;


hdmi hdmi_inst(
    .clk(clk),
    .rst(rst),
    .times5clk(times5clk),
    .r(red),.g(green),.b(blue),
    .hSync(hSync), .vSync(vSync), .DrawArea(DrawArea),
    .rp(rp),
    .rn(rn),
    .gp(gp),
    .gn(gn),
    .bp(bp),
    .bn(bn),
    .clkp(clkp),
    .clkn(clkn)
);


endmodule