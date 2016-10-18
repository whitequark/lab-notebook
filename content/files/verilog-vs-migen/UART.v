/*
 * UART transceiver. Only RXD/TXD lines and 8n1 mode is supported.
 *
 * Author: whitequark@whitequark.org (2016)
 *
 * Parameters:
 *  FREQ:       frequency of `clk`
 *  BAUD:       baud rate of serial line
 *
 * Common signals:
 *  reset:      active-low reset; only affects rx_ready_o, rx_error_o and tx_ack_o
 *  clk:        input clock, from which receiver and transmitter clocks are derived;
 *              all transitions happen on (posedge clk)
 *
 * Receiver signals:
 *  rx_i:       serial line input
 *  rx_data_o:  received octet, only valid while (rx_ack_i)
 *  rx_ready_o: whether rx_data_o contains a complete octet
 *  rx_ack_i:   clears rx_full_o and indicates that a new octet may be received
 *  rx_error_o: is asserted if a start bit arrives while (rx_full_o), or
 *              if a start bit is not followed with the stop bit at appropriate time
 *
 * Transmitter signals:
 *  tx_o:       serial line output
 *  tx_data_i:  octet to be sent, needs to be valid while (tx_ready_i && !tx_ack_o)
 *  tx_ready_i: indicates that a new octet should be sent
 *  tx_ack_o:   indicates that an octet is being sent
 *  tx_empty_o: indicates that a new octet may be sent
 */
module UART #(
        parameter FREQ  = 1_000_000,
        parameter BAUD  = 9600
    ) (
        input           reset,
        input           clk,
        // Receiver half
        input           rx_i,
        output [7:0]    rx_data_o,
        output          rx_ready_o,
        input           rx_ack_i,
        output          rx_error_o,
        // Transmitter half
        output          tx_o,
        input  [7:0]    tx_data_i,
        input           tx_ready_i,
        output          tx_ack_o
    );

    // RX oversampler
    reg        rx_sampler_reset = 1'b0;
    wire       rx_sampler_clk;
    ClockDiv #(
        .FREQ_I(FREQ),
        .FREQ_O(BAUD * 3),
        .PHASE(1'b1),
        .MAX_PPM(50_000)
    ) rx_sampler_clk_div (
        .reset(rx_sampler_reset),
        .clk_i(clk),
        .clk_o(rx_sampler_clk)
    );

    reg  [2:0] rx_sample  = 3'b000;
    wire       rx_sample1 = (rx_sample == 3'b111 ||
                             rx_sample == 3'b110 ||
                             rx_sample == 3'b101 ||
                             rx_sample == 3'b011);
    always @(posedge rx_sampler_clk or negedge rx_sampler_reset)
        if(!rx_sampler_reset)
            rx_sample <= 3'b000;
        else
            rx_sample <= {rx_sample[1:0], rx_i};

    (* fsm_encoding="one-hot" *)
    reg  [1:0] rx_sampleno  = 2'd2;
    wire       rx_samplerdy = (rx_sampleno == 2'd2);
    always @(posedge rx_sampler_clk or negedge rx_sampler_reset)
        if(!rx_sampler_reset)
            rx_sampleno <= 2'd2;
        else case(rx_sampleno)
            2'd0: rx_sampleno <= 2'd1;
            2'd1: rx_sampleno <= 2'd2;
            2'd2: rx_sampleno <= 2'd0;
        endcase

    // RX strobe generator
    reg  [1:0] rx_strobereg = 2'b00;
    wire       rx_strobe    = (rx_strobereg == 2'b01);
    always @(posedge clk or negedge reset)
        if(!reset)
            rx_strobereg <= 2'b00;
        else
            rx_strobereg <= {rx_strobereg[0], rx_samplerdy};

    // RX state machine
    localparam RX_IDLE  = 3'd0,
               RX_START = 3'd1,
               RX_DATA  = 3'd2,
               RX_STOP  = 3'd3,
               RX_FULL  = 3'd4,
               RX_ERROR = 3'd5;
    reg  [2:0] rx_state = 3'd0;
    reg  [7:0] rx_data  = 8'b00000000;
    reg  [2:0] rx_bitno = 3'd0;
    always @(posedge clk or negedge reset)
        if(!reset) begin
            rx_sampler_reset <= 1'b0;
            rx_state <= RX_IDLE;
            rx_data <= 8'b00000000;
            rx_bitno <= 3'd0;
        end else case(rx_state)
            RX_IDLE:
                if(!rx_i) begin
                    rx_sampler_reset <= 1'b1;
                    rx_state <= RX_START;
                end
            RX_START:
                if(rx_strobe)
                    rx_state <= RX_DATA;
            RX_DATA:
                if(rx_strobe) begin
                    if(rx_bitno == 3'd7)
                        rx_state <= RX_STOP;
                    rx_data <= {rx_sample1, rx_data[7:1]};
                    rx_bitno <= rx_bitno + 3'd1;
                end
            RX_STOP:
                if(rx_strobe) begin
                    rx_sampler_reset <= 1'b0;
                    if(rx_sample1 == 1'b0)
                        rx_state <= RX_ERROR;
                    else
                        rx_state <= RX_FULL;
                end
            RX_FULL:
                if(rx_ack_i)
                    rx_state <= RX_IDLE;
                else if(!rx_i)
                    rx_state <= RX_ERROR;
        endcase

    assign rx_data_o  = rx_data;
    assign rx_ready_o = (rx_state == RX_FULL);
    assign rx_error_o = (rx_state == RX_ERROR);

    // TX sampler
    reg        tx_sampler_reset = 1'b0;
    wire       tx_sampler_clk;
    ClockDiv #(
        .FREQ_I(FREQ),
        // Make sure TX baud is exactly the same as RX baud, even after all the rounding that
        // might have happened inside rx_sampler_clk_div, by replicating it here.
        // Otherwise, anything that sends an octet every time it receives an octet will
        // eventually catch a frame error.
        .FREQ_O(FREQ / ((FREQ / (BAUD * 3) / 2) * 2) / 3),
        .PHASE(1'b0),
        .MAX_PPM(50_000)
    ) tx_sampler_clk_div (
        .reset(tx_sampler_reset),
        .clk_i(clk),
        .clk_o(tx_sampler_clk)
    );

    // TX strobe generator
    reg  [1:0] tx_strobereg = 2'b00;
    wire       tx_strobe    = (tx_strobereg == 2'b01);
    always @(posedge clk or negedge reset)
        if(!reset)
            tx_strobereg <= 2'b00;
        else
            tx_strobereg <= {tx_strobereg[0], tx_sampler_clk};

    // TX state machine
    localparam TX_IDLE  = 3'd0,
               TX_START = 3'd1,
               TX_DATA  = 3'd2,
               TX_STOP0 = 3'd3,
               TX_STOP1 = 3'd4;
    reg  [2:0] tx_state = 3'd0;
    reg  [7:0] tx_data  = 8'b00000000;
    reg  [2:0] tx_bitno = 3'd0;
    reg        tx_buf   = 1'b1;
    always @(posedge clk or negedge reset)
        if(!reset) begin
            tx_sampler_reset <= 1'b0;
            tx_state <= 3'd0;
            tx_data <= 8'b00000000;
            tx_bitno <= 3'd0;
            tx_buf <= 1'b1;
        end else case(tx_state)
            TX_IDLE:
                if(tx_ready_i) begin
                    tx_sampler_reset <= 1'b1;
                    tx_state <= TX_START;
                    tx_data <= tx_data_i;
                end
            TX_START:
                if(tx_strobe) begin
                    tx_state <= TX_DATA;
                    tx_buf <= 1'b0;
                end
            TX_DATA:
                if(tx_strobe) begin
                    if(tx_bitno == 3'd7)
                        tx_state <= TX_STOP0;
                    tx_data <= {1'b0, tx_data[7:1]};
                    tx_bitno <= tx_bitno + 3'd1;
                    tx_buf <= tx_data[0];
                end
            TX_STOP0:
                if(tx_strobe) begin
                    tx_state <= TX_STOP1;
                    tx_buf <= 1'b1;
                end
            TX_STOP1:
                if(tx_strobe) begin
                    tx_sampler_reset <= 1'b0;
                    tx_state <= TX_IDLE;
                end
        endcase

    assign tx_o       = tx_buf;
    assign tx_ack_o   = (tx_state == TX_IDLE);

endmodule

`ifdef TEST
`timescale 1us/1ns
`define f (1_000_000.0/1_000_000.0)
`define t (1_000_000.0/9600.0)
`define assert(x) if(!(x)) begin \
        $error("at %8t: assertion failed: (%s) = %b", $time, "x", x); \
        #100; \
        $finish_and_return(1); \
    end #0
module UARTTest();
    reg        baud_clk = 1'b0;
    always #(`t/2) baud_clk = ~baud_clk;

    reg        reset = 1'b0;
    reg        clk = 1'b0;
    always #(`f/2) clk = ~clk;

    reg        rx = 1'b1;
    wire [7:0] rx_data;
    wire       rx_ready;
    reg        rx_ack = 1'b0;
    wire       rx_error;
    wire       tx;
    reg  [7:0] tx_data;
    reg        tx_ready;
    wire       tx_ack;
    UART #(
        .FREQ(1_000_000)
    ) uart (
        .reset(reset),
        .clk(clk),
        .rx_i(rx),
        .rx_data_o(rx_data),
        .rx_ready_o(rx_ready),
        .rx_ack_i(rx_ack),
        .rx_error_o(rx_error),
        .tx_o(tx),
        .tx_data_i(tx_data),
        .tx_ready_i(tx_ready),
        .tx_ack_o(tx_ack)
    );

    initial begin
        $dumpfile("UARTTest.vcd");
        $dumpvars(0, UARTTest);

        #10 reset = 1;

        // RX tests
        `define B(v) rx = v; #`t;
        `define S    `B(0) `assert (rx_error === 0); `assert(rx_ready === 0);
        `define D(v) `B(v) `assert (rx_error === 0); `assert(rx_ready === 0);
        `define E    `B(1) `assert (rx_error === 0);
        `define A(v) #`t; `assert (rx_data === v); \
                     rx_ack = 1; while(rx_ready) #1; rx_ack = 0;
        `define F    #`t; `assert (rx_error === 1); \
                     rx = 1; reset = 0; while(rx_error) #1; reset = 1;

        // bit patterns
        #20 `S `D(1) `D(0) `D(1) `D(0) `D(1) `D(0) `D(1) `D(0) `E  `A(8'h55)
        #5  `S `D(1) `D(1) `D(0) `D(0) `D(0) `D(0) `D(1) `D(1) `E  `A(8'hC3)
        #30 `S `D(1) `D(0) `D(0) `D(0) `D(0) `D(0) `D(0) `D(1) `E  `A(8'h81)
        #3  `S `D(1) `D(0) `D(1) `D(0) `D(0) `D(1) `D(0) `D(1) `E  `A(8'hA5)
        #10 `S `D(1) `D(1) `D(1) `D(1) `D(1) `D(1) `D(1) `D(1) `E  `A(8'hFF)

        // framing error
        #5  `S `D(1) `D(1) `D(1) `D(1) `D(1) `D(1) `D(1) `D(1) `B(0) `F

        // overflow error
        #10 `S `D(1) `D(1) `D(1) `D(1) `D(1) `D(1) `D(1) `D(1) `E  `B(0) `F

        `undef B
        `undef S
        `undef D
        `undef E
        `undef A
        `undef F

        #10;

        // TX tests
        `define B(v) #`t; `assert (tx === v);
        `define S(v) `assert (tx === 1); `assert (tx_ack == 1); \
                     tx_data = v; tx_ready = 1; while(tx) #(`t/50); #(`t/2); tx_ready = 0; \
                     `assert (tx === 0); `assert (tx_ack == 0);
        `define D(v) `assert (tx_ack == 0); `B(v)
        `define E    `assert (tx_ack == 0); `B(1) \
                     `assert (tx_ack == 0); #100;

        `S(8'h55) `D(1) `D(0) `D(1) `D(0) `D(1) `D(0) `D(1) `D(0) `E
        `S(8'h81) `D(1) `D(0) `D(0) `D(0) `D(0) `D(0) `D(0) `D(1) `E
        `S(8'hFF) `D(1) `D(1) `D(1) `D(1) `D(1) `D(1) `D(1) `D(1) `E
        `S(8'h00) `D(0) `D(0) `D(0) `D(0) `D(0) `D(0) `D(0) `D(0) `E

        `undef B
        `undef S
        `undef E

        #100;
        $finish;
    end
endmodule
`endif
