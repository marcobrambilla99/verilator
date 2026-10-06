// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Marco Brambilla
// SPDX-License-Identifier: CC0-1.0

// verilog_format: off
`define stop $stop
`define checkd(gotv,expv) do if ((gotv) !== (expv)) begin $write("%%Error: %s:%0d:  got=%0d exp=%0d\\n", `__FILE__,`__LINE__, (gotv), (expv)); `stop; end while(0);
// verilog_format: on

module t (
    input clk
);

  int cyc = 0;
  logic a = 0, b = 0;
  int fail_imm = 0, fail_late = 0;

  // A forbidden sequence fails when the sequence matches.
  // window 1: a in cycle 3, b in cycle 4  -> b[->1] target in the first cycle after a
  // window 2: a in cycle 10, b in cycle 12 -> b[->1] target one cycle later
  assert property (@(posedge clk) not (a ##1 b [-> 1]))
  else begin
    if (cyc < 8) fail_imm = fail_imm + 1;
    else fail_late = fail_late + 1;
  end

  always @(posedge clk) begin
    cyc <= cyc + 1;
    a <= (cyc == 2 || cyc == 9);
    b <= (cyc == 3 || cyc == 11);
    if (cyc == 20) begin
      `checkd(fail_imm, 1);
      `checkd(fail_late, 1);
      $write("*-* All Finished *-*\n");
      $finish;
    end
  end
endmodule
