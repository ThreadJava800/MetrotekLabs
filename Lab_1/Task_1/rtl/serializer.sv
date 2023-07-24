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

always_comb
  begin
    if ( !data_mod_i )
      data_mod_cpy = MAX_WORD_LEN;
    else
      data_mod_cpy = data_mod_i - 1'b1;
  end

// this block recognises if output is finished or not
always_comb 
  begin
    if ( srst_i )
      finished = 1'b1;
    else if ( ( data_val_i ) )
      finished = 1'b0;
    else if ( (num_cnt == data_mod_cpy + 1'b1) )
      // finished sending numbers  
      finished = 1'b1;
    else
      begin
        if ( busy_o )
          finished = 1'b0;
        else
          finished = 1'b1;
      end
  end

// ser_data_o block
always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      ser_data_o <= 1'b0;
    else
      begin
        if ( finished )
          ser_data_o <= 1'b0;
        else
          ser_data_o <= data_i[MAX_WORD_LEN - num_cnt];
      end
  end

// ser_data_val_o block
always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      ser_data_val_o <= 1'b0;
    else
      begin
        if ( finished )
          ser_data_val_o <= 1'b0;
        else
          ser_data_val_o <= 1'b1;
      end
  end

// busy_o block
always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      busy_o <= 1'b0;
    else
      begin
        if ( finished )
          busy_o <= 1'b0;
        else
          busy_o <= 1'b1;
      end
  end

// num_cnt block
always_ff @( posedge clk_i )
  begin
    if ( srst_i )
       num_cnt <= 4'b0;
    else
      begin
        if ( finished )
          num_cnt <= 4'b0;
        else
          num_cnt <= num_cnt + 1'b1;
      end
  end

endmodule