module UARTLoopback(
        input        clk_12mhz,
        output [7:0] leds,
        input        uart_rx,
        output       uart_tx,
        output       debug1,
        output       debug2
    );

    wire [7:0] rx_data;
    wire       rx_ready;
    wire       rx_ack;
    wire       rx_error;
    wire [7:0] tx_data;
    wire       tx_ready;
    wire       tx_ack;
    UART #(
        .FREQ(12_000_000),
        .BAUD(115200)
    ) uart (
        .reset(1'b1),
        .clk(clk_12mhz),
        .rx_i(uart_rx),
        .rx_data_o(rx_data),
        .rx_ready_o(rx_ready),
        .rx_ack_i(rx_ack),
        .rx_error_o(rx_error),
        .tx_o(uart_tx),
        .tx_data_i(tx_data),
        .tx_ready_i(tx_ready),
        .tx_ack_o(tx_ack)
    );

    reg        empty     = 1'b1;
    reg  [7:0] data      = 8'h00;
    wire       rx_strobe = (rx_ready && empty);
    wire       tx_strobe = (tx_ack && !empty);
    always @(posedge clk_12mhz) begin
        if(rx_strobe) begin
            data <= rx_data;
            empty <= 1'b0;
        end
        if(tx_strobe)
            empty <= 1'b1;
    end

    assign rx_ack   = rx_strobe;
    assign tx_data  = data;
    assign tx_ready = tx_strobe;

    assign leds = {rx_error, rx_data[6:0]};
    assign debug1 = uart_rx;
    assign debug2 = uart_tx;

endmodule
