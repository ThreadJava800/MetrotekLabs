module tb;
parameter             A = 1;
parameter [4:0]       B = -1;
parameter logic [4:0] C = 1;
parameter             D = 2**63;
parameter             E = "SystemVerilog";
parameter int         F = 3;
parameter integer     J = 3;

logic [3:0] a = 5;
int b = 3;

initial
  begin
    $display( $typename(A), A );
    $display( $typename(B), B );
    $display( $typename(C), C );
    $display( $typename(D), D );
    $display( $typename(E), E );
    $display( $typename(F), F );
    $display( $typename(J), J );
    $display( $typename(a), a );
    $display( $typename(b), b );
    $display( $typename(5)    );
    $stop();
  end
endmodule