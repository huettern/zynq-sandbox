module lcd_timing_generator #(
    // active pixels on display
    parameter H_PIXEL_COUNT = 800,
    parameter V_PIXEL_COUNT = 480,

    // horizontal back and front porch, multiple of clk_i
    // thp: hsync pulse width
    // thb: horizontal invalid period BEFORE active area
    // thf: horizontal invalid period AFTER active area
    parameter THP_COUNT = 128,
    parameter THB_COUNT = 88,
    parameter THF_COUNT = 40,

    // vertical back and front porch, multiple of hsync_o
    // thp: hsync pulse width
    // thb: horizontal invalid period BEFORE active area
    // thf: horizontal invalid period AFTER active area
    parameter TVP_COUNT = 2112,
    parameter TVB_COUNT = 33792,
    parameter TVF_COUNT = 11616
  ) (
  // ------------------------------
  // clock and reset
  input logic clk_i,
  input logic rst_ni,

  // ------------------------------
  // control interface
  input logic start_i,
  output logic busy_o,

  // ------------------------------
  // timing outputs
  output logic active_video_o,
  output logic hsync_o,
  output logic vsync_o,
  output logic enable_o,
  output logic hline_last_o
);

  // ----------------------------------------------------------------------
  // Defines
  localparam HCNT_BITS = $clog2(THP_COUNT+THB_COUNT+THF_COUNT+H_PIXEL_COUNT);
  localparam VCNT_BITS = $clog2(TVP_COUNT+TVB_COUNT+TVF_COUNT+V_PIXEL_COUNT);

  // ----------------------------------------------------------------------
  // Signals and wires

  // horizontal and vertical states
  logic running_d, running_q, vertical_running, lines_done;

  logic [HCNT_BITS-1:0] hcnt_d, hcnt_q;
  logic [VCNT_BITS-1:0] vcnt_d, vcnt_q;

  logic hline_last, vline_last;
  assign hline_last = (hcnt_q == (THP_COUNT+THB_COUNT+THF_COUNT+H_PIXEL_COUNT-1));
  assign vline_last = (vcnt_q == (TVP_COUNT+TVB_COUNT+TVF_COUNT+V_PIXEL_COUNT-1));
  assign lines_done  = (vcnt_q >= (TVP_COUNT+TVB_COUNT+V_PIXEL_COUNT));
  assign vertical_running = (vcnt_q >= (TVP_COUNT+TVB_COUNT)) && (vcnt_q < (TVP_COUNT+TVB_COUNT+V_PIXEL_COUNT));

  wire active_video;

  // ----------------------------------------------------------------------
  // Vertical state machine
  always_ff @(posedge clk_i) begin
    if(~rst_ni) begin
      vcnt_q <= 0;
      running_q <= 0;
    end else begin
      vcnt_q <= vcnt_d;
      running_q <= running_d;
    end
  end

  always_comb begin
    running_d = running_q;
    vcnt_d = vcnt_q;

    if (~running_q) begin
      vcnt_d = 0;
      if (start_i) begin
        running_d = 1;
      end
    end else begin
      // increment vertical counter if horizontal counter is done
      if (hline_last || ~vertical_running || lines_done) begin
        vcnt_d = vcnt_q + 1;
      end

      // stop if vertical counter has completed
      if (vline_last) begin
        running_d = 0;
      end
    end
  end

  // ----------------------------------------------------------------------
  // Horizontal state machine
  always_ff @(posedge clk_i) begin
    if(~rst_ni) begin
      hcnt_q <= 0;
    end else begin
      hcnt_q <= hcnt_d;
    end
  end

  always_comb begin
    hcnt_d = hcnt_q;

    if (~running_q) begin
      hcnt_d = 0;
    end else begin
      // increment horizontal counter and wrap if last element reached
      if (hline_last) begin
        hcnt_d = 0;
      end else if (~lines_done) begin
        if (vertical_running) begin
          hcnt_d = hcnt_q + 1;
        end
      end
    end
  end

  // ----------------------------------------------------------------------
  // output
  assign busy_o = running_q;

  assign vsync_o = (running_q && (vcnt_q < TVP_COUNT)) ? 0 : 1;
  assign hsync_o = (vertical_running && (hcnt_q < THP_COUNT)) ? 0 : 1;

  assign active_video = ( (hcnt_q >= (THP_COUNT+THB_COUNT)) && (hcnt_q < (THP_COUNT+THB_COUNT+H_PIXEL_COUNT) )) ? 1 : 0;
  assign active_video_o = active_video;

  assign enable_o = active_video;
  assign hline_last_o = hline_last;

endmodule