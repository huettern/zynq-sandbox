module lcd_fifo #(
    parameter DEPTH = 128,
    parameter DATA_WIDTH = 18,

    // user signal
    parameter USER_ENABLE = 1,
    parameter USER_WIDTH = 1

  ) (
  // ------------------------------
  // clock and reset
  input logic aclk_i,
  input logic rst_ni,

  // ------------------------------
  // AXIS interface
  input  logic [DATA_WIDTH-1:0]  s_axis_tdata,
  input  logic                   s_axis_tvalid,
  output logic                   s_axis_tready,
  input  logic                   s_axis_tlast,
  input  logic [USER_WIDTH-1:0]  s_axis_tuser,

  // ------------------------------
  // lcd interface
  input logic active_video_i,
  output logic [DATA_WIDTH-1:0] lcd_dat_o
);

  // ----------------------------------------------------------------------
  // Defines
  localparam ADDR_WIDTH = $clog2(DEPTH);

  // ----------------------------------------------------------------------
  // Signals and wires
  reg [(DATA_WIDTH-1):0]  mem [0:((2**ADDR_WIDTH)-1)];

  logic [(DATA_WIDTH-1):0] o_item, i_item;
  logic [(ADDR_WIDTH-1):0] wraddr, rdaddr, fill;

  logic full, empty, overrun, underrun, write_en, read_en;

  assign read_en = active_video_i;

  // be ready if not full
  assign s_axis_tready = !full;
  assign write_en = s_axis_tvalid && !full;

  // map in out
  assign i_item = s_axis_tdata;
  assign lcd_dat_o = o_item;

  // ----------------------------------------------------------------------
  // read write access
  always_ff @(posedge aclk_i) begin
    if (write_en) begin
      mem[wraddr] <= i_item;
    end
  end

  always_ff @(posedge aclk_i) begin
    if (read_en) begin
      o_item <= mem[rdaddr];
    end
  end
  
  // write address logic
  always_ff @(posedge aclk_i) begin
    if (!rst_ni) begin
      wraddr <= 0;
      overrun  <= 0;
    end else if (write_en) begin
      if ( (!full) || (read_en) ) begin
        wraddr <= (wraddr + 1'b1);
      end else begin
        overrun <= 1'b1;
      end
    end
  end

  // read address logic 
  always_ff @(posedge aclk_i) begin
    if (!rst_ni) begin
      rdaddr <= 0;
      underrun <= 0;
    end else if (read_en) begin
      if (!empty) begin
        rdaddr <= rdaddr + 1'b1;
      end else begin
        underrun <= 1'b1;
      end
    end
  end

  // Calculate the fill
  always @(posedge aclk_i) begin
    if (!rst_ni) begin
      fill <= 0;
    end else casez({ write_en, read_en, full, empty })
      4'b01?0: fill <= fill - 1'b1; // A successful read
      4'b100?: fill <= fill + 1'b1; // A successful write
      4'b1101: fill <= fill + 1'b1; // Successful write, failed read
      4'b11?0: fill <= fill;        // Successful read *and* write -- no change
      default: fill <= fill;  // Default, no change
    endcase
  end

  // calculate full/empty
  logic  [(ADDR_WIDTH-1):0] dblnext, nxtread;
  assign  dblnext = wraddr + 2;
  assign  nxtread = rdaddr + 1'b1;

  always @(posedge aclk_i) begin
    if (!rst_ni) begin
      full <= 1'b0;
      empty <= 1'b1;
    end else casez({ write_en, read_en, !full, !empty })
      4'b01?1: begin  // A successful read
        full  <= 1'b0;
        empty <= (nxtread == wraddr);
      end
      4'b101?: begin  // A successful write
        full <= (dblnext == rdaddr);
        empty <= 1'b0;
      end
      4'b11?0: begin  // Successful write, failed read
        full  <= 1'b0;
        empty <= 1'b0;
      end
      4'b11?1: begin  // Successful read and write
        full  <= full;
        empty <= 1'b0;
      end
      default: begin end
    endcase
  end

endmodule