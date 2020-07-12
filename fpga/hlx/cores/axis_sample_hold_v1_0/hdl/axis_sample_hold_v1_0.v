
`timescale 1 ns / 1 ps

module axis_sample_hold_v1_0 #
(
  parameter integer AXIS_TDATA_WIDTH = 32
)
(
  // data and clock
  input  wire                        aclk,
  input  wire                        arstn,

  // Slave side
  output wire                        s_axis_tready,
  input  wire [AXIS_TDATA_WIDTH-1:0] s_axis_tdata,
  input  wire                        s_axis_tvalid,

  // master side
  input wire                          m_axis_tready,
  output  wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output  wire                        m_axis_tvalid
);

  reg [AXIS_TDATA_WIDTH-1:0] int_dat_reg;

  always @(posedge aclk) begin
    // default, hold old value
    int_dat_reg <= int_dat_reg;

    if (~arstn) begin
      // on reset, set to zero
      int_dat_reg <= {(AXIS_TDATA_WIDTH){1'b0}};
    end else begin

      if (s_axis_tvalid) begin
        // no reset and input valid, sample new value
        int_dat_reg <= s_axis_tdata;
      end

    end

  end

  // we are always ready and the output is always valid
  assign s_axis_tready = 1'b1;
  assign m_axis_tvalid = 1'b1;

  // data output
  assign m_axis_tdata = int_dat_reg;

endmodule
