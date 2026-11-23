`timescale 1ns / 1ps


module test_bench();
    localparam SYSTEM_FREQUENCY   = 50_000_000;
    localparam BAUDRATE_FREQUENCY = 115_200;

    localparam DIVIDE_RATIO = SYSTEM_FREQUENCY/BAUDRATE_FREQUENCY;

    //Signals that module would use
    logic clk_i;
    logic rst_ni;
    logic tx_en;
    logic [7:0] tx_data_in;
    logic tx_to_rx_loopback;
    logic [7:0] rx_data_out;

    fsm_uart # (
        .SYSTEM_FREQUENCY(SYSTEM_FREQUENCY),
        .BAUDRATE_FREQUENCY(BAUDRATE_FREQUENCY)
    ) u_uart (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .tx_en(tx_en),

        .tx_data_in(tx_data_in),
        .tx_data_out(tx_to_rx_loopback),
        .rx_data_in(tx_to_rx_loopback),
        .rx_data_out(rx_data_out)
    );

    localparam clk_T = 20;

    assign #clk_T clk_i = ~clk_i;

    //generate stimulation
    initial begin
        clk_i = 1;
        rst_ni = 0;
        tx_en = 0;
        tx_data_in = 8'b01101110;

        #(clk_T*2.5);
        rst_ni = 1;
        #(clk_T*2.5);

        tx_en = 1;
        #(clk_T*DIVIDE_RATIO);
        tx_en = 0;

        #(clk_T*DIVIDE_RATIO*9);
        tx_data_in = 8'b10000011;
        tx_en = 1;
        #(clk_T*DIVIDE_RATIO*2);

        tx_en = 0;

        #(clk_T*DIVIDE_RATIO*11);
        
        $finish;
    end

endmodule
