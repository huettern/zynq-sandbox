module axisv_tpg #(
  // active pixels on display
  parameter H_PIXEL_COUNT = 800,
  parameter V_PIXEL_COUNT = 480,

  // LCD data width
  parameter DATA_WIDTH = 18
) (
  // ------------------------------
  // clock and reset
  input logic aclk_i,
  input logic rst_ni,

  // ------------------------------
  // AXIS interface
  output  logic [DATA_WIDTH-1:0]  m_axis_tdata,
  output  logic                   m_axis_tvalid,
  input   logic                   m_axis_tready,
  output  logic                   m_axis_tlast,
  output  logic [0:0]  m_axis_tuser,

  // ------------------------------
  // user input
  input logic trigger_i,
  output logic active_o
);
  
  localparam COL_CNT_WIDTH = $clog2(H_PIXEL_COUNT);
  localparam ROW_CNT_WIDTH = $clog2(V_PIXEL_COUNT);

  logic [COL_CNT_WIDTH:0] col_cnt_d, col_cnt_q;
  logic [ROW_CNT_WIDTH:0] row_cnt_d, row_cnt_q;
  logic running_d, running_q;

  // EOL on tlast
  assign m_axis_tlast = (col_cnt_q == (H_PIXEL_COUNT-1));
  // SOF on tuser[0]
  assign m_axis_tuser[0] = ( running_q && (row_cnt_q == 0) && (col_cnt_q == 0));
  // running on valid
  assign m_axis_tvalid = running_q;
  // copy of running on active pin
  assign active_o = running_q;

  // constant data value
  // assign m_axis_tdata = 18'b000000_000000_111111;
  logic [5:0] active_color;
  assign active_color = row_cnt_q[5:0];
  logic [2:0] color_select;
  assign color_select = col_cnt_q[8:6];

  assign m_axis_tdata[ 5: 0] = color_select[0] ? active_color : 6'b0;
  assign m_axis_tdata[11: 6] = color_select[1] ? active_color : 6'b0;
  assign m_axis_tdata[17:12] = color_select[2] ? active_color : 6'b0;

  // axis stream valid
  logic stream_on;
  assign stream_on = m_axis_tvalid && m_axis_tready;

  always_comb begin
    running_d = running_q;
    col_cnt_d = col_cnt_q;
    row_cnt_d = row_cnt_q;

    // start
    if ((~running_q) && trigger_i) begin
      running_d = 1;
      col_cnt_d = 0;
      row_cnt_d = 0;
    end

    // increment logic
    if (running_q && stream_on) begin
      col_cnt_d = col_cnt_q + 1;

      // at last pixel of line
      if (col_cnt_q == (H_PIXEL_COUNT-1) ) begin
        row_cnt_d = row_cnt_q + 1;
        col_cnt_d = 0;

        // at last pixel of frame
        if (row_cnt_q == (V_PIXEL_COUNT-1) ) begin
          row_cnt_d = 0;
          running_d = 0;
        end
      end

    end
  end

  always_ff @(posedge aclk_i) begin
    if(~rst_ni) begin
      col_cnt_q <= 0;
      row_cnt_q <= 0;
      running_q <= 0;
    end else begin
      col_cnt_q <= col_cnt_d;
      row_cnt_q <= row_cnt_d;
      running_q <= running_d;
    end
  end

endmodule