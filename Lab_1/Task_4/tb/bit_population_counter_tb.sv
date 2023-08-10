module bit_population_counter_tb;

parameter int TEST_NUM   = 1000;
parameter int TEST_WIDTH = 32;

bit clk;

logic                       srst;
logic [ TEST_WIDTH - 1 :0 ] data;
logic                       data_val;

initial
  forever
    #5 clk = !clk;

default clocking cb 
  @( posedge clk );
endclocking

logic [ $clog2(TEST_WIDTH) :0] data_out;
logic                      data_val_out;

bit_population_counter #( .WIDTH( TEST_WIDTH ) ) DUT (
  .clk_i        (clk),
  .srst_i       (srst),
  .data_i       (data),
  .data_val_i   (data_val),

  .data_o       (data_out),
  .data_val_o   (data_val_out)
);

typedef struct {
  logic  [ TEST_WIDTH - 1 :0 ] test_data;
  logic                        test_data_val;
} test_pkg;

int clk_delay;
bit clk_val;
int clk_cnt;
task create_package( mailbox #( test_pkg ) pkg );
  clk_delay = 0;
  clk_cnt   = 0;
  clk_val   = 0;

  for ( int i = 0; i < TEST_NUM; i++ )
    begin
      test_pkg new_pkg;
      new_pkg.test_data     = $urandom_range( 2**TEST_WIDTH - 1, 0 );

      if ( clk_cnt >= clk_delay )
        begin
          clk_delay = $urandom_range( 200, 1 );
          clk_cnt   = 0;
          clk_val   = $urandom_range( 1, 0 );
        end
      else
        new_pkg.test_data_val = clk_val;

      clk_cnt++;
      pkg.put( new_pkg );
    end
endtask

int                          bit_cnt   = 0;
bit [ $clog2(TEST_WIDTH) :0] etalon_cnt;

task send_package( mailbox #( test_pkg ) pkgs,
                   mailbox #( logic [$clog2(TEST_WIDTH):0] ) etalon );
  while ( pkgs.num() > 0 ) 
    begin
      test_pkg pkg;
      pkgs.get( pkg );

      data     = pkg.test_data;
      data_val = pkg.test_data_val;

      if ( data_val )
        begin
          etalon_cnt = $countones(data);
          etalon.put( etalon_cnt );
        end

      ##1;
    end

    data_val = 1'b0;
endtask

int collect_cnt = 0;
task collect_data ( mailbox #( logic [$clog2(TEST_WIDTH):0] ) recieved );
  ##1;
  while ( collect_cnt < TEST_NUM )
    begin
      if ( data_val_out )
        begin
          recieved.put( data_out );
        end
      collect_cnt++;
      ##1;
    end
endtask

int test_cnt = 0;
task test ( mailbox #( logic [$clog2(TEST_WIDTH):0] ) recieved,
            mailbox #( logic [$clog2(TEST_WIDTH):0] ) etalon );

  while ( test_cnt < TEST_NUM )
    begin
      if ( recieved.num() > 0 )
        begin
          logic [$clog2(TEST_WIDTH):0] check_value;
          logic [$clog2(TEST_WIDTH):0] original;
    
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
mailbox #( logic [$clog2(TEST_WIDTH):0] ) result_pkgs = new();
mailbox #( logic [$clog2(TEST_WIDTH):0] ) orig_pkgs   = new();

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