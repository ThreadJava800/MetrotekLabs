module serializer_tb;

bit         clk;
bit         srst;
bit [15:0]  data;
bit [3:0 ]  data_mod;
bit         data_val;

initial
  forever
    #5 clk = !clk;

default clocking cb 
  @( posedge clk );
endclocking

bit ser_data;
bit ser_data_val;
bit busy;

serializer DUT (
  .clk_i          (clk),
  .srst_i         (srst),
  .data_i         (data),
  .data_mod_i     (data_mod),
  .data_val_i     (data_val),
  .ser_data_o     (ser_data),
  .ser_data_val_o (ser_data_val),
  .busy_o         (busy)
);

task testBench( input [15:0] data_test, input [3:0] data_mod_test, input data_val_test, input [15:0] check_arr );
  static bit [3:0] num_count = 'd15;
  static bit       success   = 1'b1;

  if ( data_mod_test )
    num_count = data_mod_test;
  else
    num_count = 15;

  wait ( busy );

  for ( int i = 0; i <= num_count; i++ )
    begin
      ##1;

      if ( ( check_arr[15 - i] != ser_data ) )
        begin
          $display( "Error: test: data_i=%d data_mod_i=%d data_val=%d number_pos=%d", data_test, data_mod_test, data_val_test, i );
          $display( "\t Expected: ser_data_o=%d, ser_data_val=1, busy_o=1 ", check_arr[15 - i] );
          $display( "\t Got: ser_data_o=%d, ser_data_val=%d, busy_o=%d ", ser_data, ser_data_val, busy );

          success = 1'b0;
        //   break;
        end
    end

  if ( success )
    begin
      if ( ( ser_data_val == 1'b0 ) && ( busy == 1'b0 ) )
        $display( "Test was successful!" );
      else
        begin
          $display( "Error: test: data_i=%d data_mod_i=%d data_val=%d", data_test, data_mod_test, data_val_test );
          $display( "\t Expected: ser_data_val=0, busy_o=0 " );
          $display( "\t Got: ser_data_val=%d, busy_o=%d ", ser_data_val, busy );
        end
    end
endtask

`define set_data(DATA, DATA_MOD, DATA_VAL) \
  srst     <= 1'b1;                         \
  data     <= DATA;                          \
  data_mod <= DATA_MOD;                       \
  ##1 srst <= 1'b0;                            \
  #4 data_val <= 1'b1;                         \
  ##1 data_val <= 1'b0;

initial
  begin
    `set_data( 'd15, 'd0, '1       )
    testBench( 'd15, 'd0, '1, 'd15 );
  end

endmodule