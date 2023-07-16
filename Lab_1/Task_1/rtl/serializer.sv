module serializer #(
    parameter MAX_WORD_LEN = 4'd15,
    parameter TRUE         = 1'b1,
    parameter FALSE        = 1'b0
)(
    input  logic         clk_i,
    input  logic         srst_i,
    input  logic [15:0]  data_i,
    input  logic [3:0 ]  data_mod_i,
    input  logic         data_val_i,

    output logic         ser_data_o,
    output logic         ser_data_val_o,
    output logic         busy_o 
);

logic [3:0] num_cnt;
logic       valid_mod;

always_ff @( posedge clk_i )
    begin
        // синхронный сброс
        if ( srst_i )
            begin
                ser_data_o     <= 1'b0;
                busy_o         <= FALSE;
                ser_data_val_o <= TRUE;

                valid_mod      <= TRUE;

                if ( data_mod_i == 0 )
                    num_cnt <= MAX_WORD_LEN;
                else
                    begin
                        if ( ( data_mod_i == 1 ) || ( data_mod_i == 2 ) )
                            valid_mod <= FALSE;
                        else
                            valid_mod <= TRUE;

                        num_cnt <= data_mod_i;
                    end
            end
        else
            begin
                if ( ( data_val_i ) && ( valid_mod ) )
                    begin
                        if ( num_cnt != 0 )
                            begin
                                ser_data_o     <= data_i[MAX_WORD_LEN - num_cnt];
                                busy_o         <= TRUE;
                                ser_data_val_o <= FALSE;

                                num_cnt <= num_cnt - 1'b1;
                            end
                        else
                            begin
                                ser_data_o     <= data_i[MAX_WORD_LEN];
                                busy_o         <= FALSE;
                                ser_data_val_o <= TRUE;
                            end
                    end
            end

    end

endmodule