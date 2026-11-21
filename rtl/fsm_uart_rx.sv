module fsm_uart_rx # (
    parameter int unsigned SYSTEM_FREQUENCY = 50_000_000,
    parameter int unsigned TARGET_FREQUENCY = 115_200
) (
    input  logic       clk_i,
    input  logic       rst_ni,
    input  logic       rx_data_in,
    output logic [7:0] rx_data_out
);
    typedef enum logic [1:0]{
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b11,
        STOP  = 2'b10
    } uart_rx_state;

    uart_rx_state current_state = IDLE;
    uart_rx_state next_state;

    logic       double_baud_tick;     //2x oversampling and center-aligned single-sampling
    logic       cnt_div_ctrl      = 0;      //place 1 here to start the count-divider
    logic [7:0] rx_data_q         = 8'h00;     //buff for parallel output
    logic [4:0] bit_cnt           = 5'b00000;
    logic [1:0] start_finish_cnt  = 2'b00;
    logic       fake_start_flag   = 0;         //fake start marker
    logic [1:0] stop_finish_cnt   = 2'b00;

    frequency_divider # (
        .SYSTEM_FREQUENCY(SYSTEM_FREQUENCY),
        .TARGET_FREQUENCY(TARGET_FREQUENCY*2)  //2x oversampling
    ) u_cnt_divider (
        .clk_i   (clk_i),
        .rst_ni  (rst_ni),
        .clear_ni(cnt_div_ctrl),
        .pulse_o (double_baud_tick)
    );



    always_ff @(posedge clk_i or negedge rst_ni) begin
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
                if(!rx_data_in) begin
                    next_state = START;
                end
            end

            START: begin
                if(fake_start_flag) begin
                    next_state = IDLE;
                end else if (start_finish_cnt==2) begin
                    next_state = DATA;
                end
            end

            DATA: begin
                if(bit_cnt == 16) begin
                    next_state = STOP;
                end
            end

            STOP: begin
                if(stop_finish_cnt == 2) begin
                    next_state = IDLE;
                end
            end
        endcase
    end


    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(!rst_ni) begin
            cnt_div_ctrl      <= 0;
            bit_cnt           <= 4'h0;
            start_finish_cnt  <= 2'b00;
            fake_start_flag   <= 0;
            stop_finish_cnt   <= 2'b00;
            rx_data_q         <= 8'h00;
            rx_data_out       <= 8'h00;

        end else begin
            case (current_state)
                IDLE: begin
                    rx_data_q         <= 8'h00;
                    cnt_div_ctrl      <= 0;
                    start_finish_cnt  <= 2'b00;
                    fake_start_flag   <= 0;
                    stop_finish_cnt   <= 2'b00;
                    bit_cnt           <= 5'b00000;
                    if (rx_data_in == 0) begin        //if START bit comes, start the divider
                        cnt_div_ctrl <= 1;            //and after at most 3 clock tick, the first pulse will be detected
                    end
                end



                START: begin
                    if(double_baud_tick) begin
                        start_finish_cnt <= start_finish_cnt + 1;
                        if(start_finish_cnt == 1) begin     //here I use the trait: it watches the old value of start_finish_cnt
                            fake_start_flag <= rx_data_in;  //so when the second pulse is detected, if condition will be true.
                        end                                 //directly judge if it is fake start.
                    end
                end

                DATA: begin
                    if(double_baud_tick) begin
                        start_finish_cnt <= 2'b00;
                        fake_start_flag  <= 0;
                        bit_cnt <= bit_cnt + 1;

                        if(bit_cnt%2==1) begin
                            rx_data_q <= {rx_data_in, rx_data_q[7:1]};
                        end
                    end
                end

                STOP: begin
                    if(double_baud_tick)begin
                        bit_cnt <= 5'b00000;
                        stop_finish_cnt <= stop_finish_cnt + 1;

                        if(stop_finish_cnt == 1) begin     //judge at half baudtick to see if there is dataframe error
                            if(rx_data_in)begin
                                rx_data_out <= rx_data_q;  //no, then send the result out.
                            end else begin
                                rx_data_out <= 0;          //yes, then keep NULL(0x00)
                            end
                        end
                    end
                end
            endcase
        end
    end

endmodule
