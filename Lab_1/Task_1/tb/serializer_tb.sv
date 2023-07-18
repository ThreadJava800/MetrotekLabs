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

initial
  begin
    automatic int test_cnt  = 0;

    srst <= 1'b1;
    ##1 srst <= 1'b0;

    repeat ( 10 )
      begin
        automatic bit [15:0] testValue = $urandom_range(131071, 0);
        automatic bit [3:0]  testMod   = $urandom_range(15, 0);
        automatic bit        success   = 1'b1;

        data     <= testValue;
        data_mod <= testMod;
        data_val <= 1'b1;

        ##1;

        data_val <= 1'b0;

        for ( int i = 0; i <= testMod; i++ )
          begin
            // $display ("%d %d %d", testValue, testValue[15 - i], ser_data);
            if ( ser_data != testValue[15 - i] )
              begin
                $display( "Error: test: data_i=%d data_mod_i=%d number_pos=%d", testValue, testMod, i );
                $display( "\t Expected: ser_data_o=%d, ser_data_val=1, busy_o=1 ", testValue[15 - i] );
                $display( "\t Got: ser_data_o=%d, ser_data_val=%d, busy_o=%d ", ser_data, ser_data_val, busy );

                success = 1'b0;;
              end
            ##1;
          end

        if ( success )
          test_cnt++;
      end

    if ( test_cnt == 10 )
        $display( "All tests passed!" );
  end

endmodule