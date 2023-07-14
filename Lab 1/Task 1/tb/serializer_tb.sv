module serializer_tb;

bit         clk;
bit         srst;
bit [15:0]  data;
bit [3:0 ]  data_mod;
bit         data_val;

initial
    forever
        #5 clk = !clk;

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

initial
    begin
        srst <= 1'b1;
        data <= 'd12;
        data_mod <= 'd15;
        data_val <= '1;
        #20
        srst <= 1'b0;
    end

endmodule