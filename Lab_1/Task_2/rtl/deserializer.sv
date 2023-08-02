module deserializer #(
    parameter [5:0] DATA_W = 5'd16
) (
  input  logic                       clk_i,
  input  logic                       srst_i,
  input  logic                       data_i,
  input  logic                       data_val_i,

  output logic [ DATA_W - 5'd1 :0]   deser_data_o,
  output logic                       deser_data_val_o
);

bit [ $clog2(DATA_W) :0] bit_cnt;
bit                          data_val_cpy;
bit                          prev_val;

// bit_cnt block
always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      bit_cnt <= 4'd0;
    else if ( bit_cnt == 5'd16 )
      bit_cnt <= 4'd0;
    else
      begin
        if ( data_val_i )
           bit_cnt <= bit_cnt + 1'b1;
      end
  end

always_ff @( posedge clk_i )
  prev_val <= data_val_i;

always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      deser_data_o <= 4'd0;
    else if ( bit_cnt == 5'd16 )
      deser_data_o <= 4'd0;
    else
      begin
        if ( data_val_i )
          deser_data_o <= {deser_data_o[14:0], data_i};
      end
  end

assign deser_data_val_o = ( ( bit_cnt == 5'd16 ) && prev_val );

endmodule