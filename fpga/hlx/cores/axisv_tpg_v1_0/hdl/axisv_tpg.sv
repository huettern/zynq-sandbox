module axisv_tpg #(
  // active pixels on display
  parameter H_PIXEL_COUNT = 8,
  parameter V_PIXEL_COUNT = 4,

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
  input logic trigger_i
);
  
  localparam COL_CNT_WIDTH = $clog2(H_PIXEL_COUNT);
  localparam ROW_CNT_WIDTH = $clog2(V_PIXEL_COUNT);

  logic [COL_CNT_WIDTH:0] col_cnt_d, col_cnt_q;
  logic [ROW_CNT_WIDTH:0] row_cnt_d, row_cnt_q;
  logic running_d, running_q;

  // EOL on tlast
  assign m_axis_tlast = (col_cnt_q == (H_PIXEL_COUNT-1));
  // EOF on tuser[0]
  assign m_axis_tuser[0] = ( (row_cnt_q == (V_PIXEL_COUNT-1)) && (col_cnt_q == (H_PIXEL_COUNT-1)) );
  // running on valid
  assign m_axis_tvalid = running_q;

  // constant data value
  // assign m_axis_tdata = 18'b000000_000000_111111;
  assign m_axis_tdata[ROW_CNT_WIDTH:0] = row_cnt_q;
  assign m_axis_tdata[DATA_WIDTH-1:ROW_CNT_WIDTH+1] = 0;

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