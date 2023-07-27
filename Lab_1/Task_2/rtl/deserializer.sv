module deserializer #(
    parameter DATA_W = 5'd16
) (
  input  logic        clk_i,
  input  logic        srst_i,
  input  logic        data_i,
  input  logic        data_val_i,

  output logic [( DATA_W - 1'b1 ):0] deser_data_o,
  output logic                       deser_data_val_o
);

bit [$clog2(DATA_W):0] bit_cnt;
bit                    data_cpy;

enum logic [1:0] {
  DEFAULT,
  IN_PROC,
  FINISH
} state, next_state;

// state switcher
always_ff @( posedge clk_i )
  begin
    if ( srst_i )
      state <= DEFAULT;
    else
      state <= next_state;
  end

// next_state controller
always_comb
  begin
    case ( state )
      DEFAULT:
        begin
          if ( data_val_i )
            begin
              next_state = IN_PROC;
            end
        end
      IN_PROC:
        begin
          if ( bit_cnt == 5'd16 )
            next_state = FINISH;
          else
            next_state = state;
        end
      FINISH:
        begin
          next_state = DEFAULT;
        end
      endcase
  end

assign data_cpy = data_i;

// bit_cnt block
always_ff @( posedge clk_i )
  begin
    case ( state )
      DEFAULT, FINISH:
        begin
          bit_cnt <= 16'd0;
        end
      IN_PROC:
        begin
          bit_cnt <= bit_cnt + 1'b1;
        end
    endcase
  end

// deser_data_o block
always_ff @( posedge clk_i )
  begin
    case ( state )
      DEFAULT:
        begin
          deser_data_o <= 16'd0;
        end
      IN_PROC:
        begin
          if ( data_val_i )
            begin
            //   deser_data_o <= deser_data_o << 1;
              deser_data_o <= {deser_data_o[14:0], data_cpy};
            end
        end
    endcase
  end

// deser_data_val_o block
always_ff @( posedge clk_i )
  begin
    case ( state )
      DEFAULT, IN_PROC:
        begin
          deser_data_val_o <= 1'b0;
        end
      FINISH:
        begin
          deser_data_val_o <= 1'b1;
        end
    endcase
  end

endmodule