module serializer #(
  parameter DATA_W = 15
) (
  input  logic                              clk_i,
  input  logic                              srst_i,
  input  logic [15:0]                       data_i,
  input  logic [( $clog2(DATA_W) - 1 ):0 ]  data_mod_i,
  input  logic                              data_val_i,

  output logic                              ser_data_o,
  output logic                              ser_data_val_o,
  output logic                              busy_o 
);

localparam MAX_WORD_LEN = 4'd15;

logic [( $clog2(DATA_W)     ):0] num_cnt;
logic [( $clog2(DATA_W) - 1 ):0] data_mod_cpy;
bit finished;

// this block recognises if output is finished or not
always_comb 
  begin
    // set  data_mod_cpy to MAX (15) if data_mod = 0
    // else data_mod_cpy = data_mod
    data_mod_cpy = data_mod_i;
    if ( !data_mod_i )
      data_mod_cpy = MAX_WORD_LEN;

    if ( ( data_val_i ) && ( !busy_o ) )
      finished = 1'b0;

    if ( srst_i )
      finished = 1'b1;

    // set finished to 1 if reset is present, or we finished sending numbers  
    if ( (num_cnt == data_mod_cpy + 1'b1) )
      finished = 1'b1;

    // needed for correct work of combinational logic
    else
      begin
        if ( finished )
          finished = 1'b1;
        else
          finished = 1'b0;
      end
  end

always_ff @( posedge clk_i )
  begin
    // reset => default state
    if ( srst_i )
      begin
        ser_data_o     <= 1'b0;
        ser_data_val_o <= 1'b0;  // data not valid
        busy_o         <= 1'b0;  // module is not busy

        num_cnt        <= 4'b0;
      end

    if ( finished )
      begin
        busy_o         <= 1'b0;
        ser_data_val_o <= 1'b0;
        ser_data_o     <= 1'b0;

        num_cnt        <= 4'b0;
      end
    else
      begin
        busy_o <= 1'b1;

        ser_data_o     <= data_i[MAX_WORD_LEN - num_cnt];
        ser_data_val_o <= 1'b1;
        num_cnt        <= num_cnt + 1'b1;  // move to next number
      end
  end

endmodule