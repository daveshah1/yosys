/*
 *  yosys -- Yosys Open SYnthesis Suite
 *
 *  Copyright (C) 2012  Clifford Wolf <clifford@clifford.at>
 *                2019  Eddie Hung    <eddie@fpgeh.com>
 *                2019  David Shah    <dave@ds0.me>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

// ============================================================================

module \$__ABC_FF_ (input C, D, output Q);
endmodule

(* abc_box_id = 6, lib_whitebox, abc_flop = "TRELLIS_FF", abc_flop_q = "Q", abc_flop_d = "DI", abc_flop_past_q = "\\Q_past" *)
module \$__ABC_TRELLIS_FF (

	(* abc_flop_q *) output Q,
	input CLK, CE,
	(* abc_flop_d *) input DI,
	(* abc_flop_q_past, abc_discard *) input Q_past,
	input LSR);
	parameter GSR = "ENABLED";
	parameter [127:0] CEMUX = "1";
	parameter CLKMUX = "CLK";
	parameter LSRMUX = "LSR";
	parameter SRMODE = "LSR_OVER_CE";
	parameter REGSET = "RESET";
	parameter [127:0] LSRMODE = "LSR";

	reg muxce;
	generate
		case (CEMUX)
			"1": assign muxce = 1'b1;
			"0": assign muxce = 1'b0;
			"INV": assign muxce = ~CE;
			default: assign muxce = CE;
		endcase
	endgenerate
	wire muxlsr = (LSRMUX == "INV") ? ~LSR : LSR;
	wire srval = (REGSET == "SET") ? 1'b1 : 1'b0;

	assign Q = muxlsr ? srval : (muxce ? DI : Q_past); 

endmodule
