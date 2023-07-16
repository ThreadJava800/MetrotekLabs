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

task testBench( input data_test, input [3:0] data_mod_test, input data_val_test, input [15:0] check_arr );
    static bit [3:0] num_count = 'd15;
    static bit       success   = 1'b1;

    if ( data_mod_test != 0 )
        num_count = data_mod_test;

    for ( int i = 0; i < data_mod_test; i++ )
        begin
            if ( ( check_arr[15 - i] != ser_data ) || ( ser_data_val == 1'b1 ) || ( busy == 1'b0 ) )
                begin
                    $display( "Test was not successful!" );
                    success = 1'b0;
                    break;
                end
            ##1;
        end

    if ( success )
        begin
            if ( ( ser_data_val == 1'b1 ) && ( busy == 1'b0 ) )
                $display( "Test was successful!" );
            else
                $display( "Test was not successful!" );
        end
endtask

initial
    begin
        srst     <= 1'b1;
        data     <= 'd15;
        data_mod <= 'd0;
        data_val <= '1;
        #20 srst <= 1'b0;
        testBench( 'd15, 'd0, '1, 'd1 );
    end

endmodule