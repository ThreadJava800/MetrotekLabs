module priority_encoder_tb;

parameter int TEST_NUM   = 10000;
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

logic [ TEST_WIDTH - 1 :0] data_left;
logic [ TEST_WIDTH - 1 :0] data_right;
logic                      data_val_out;

priority_encoder #( .WIDTH( TEST_WIDTH ) ) DUT (
  .clk_i        (clk),
  .srst_i       (srst),
  .data_i       (data),
  .data_val_i   (data_val),

  .data_left_o  (data_left),
  .data_right_o (data_right),
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
      new_pkg.test_data     = $urandom_range( 2**TEST_WIDTH - 1, 1 );

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

int                      bit_cnt   = 0;
bit [ TEST_WIDTH+1 :0] etalon_left;
bit [ TEST_WIDTH+1 :0] etalon_right;

task send_package( mailbox #( test_pkg ) pkgs,
                   mailbox #( logic [TEST_WIDTH - 1:0] ) etalon );
  while ( pkgs.num() > 0 ) 
    begin
      test_pkg pkg;
      pkgs.get( pkg );

      data     = pkg.test_data;
      data_val = pkg.test_data_val;
      
      if ( data_val )
        begin
          etalon_left  = 2 ** TEST_WIDTH;  // poison value that can't be equal to pos num
          etalon_right = 2 ** TEST_WIDTH;

          for ( int i = 0; i < TEST_WIDTH; i++ )
            begin
              if ( ( etalon_right == 2 ** TEST_WIDTH ) && ( data[i] == 1 ) )
                etalon_right = i;

              if ( data[i] == 1 )
                etalon_left = i;
            end
      
          etalon.put( etalon_left );
          etalon.put( etalon_right );
        end

      ##1;
    end

    data_val = 1'b0;
endtask

int collect_cnt = 0;
task collect_data ( mailbox #( logic [TEST_WIDTH - 1:0] ) recieved );
  ##1;
  while ( collect_cnt < TEST_NUM )
    begin
      if ( data_val_out )
        begin
          recieved.put( data_left );
          recieved.put( data_right );
        end
      collect_cnt++;
      ##1;
    end
endtask

int test_cnt = 0;
task test ( mailbox #( logic [TEST_WIDTH - 1:0] ) recieved,
            mailbox #( logic [TEST_WIDTH - 1:0] ) etalon );

  while ( test_cnt < TEST_NUM * 2 )
    begin
      if ( recieved.num() > 0 )
        begin
          logic [TEST_WIDTH - 1:0] check_value;
          logic [TEST_WIDTH - 1:0] original;
    
          recieved.get( check_value );
          etalon.get( original );
    
          for ( int i = 0; i < TEST_WIDTH; i++ )
            begin
              if ( check_value[i] == 1 )
                begin
                  if ( original != i )
                    $display( "Error! met one on a wrong position: val = %d, pos = %d, await = %d", check_value, i, original );
                end
            end
        end

      ##1;
      test_cnt++;
    end

    $display( "Tests finished" );
endtask

mailbox #( test_pkg )     sended_pkgs = new();
mailbox #( logic [TEST_WIDTH - 1:0] ) result_pkgs = new();
mailbox #( logic [TEST_WIDTH - 1:0] ) orig_pkgs   = new();

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