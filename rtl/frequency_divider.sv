module frequency_divider #(
    parameter int unsigned SYSTEM_FREQUENCY = 50_000_000,
    parameter int unsigned TARGET_FREQUENCY = 115_200
) (
    input  logic clk_i,
    input  logic rst_ni,
    input  logic clear_ni,
    output logic pulse_o

);
    localparam int unsigned Divider_Counter_Target = SYSTEM_FREQUENCY/TARGET_FREQUENCY-1;
    localparam int unsigned Counter_Width          = $clog2(Divider_Counter_Target + 1);

    logic [Counter_Width - 1 :0] divider_counter;
    logic                        pulse_o_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(!rst_ni) begin
            divider_counter <= 0;
            pulse_o_q       <= 0;
        end else if(!clear_ni) begin
            divider_counter <= 0;
            pulse_o_q       <= 0;
        end else if (divider_counter == 0) begin
            pulse_o_q <= 1;
            divider_counter <= divider_counter + 1;
        end else if (divider_counter == Divider_Counter_Target) begin
            divider_counter <= 0;
            pulse_o_q <=0;
        end else begin
            divider_counter <= divider_counter + 1;
            pulse_o_q <= 0;
        end
    end
    assign pulse_o = pulse_o_q;

endmodule