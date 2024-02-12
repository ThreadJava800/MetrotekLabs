module debouncer #(
    parameter int CLK_FREQ_MHZ   = 5,
    parameter int GLITCH_TIME_NS = 1
) (
  input  logic clk_i,
  input  logic key_i,
  output logic key_pressed_stb_o
);

endmodule