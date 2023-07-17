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


// reset block
always_ff @( posedge clk_i )
  begin
    // reset => default state
    if ( srst_i )
      begin
        ser_data_o     <= 16'b0;
        ser_data_val_o <= 1'b0;  // data not valid
        busy_o         <= 1'b0;  // module is not busy
      end
  end

// data_val_i active (1 clock) => start new calculation
always_ff @( posedge clk_i )
  begin
    if ( ( data_val_i ) && ( !busy_o ) )
      begin
        busy_o         <= 1'b1;  // module is busy
        ser_data_val_o <= 1'b0;

        // set  num_cnt to MAX (15) if data_mod = 0
        // else num_cnt = data_mod
        num_cnt <= data_mod_i;
        if ( !data_mod_i )
          num_cnt <= MAX_WORD_LEN;
      end
  end

// main calculation block
always_ff @( posedge clk_i )
  begin
    if ( num_cnt > 0 )
      begin
        ser_data_o     <= data_i[MAX_WORD_LEN - num_cnt];
        ser_data_val_o <= 1'b1;

        num_cnt        <= num_cnt - 1'b1;  // move to next number
      end
    else
      begin
        // last number, so setting busy to 0
        ser_data_o     <= data_i[MAX_WORD_LEN];
        ser_data_val_o <= 1'b0;
        busy_o         <= 1'b0;
      end
  end

endmodule