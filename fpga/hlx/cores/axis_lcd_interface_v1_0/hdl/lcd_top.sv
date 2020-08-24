module lcd_top #(

  // active pixels on display
  parameter H_PIXEL_COUNT = 8,
  parameter V_PIXEL_COUNT = 4,

  // horizontal back and front porch, multiple of clk_i
  // thp: hsync pulse width
  // thb: horizontal invalid period BEFORE active area
  // thf: horizontal invalid period AFTER active area
  parameter THP_COUNT = 2,
  parameter THB_COUNT = 3,
  parameter THF_COUNT = 4,

  // vertical back and front porch, multiple of hsync_o
  // thp: hsync pulse width
  // thb: horizontal invalid period BEFORE active area
  // thf: horizontal invalid period AFTER active area
  parameter TVP_COUNT = 5,
  parameter TVB_COUNT = 6,
  parameter TVF_COUNT = 7,

  parameter FIFO_DEPTH = 128,
  // LCD data width
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
  output logic enable_o,
  output logic [DATA_WIDTH-1:0] lcd_dat_o
);

  // ----------------------------------------------------------------------
  // Defines

  // ----------------------------------------------------------------------
  // Signals and wires
  logic tg_start, tg_busy, tg_active_video;
  logic tg_hsync, tg_vsync, tg_enable, tg_hline_last;

  // create a delayed versions of tg signals to compensate for FiFo latency
  logic tg_hsync_d, tg_vsync_d, tg_enable_d;
  always_ff @(posedge aclk_i) begin
    tg_hsync_d <= tg_hsync;
    tg_vsync_d <= tg_vsync;
    tg_enable_d <= tg_enable;
  end

  // map timing generator start to user0 of axi stream = start of frame
  assign tg_start = s_axis_tuser[0];

  // connect output
  assign enable_o = tg_enable_d;

  // ----------------------------------------------------------------------
  // FiFo Instance
  lcd_fifo #(
    .DEPTH(FIFO_DEPTH),
    .DATA_WIDTH(DATA_WIDTH),
    .USER_ENABLE(USER_ENABLE),
    .USER_WIDTH(USER_WIDTH)
  ) i_fifo (
    .aclk_i(aclk_i),
    .rst_ni(rst_ni),
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    .s_axis_tlast(s_axis_tlast),
    .s_axis_tuser(s_axis_tuser),
    .active_video_i(tg_active_video),
    .lcd_dat_o(lcd_dat_o)
  );

  // ----------------------------------------------------------------------
  // Timing Generator instance
  lcd_timing_generator #(
    .H_PIXEL_COUNT(H_PIXEL_COUNT),
    .V_PIXEL_COUNT(V_PIXEL_COUNT),
    .THP_COUNT(THP_COUNT),
    .THB_COUNT(THB_COUNT),
    .THF_COUNT(THF_COUNT),
    .TVP_COUNT(TVP_COUNT),
    .TVB_COUNT(TVB_COUNT),
    .TVF_COUNT(TVF_COUNT)
  ) i_timing (
    .clk_i(aclk_i),
    .rst_ni(rst_ni),

    .start_i(tg_start),
    .busy_o(tg_busy),

    .active_video_o(tg_active_video),
    .hsync_o(tg_hsync),
    .vsync_o(tg_vsync),
    .enable_o(tg_enable),
    .hline_last_o(tg_hline_last)
  );
  
endmodule