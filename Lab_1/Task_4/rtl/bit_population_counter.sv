module bit_population_counter #(
    parameter int WIDTH = 32
) (
  input  logic                     clk_i,
  input  logic                     srst_i,
  input  logic [ WIDTH - 1 :0]     data_i,
  input  logic                     data_val_i,

  output logic [ $clog2(WIDTH) :0] data_o,
  output logic                     data_val_o
);

logic [$clog2(WIDTH) :0] bit_cnt;

// set data_val_o
always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      data_val_o <= 1'b0;
    else
      data_val_o <= data_val_i;
  end

// set data_o
always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      data_o <= 1'b0;
    else
      data_o <= bit_cnt;
  end

// generate bit_cnt
always_comb 
  begin
    bit_cnt = ( $clog2(WIDTH) )'(0);

    for ( int i = 0; i < WIDTH; i++ )
      begin
        if ( data_i[i] == 1'b1 )
          bit_cnt++;
      end
  end

endmodule