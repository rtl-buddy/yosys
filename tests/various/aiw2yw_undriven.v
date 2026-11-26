module top(input clk, input we, input [1:0] wa, ra, input [3:0] wd);
  reg [3:0] mem [0:2];
  reg [3:0] rd;
  always @(posedge clk) begin
    if (we) mem[wa] <= wd;
    rd <= mem[ra];
  end
  always @(posedge clk) assert(rd != 4'hf);
endmodule
