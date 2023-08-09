module priority_encoder #(
    parameter int WIDTH = 32
) (
  input  logic                 clk_i,
  input  logic                 srst_i,
  input  logic [ WIDTH - 1 :0] data_i,
  input  logic                 data_val_i,

  output logic [ WIDTH - 1 :0] data_left_o,
  output logic [ WIDTH - 1 :0] data_right_o,
  output logic                 data_val_o
);

logic [ WIDTH - 1 :0] data_left;
logic                 left_val;
logic [ WIDTH - 1 :0] data_right;
logic                 right_val;

// set data_val_o
always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      data_val_o <= 1'b0;
    else
      data_val_o <= data_val_i;
  end

// set data_left
always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      data_left_o <= 1'b0;
    else
      data_left_o <= data_left;
  end

// set data_right
always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      data_right_o <= 1'b0;
    else
      data_right_o <= data_right;
  end

// generate data_left
always_comb 
  begin
    data_right = ( WIDTH )'(0);
    right_val  = 1'b0;

    for ( int i = 0; i < WIDTH; i++ )
      begin
        if ( right_val )
          data_right[i] = 1'b0;
        else
          data_right[i] = data_i[i];

        if ( data_i[i] == 1'b1 )
          right_val = 1'b1;
      end
  end

// generate data_right
always_comb
  begin
    data_left = ( WIDTH )'(0);
    left_val  = 1'b0;

    for ( int i = WIDTH - 1; i >= 0; i-- )
      begin
        if ( left_val )
          data_left[i] = 1'b0;
        else
          data_left[i] = data_i[i];

        if ( data_i[i] == 1'b1 )
          left_val = 1'b1;
      end
  end

endmodule