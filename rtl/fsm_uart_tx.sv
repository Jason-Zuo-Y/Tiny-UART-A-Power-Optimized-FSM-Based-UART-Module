module fsm_uart_tx #(
    parameter int unsigned SYSTEM_FREQUENCY = 50_000_000,
    parameter int unsigned TARGET_FREQUENCY = 115_200
) (
    input  logic       clk_i,
    input  logic       rst_ni,
    input  logic       send_en_control,
    input  logic [7:0] tx_data_in,
    output logic       tx_data_out
    
);

    logic       tx_data_out_q = 1;
    logic [7:0] tx_data = 8'h00;

    logic       baud_tick;
    logic       start_finish_flag = 0;
    logic [1:0] stop_finish_cnt  = 2'b00;

    logic [3:0] bit_cnt = 4'b0000;

    logic       cnt_div_ctrl = 0;

    frequency_divider #(
        .SYSTEM_FREQUENCY(SYSTEM_FREQUENCY),
        .TARGET_FREQUENCY(TARGET_FREQUENCY)
    ) u_cnt_divider (
        .clk_i   (clk_i),
        .rst_ni  (rst_ni),
        .clear_ni(cnt_div_ctrl),
        .pulse_o (baud_tick)
    );

    typedef enum logic [1:0]{
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b11,
        STOP  = 2'b10
    }uart_tx_state_t;

    uart_tx_state_t current_state = IDLE;
    uart_tx_state_t next_state;

    always_ff @( posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end




    always_comb begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (send_en_control) begin
                    next_state = START;
                end
            end

            START: begin
                if (start_finish_flag) begin
                    next_state = DATA;
                end
            end

            DATA: begin
                if (bit_cnt == 8) begin
                    next_state = STOP;
                end
            end

            STOP: begin
                if (stop_finish_cnt == 3) begin
                    next_state = IDLE;
                end
            end
        endcase
    end



    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(!rst_ni) begin
            tx_data_out_q     <= 1;
            start_finish_flag <= 0;
            stop_finish_cnt   <= 0;
            tx_data           <= 8'h00;
            bit_cnt           <= 4'b0000;
            cnt_div_ctrl      <= 0;


        end else begin
            case (current_state)
                IDLE: begin
                    tx_data_out_q   <= 1;
                    stop_finish_cnt <= 2'b00;
                    if(send_en_control) begin
                        tx_data <= tx_data_in;
                        cnt_div_ctrl <= 1;
                    end
                end

                START: begin
                    if(baud_tick) begin
                        tx_data_out_q     <= 0;
                        start_finish_flag <= 1;
                    end
                end

                DATA: begin
                    if(baud_tick) begin
                        start_finish_flag <= 0;
                        tx_data_out_q <= tx_data[0];
                        tx_data   <= { 1'b0, tx_data[7:1]};
                        bit_cnt   <= bit_cnt + 1;
                    end
                end

                STOP: begin
                    if(baud_tick) begin
                        tx_data_out_q   <= 1;
                        stop_finish_cnt <= stop_finish_cnt + 1;
                        bit_cnt         <= 0;

                        if(stop_finish_cnt == 2)begin
                            cnt_div_ctrl <= 0;
                        end
                    end
                end

            endcase
        end
    end


    assign tx_data_out = tx_data_out_q;

endmodule