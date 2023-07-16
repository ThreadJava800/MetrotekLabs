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
    .clk_i      (clk),
    .srst_i     (srst),
    .data_i     (data),
    .data_mod_i (data_mod),
    .data_val_i (data_val),

    .ser_data_o     (ser_data),
    .ser_data_val_o (ser_data_val),
    .busy_o         (busy)
);

bit results [$];

task testBench( input data_test, input [3:0] data_mod_test, input data_val_test, input [15:0] check_arr );
    static bit [3:0] num_count = 'd15;
    static bit       success   = 1'b1;

    if ( data_mod_test != 0 )
        num_count = data_mod_test;
    else
        num_count = 15;

    wait ( busy );

    for ( int i = 0; i <= num_count; i++ )
        begin
            ##1;

            // $display( "%d %d", ser_data, check_arr[i] );
            if ( ( check_arr[i] != ser_data ) )
                begin
                    $display( "Test was not successful!" );
                    success = 1'b0;
                    // $stop();
                end
        end

    if ( success )
        begin
            if ( ( ser_data_val == 1'b1 ) && ( busy == 1'b0 ) )
                $display( "Test was successful!" );
            else
                $display( "Test was not successful!" );
        end
endtask

`define set_data(DATA, DATA_MOD, DATA_VAL) \
    srst     <= 1'b1;                       \
    data     <= DATA;                        \
    data_mod <= DATA_MOD;                     \
    data_val <= DATA_VAL;                      \
    #20 srst <= 1'b0;

initial
    begin
        `set_data( 'd15, 'd0, '1       )
        testBench( 'd15, 'd0, '1, 'd15 );

        `set_data( 'd14, 'd0, '1       )
        testBench( 'd14, 'd0, '1, 'd14 );

        `set_data( 'd13, 'd0, '1       )
        testBench( 'd13, 'd0, '1, 'd13 );

        `set_data( 'd12, 'd0, '1       )
        testBench( 'd12, 'd0, '1, 'd12 );

        `set_data( 'd11, 'd0, '1       )
        testBench( 'd11, 'd0, '1, 'd11 );

        `set_data( 'd10, 'd0, '1       )
        testBench( 'd10, 'd0, '1, 'd10 );

        `set_data( 'd9, 'd0, '1       )
        testBench( 'd9, 'd0, '1, 'd9 );

        `set_data( 'd8, 'd0, '1       )
        testBench( 'd8, 'd0, '1, 'd8 );

        `set_data( 'd7, 'd0, '1       )
        testBench( 'd7, 'd0, '1, 'd7 );

        `set_data( 'd6, 'd0, '1       )
        testBench( 'd6, 'd0, '1, 'd6 );

        `set_data( 'd5, 'd0, '1       )
        testBench( 'd5, 'd0, '1, 'd5 );

        `set_data( 'd4, 'd0, '1       )
        testBench( 'd4, 'd0, '1, 'd4 );

        `set_data( 'd3, 'd0, '1       )
        testBench( 'd3, 'd0, '1, 'd3 );

        `set_data( 'd2, 'd0, '1       )
        testBench( 'd2, 'd0, '1, 'd2 );

        `set_data( 'd1, 'd0, '1       )
        testBench( 'd1, 'd0, '1, 'd1 );

        `set_data( 'd0, 'd0, '1       )
        testBench( 'd0, 'd0, '1, 'd0 );
    end

endmodule