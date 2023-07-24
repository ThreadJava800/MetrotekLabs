module serializer_tb;

localparam TEST_NUMBER = 10; 

bit           clk;

logic         srst;
logic [15:0]  data;
logic [3:0 ]  data_mod;
logic         data_val;

initial
  forever
    #5 clk = !clk;

default clocking cb 
  @( posedge clk );
endclocking

logic ser_data;
logic ser_data_val;
logic busy;

bit [15:0] testValue;
bit [3:0]  testMod;

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

typedef struct {
  logic [15:0] data_i_test;
  logic [3 :0] data_mod_test;
  logic        data_val_test;
} input_data;

task fill_mailbox ( mailbox #( input_data ) tests );
  for ( int i = 0; i < TEST_NUMBER; i++ )
    begin
      input_data test;

      test.data_i_test   = $urandom_range( ( 2**16 - 1 ), 0 );
      test.data_mod_test = $urandom_range( 3, 0 );

      tests.put( test );
    end
endtask

bit         success;
int         success_cnt;
logic [3:0] temp_mod;

task test ( mailbox #( input_data ) tests );
  while ( tests.num() > 0 )
    begin
      input_data test;
      tests.get( test );

      data     = test.data_i_test;
      data_mod = test.data_mod_test;

      data_val = 1'b1;
      ##1;
      data_val = 1'b0;

      success = 1'b1;

      temp_mod = (data_mod == 4'b0) ? 4'd15 : ( data_mod - 1'b1 );

      for ( int i = 0; i < temp_mod; i++ )
        begin
          if ( ( ser_data_val ) && ( busy ) )
            begin
              if ( ser_data != data[15 - i] )
                begin
                  $display( "Incorrect value: test: %d, pos: %d\n
                             Expected: %d\n
                             Got: %d", data, i, data[15 - i], ser_data);

                  success = 1'b0;
                end
            end
          else
            begin
              $display( "Incorrect support signals: test: %d, pos: %d\n
                         Expected: ser_data_val = 1, busy = 1\n
                         Got: ser_data_val = %d, busy = %d", data, i, ser_data_val, busy);

              success = 1'b0;
            end
        end

        if ( success )
          success_cnt++;
    end

    if ( success == TEST_NUMBER )
      $display( "All tests were successful!" );
endtask

mailbox #( input_data ) test_box = new();

initial
  begin
    srst <= 1'b1;
    ##1;
    srst <= 1'b0;

    fill_mailbox( test_box );
    test( test_box );
  end

endmodule