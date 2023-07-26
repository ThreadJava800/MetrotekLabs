module serializer_tb;

parameter TEST_NUM = 2 ** 16;

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
int test_cnt  = 0;

initial
  begin
    srst = 1'b1;
    ##1 srst = 1'b0;

    ##2;

        // data      = 'd32768 + 1;
        // data_mod  = 0;
        // data_val  = 1'b1;

        // ##1;

        // data_val  = 1'b0;
        // data_mod = 13;
        // data = 123782;

        // for (int i = 0; i <= 15; i++)
        //   $display(data[5'd16 - 1 - i]);

    for ( int i = 0; i < TEST_NUM; i++ )
      begin
        // testValue = i;
        testValue = $urandom_range(2**16 - 1, 0);
        testMod   = $urandom_range(15, 0);
        success   = 1'b1;

        data      = testValue;
        data_mod  = testMod;
        data_val  = 1'b1;

        ##1;

        data_val  = 1'b0;
        data      = 0;
        data_mod  = 0;

        test_mod_cycle = ( testMod == 0 ) ? 16 : testMod;

        for ( int i = 0; i < test_mod_cycle; i++ )
          begin
            // $display ("%d %d %d", testValue, testValue[15 - i], ser_data);
            if ( ( testMod != 1 ) && ( testMod != 2 ) )
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
    
                    success = 1'b0;
                  end
              end
            ##1;
          end

        if ( success )
          test_cnt++;
      end

    if ( test_cnt == TEST_NUM )
        $display( "All tests passed!" );
  end

endmodule