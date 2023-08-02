module deserializer_tb;

parameter TEST_NUM = 1000;

bit           clk;

logic srst;
logic data;
logic data_val;

initial
  forever
    #5 clk = !clk;

default clocking cb 
  @( posedge clk );
endclocking

logic [15:0] deser_data;
logic deser_data_val;

deserializer DUT (
  .clk_i          (clk),
  .srst_i         (srst),
  .data_i         (data),
  .data_val_i     (data_val),

  .deser_data_o     (deser_data),
  .deser_data_val_o (deser_data_val)
);

typedef struct {
  logic test_data;
  logic test_data_val;
} test_pkg;

task create_package( mailbox #( test_pkg ) pkg );
  for ( int i = 0; i < TEST_NUM; i++ )
    begin
      test_pkg new_pkg;
      new_pkg.test_data     = $urandom_range( 1, 0 );
      new_pkg.test_data_val = $urandom_range( 1, 0 );

      pkg.put( new_pkg );
    end
endtask

int        bit_cnt = 0;
bit [15:0] etalon_logic;

task send_package( mailbox #( test_pkg ) pkgs,
                   mailbox #( logic [15:0] ) etalon );
  while ( pkgs.num() > 0 ) 
    begin
      test_pkg pkg;
      pkgs.get( pkg );

      data     = pkg.test_data;
      data_val = pkg.test_data_val;

      if ( data_val )
        begin
          etalon_logic[15 - bit_cnt] = data;
          bit_cnt++;
        end

      if ( bit_cnt == 16 )
        begin
          etalon.put( etalon_logic );
          bit_cnt = 0;
          ##1;
        end

      ##1;
    end

    data_val = 1'b0;
endtask

int collect_cnt = 0;
task collect_data ( mailbox #( logic [15:0] ) recieved );
  while ( collect_cnt < TEST_NUM * 16 )
    begin
      if ( deser_data_val )
        begin
          recieved.put( deser_data );
        end
      collect_cnt++;
      ##1;
    end
endtask

int test_cnt = 0;
task test ( mailbox #( logic [15:0] ) recieved,
            mailbox #( logic [15:0] ) etalon );

  while ( test_cnt < TEST_NUM * 16 )
    begin
      if ( recieved.num() > 0 )
        begin
          logic [15:0] check_value;
          logic [15:0] original;
    
          recieved.get( check_value );
          etalon.get( original );
    
          if (check_value != original)
            $display( "Error occured: orig = %d, got = %d", original, check_value );
        end

      ##1;
      test_cnt++;
    end

    $display( "Tests finished" );
endtask

mailbox #( test_pkg )     sended_pkgs = new();
mailbox #( logic [15:0] ) result_pkgs = new();
mailbox #( logic [15:0] ) orig_pkgs   = new();

initial
  begin

    srst = 1'b1;
    ##1 srst = 1'b0;

    fork
      create_package( sended_pkgs );
      send_package( sended_pkgs, orig_pkgs );

      collect_data( result_pkgs );
      test( result_pkgs, orig_pkgs );
    join

  end

endmodule