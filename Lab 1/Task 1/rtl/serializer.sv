module serializer #(
    parameter MAX_WORD_LEN = 16
)(
    input logic         clk_i,
    input logic         srst_i,
    input logic [15:0]  data_i,
    input logic [3:0 ]  data_mod_i,
    input logic         data_val_i,

    output logic        ser_data_o,
    output logic        ser_data_val_o,
    output logic        busy_o 
);

logic [3:0] num_cnt;

always_ff @(posedge clk_i)
    begin
        // синхронный сброс
        if (srst_i)
            begin
                ser_data_o     <= 1'b0;
                busy_o         <= 1'b0;
                ser_data_val_o <= 1'b1;

                if (data_mod_i == 0)
                    num_cnt = MAX_WORD_LEN;
                else
                    num_cnt = data_mod_i;

                // srst_i <= 1'b0;
            end
        else
            begin
                if (data_val_i)
                    begin
                        if (num_cnt != 0)
                            begin
                                ser_data_o     <= data_i[MAX_WORD_LEN - num_cnt];
                                busy_o         <= 1'b1;
                                ser_data_val_o <= 1'b0;

                                num_cnt <= num_cnt - 1;
                            end
                        else
                            begin
                                ser_data_o     <= data_i[MAX_WORD_LEN - num_cnt];
                                busy_o         <= 1'b0;
                                ser_data_val_o <= 1'b1;
                            end
                    end
            end

    end

// assign ser_data_o = ser_data;

endmodule