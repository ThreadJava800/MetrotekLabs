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

logic [4:0] num_cnt;
logic [3:0] data_mod_cpy;
logic finished;

always_comb 
  begin
    if ( ( data_val_i ) && ( !busy_o ) )
      begin
        finished = 1'b0;

        // set  data_mod_cpy to MAX (15) if data_mod = 0
        // else data_mod_cpy = data_mod
        data_mod_cpy = data_mod_i;
        if ( !data_mod_i )
          data_mod_cpy = MAX_WORD_LEN;
      end
    if ( (num_cnt == data_mod_cpy + 1'b1) )
      finished = 1'b1;
  end

// reset block
always_ff @( posedge clk_i )
  begin
    // reset => default state
    if ( srst_i )
      begin
        ser_data_o     <= 16'b0;
        ser_data_val_o <= 1'b0;  // data not valid
        busy_o         <= 1'b0;  // module is not busy

        num_cnt        <= 4'b0;
      end
  end

always_ff @( posedge clk_i )
  begin
    if ( finished )
      begin
        busy_o         <= 1'b0;
        ser_data_val_o <= 1'b0;
        ser_data_o     <= 1'b0;

        num_cnt        <= 4'b0;
      end
  end

// main logic block
always_ff @( posedge clk_i )
  begin
    if ( !finished )
      begin
        busy_o <= 1'b1;

        ser_data_o     <= data_i[MAX_WORD_LEN - num_cnt];
        ser_data_val_o <= 1'b1;
        num_cnt        <= num_cnt + 1'b1;  // move to next number
      end
  end

endmodule