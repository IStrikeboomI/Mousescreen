module mousescreen#(
    parameter FREQ = 50_000_000
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
    output wire  clkp,
    output wire  clkn,

    // For Additional LED PMOD
    output wire [15:0] led;
);

endmodule;