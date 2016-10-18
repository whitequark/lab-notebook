/*
 * Static clock divider. Displays deviation from target output frequency during synthesis.
 *
 * Author: whitequark@whitequark.org (2016)
 *
 * Parameters:
 *  FREQ_I:  input frequency
 *  FREQ_O:  target output frequency
 *  PHASE:   polarity of the output clock after reset
 *  MAX_PPM: maximum frequency deviation; produces an error if not met
 *
 * Signals:
 *  reset:   active-low reset
 *  clk_i:   input clock
 *  clk_o:   output clock
 */
module ClockDiv #(
        parameter FREQ_I  = 2,
        parameter FREQ_O  = 1,
        parameter PHASE   = 1'b0,
        parameter MAX_PPM = 1_000_000
    ) (
        input  reset,
        input  clk_i,
        output clk_o
    );

    // This calculation always rounds frequency up.
    localparam INIT = FREQ_I / FREQ_O / 2 - 1;
    localparam ACTUAL_FREQ_O = FREQ_I / ((INIT + 1) * 2);
    localparam PPM = 64'd1_000_000 * (ACTUAL_FREQ_O - FREQ_O) / FREQ_O;
    initial $display({"ClockDiv #(.FREQ_I(%d), .FREQ_O(%d),\n",
                      "           .INIT(%d), .ACTUAL_FREQ_O(%d), .PPM(%d))"},
                     FREQ_I, FREQ_O, INIT, ACTUAL_FREQ_O, PPM);
    generate
        if(INIT < 0)
            _ERROR_FREQ_TOO_HIGH_ error();
        if(PPM > MAX_PPM)
            _ERROR_FREQ_DEVIATION_TOO_HIGH_ error();
    endgenerate

    reg [$clog2(INIT):0] cnt = 0;
    reg                  clk = PHASE;
    always @(posedge clk_i or negedge reset)
        if(!reset) begin
            cnt <= 0;
            clk <= PHASE;
        end else begin
            if(cnt == 0) begin
                clk <= ~clk;
                cnt <= INIT;
            end else begin
                cnt <= cnt - 1;
            end
        end

    assign clk_o = clk;

endmodule
