module fsm_uart # (
    parameter int unsigned SYSTEM_FREQUENCY   = 50_000_000,
    parameter int unsigned BAUDRATE_FREQUENCY = 115_200
) (
    input  logic       clk_i,
    input  logic       rst_ni,
    input  logic       tx_en,

    input  logic [7:0] tx_data_in,
    output logic       tx_data_out,
    input  logic       rx_data_in,
    output logic [7:0] rx_data_out
);
    logic rx_data_in_q1 = 1;
    logic rx_data_in_q2 = 1;

    logic tx_en_q1 = 0;
    logic tx_en_q2 = 0;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(!rst_ni) begin
            rx_data_in_q1 <= 1;
            rx_data_in_q2 <= 1;

            tx_en_q1      <= 0;
            tx_en_q2      <= 0;
        end else begin
            rx_data_in_q1 <= rx_data_in;
            rx_data_in_q2 <= rx_data_in_q1;

            tx_en_q1      <= tx_en;
            tx_en_q2      <= tx_en_q1;
        end
    end

    fsm_uart_tx # (
        .SYSTEM_FREQUENCY(SYSTEM_FREQUENCY),
        .TARGET_FREQUENCY(BAUDRATE_FREQUENCY)
    ) u_uart_tx (
        .clk_i           (clk_i),
        .rst_ni          (rst_ni),
        .send_en_control (tx_en_q2),
        .tx_data_in      (tx_data_in),
        .tx_data_out     (tx_data_out)
    );

    fsm_uart_rx # (
        .SYSTEM_FREQUENCY(SYSTEM_FREQUENCY),
        .TARGET_FREQUENCY(BAUDRATE_FREQUENCY)
    ) u_uart_rx (
        .clk_i       (clk_i),
        .rst_ni      (rst_ni),
        .rx_data_in  (rx_data_in_q2),
        .rx_data_out (rx_data_out)
    );

endmodule