`timescale 1ns / 1ps

module hdmi_testbench();

    reg clk_25m = 0;
    reg rst = 1;
    wire hsync, vsync, de;
    wire [7:0] r, g, b;

    // Generate 25.175 MHz approximately (39.72ns period)
    always #19.86 clk_25m = ~clk_25m;

    initial begin
        #100 rst = 0;
        #33000000; // Simulate ~2 full frames (16.6ms per frame)
        $finish;
    end

    // Your HDMI/DVI Controller
    hdmi uut (
        .pixel_clk(clk_25m),
        .reset(rst),
        .hsync(hsync),
        .vsync(vsync),
        .de(de),
        .r(r), .g(g), .b(b)
    );

    // Timing Monitor Logic
    integer h_cnt = 0, v_cnt = 0;
    integer active_h = 0, active_v = 0;

    always @(posedge clk_25m) begin
        if (rst) begin
            h_cnt <= 0; v_cnt <= 0;
        end else begin
            h_cnt <= h_cnt + 1;
            if (de) active_h <= active_h + 1;

            // End of Line
            if (h_cnt == 800) begin
                if (active_h != 640) 
                    $display("ERR: Row %d has %d active pixels (Expected 640)", v_cnt, active_h);
                h_cnt <= 0;
                active_h <= 0;
                v_cnt <= v_cnt + 1;
            end

            // End of Frame
            if (v_cnt == 525) begin
                $display("Frame Complete: Captured %d active lines.", active_v);
                v_cnt <= 0;
                active_v <= 0;
            end
            
            // Count total active lines
            if (h_cnt == 0 && de) active_v <= active_v + 1;
        end
    end
endmodule