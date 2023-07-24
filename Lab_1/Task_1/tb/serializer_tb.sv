module serializer_tb;

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

bit [15:0] testValue;
bit [3:0]  testMod;
bit        success;

int test_mod_cycle;

initial
  begin
    automatic int test_cnt  = 0;

    srst <= 1'b1;
    ##1 srst <= 1'b0;

    for ( int i = 0; i < 2 ** 16; i++ )
      begin
        testValue = i;
        testMod   = $urandom_range(15, 0);
        success   = 1'b1;

        data     <= testValue;
        data_mod <= testMod;
        data_val <= 1'b1;

        ##1;

        data_val <= 1'b0;

        test_mod_cycle = ( testMod == 0 ) ? 16 : testMod;

        for ( int i = 0; i < test_mod_cycle; i++ )
          begin
            // $display ("%d %d %d", testValue, testValue[15 - i], ser_data);
            if ( ( data_mod != 1 ) && ( data_mod != 2 ) )
              begin
                if ( ( ser_data != testValue[15 - i] ) || ( !ser_data_val ) || ( !busy ) )
                  begin
                    $display( "Error: test: data_i=%d data_mod_i=%d number_pos=%d", testValue, testMod, i );
                    $display( "\t Expected: ser_data_o=%d, ser_data_val=1, busy_o=1 ", testValue[15 - i] );
                    $display( "\t Got: ser_data_o=%d, ser_data_val=%d, busy_o=%d ", ser_data, ser_data_val, busy );
    
                    success = 1'b0;;
                  end
              end
            else
              begin
                if ( ( ser_data_val ) || ( busy ) )
                  begin
                    $display( "Error: test: data_i=%d data_mod_i=%d number_pos=%d", testValue, testMod, i );
                    $display( "\t Expected: ser_data_o=%d, ser_data_val=1, busy_o=1 ", testValue[15 - i] );
                    $display( "\t Got: ser_data_o=%d, ser_data_val=%d, busy_o=%d ", ser_data, ser_data_val, busy );
    
                    success = 1'b0;;
                  end
              end
            ##1;
          end

        if ( success )
          test_cnt++;
      end

    if ( test_cnt == 2 ** 16 )
        $display( "All tests passed!" );
  end

endmodule