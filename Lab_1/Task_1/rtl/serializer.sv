module serializer #(
  parameter DATA_W = 5'd16
) (
  input  logic                              clk_i,
  input  logic                              srst_i,
  input  logic [( DATA_W - 1 ):0]           data_i,
  input  logic [( $clog2(DATA_W) - 1 ):0 ]  data_mod_i,
  input  logic                              data_val_i,

  output logic                              ser_data_o,
  output logic                              ser_data_val_o,
  output logic                              busy_o 
);

logic [( $clog2(DATA_W)     ):0] num_cnt;
logic [( $clog2(DATA_W) - 1 ):0] data_mod_cpy;
logic [( DATA_W - 1 ):0]         data_cpy;

bit finished;
bit prev_finished;
bit first_symb;

always_comb
  begin
    if ( data_val_i )
      first_symb = data_i[15];
    else
      first_symb = 1'b0;
  end

// this block recognises if output is finished or not
always_comb 
  begin
    if ( data_val_i )
      begin
        if ( ( data_mod_i == 4'd1 ) || ( data_mod_i == 4'd2 ) )
          finished = 1'b1;
        else
          finished = 1'b0;
      end
    else if ( ( num_cnt == data_mod_cpy + 1'b1 ) )
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

// save values
always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      data_mod_cpy <= 4'd0;
    else
      begin
        if ( !finished && prev_finished )
          begin
            if ( data_mod_i == 0 )
              data_mod_cpy <= 4'd15;
            else
              data_mod_cpy <= data_mod_i - 1'b1;
          end
      end
  end

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      data_cpy <= 16'd0;
    else
      begin
        if ( !finished && prev_finished )
          data_cpy <= data_i;
      end
  end

always_ff @( posedge clk_i )
  prev_finished <= finished;  

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
          if ( num_cnt == 5'd0 )
            ser_data_o <= first_symb;
          else
            ser_data_o <= data_cpy[DATA_W - 1 - num_cnt];
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