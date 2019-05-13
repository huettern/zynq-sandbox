//-----------------------------------------------------
// Design Name : blinker_top
// File Name   : blinker_top.v
// Function    : Simple LED blinked
// Coder       : Deepak
//-----------------------------------------------------

module blinker_top
  # (
    parameter integer OUT_WIDTH = 8
  )
  (
    // Specify clocks
    input wire aclk,
    input wire arstn,

    // Specify outputs
    output wire [OUT_WIDTH-1:0] led
  );

  initial begin
    $dumpfile("blinker_top.vcd"); 
    $dumpvars(0, blinker_top);
  end

  // Registers
  reg [32:0] counter;

  // Assign values
  assign led[0] = 1'b1;

  assign led[7:1] = counter[31:25];

  // Counter
  always @ (posedge aclk) begin
    if (!arstn) begin
      counter <= 32'h0;
    end else begin
      counter <= counter + 1;
    end
  end

endmodule

