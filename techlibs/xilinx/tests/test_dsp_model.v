`timescale 1ns / 1ps

module testbench;
    parameter integer ACASCREG = 1;
    parameter integer ADREG = 1;
    parameter integer ALUMODEREG = 1;
    parameter integer AREG = 1;
    parameter AUTORESET_PATDET = "NO_RESET";
    parameter A_INPUT = "DIRECT";
    parameter integer BCASCREG = 1;
    parameter integer BREG = 1;
    parameter B_INPUT = "DIRECT";
    parameter integer CARRYINREG = 1;
    parameter integer CARRYINSELREG = 1;
    parameter integer CREG = 1;
    parameter integer DREG = 1;
    parameter integer INMODEREG = 1;
    parameter integer MREG = 1;
    parameter integer OPMODEREG = 1;
    parameter integer PREG = 1;
    parameter SEL_MASK = "MASK";
    parameter SEL_PATTERN = "PATTERN";
    parameter USE_DPORT = "FALSE";
    parameter USE_MULT = "MULTIPLY";
    parameter USE_PATTERN_DETECT = "NO_PATDET";
    parameter USE_SIMD = "ONE48";
    parameter [47:0] MASK = 48'h3FFFFFFFFFFF;
    parameter [47:0] PATTERN = 48'h000000000000;
    parameter [3:0] IS_ALUMODE_INVERTED = 4'b0;
    parameter [0:0] IS_CARRYIN_INVERTED = 1'b0;
    parameter [0:0] IS_CLK_INVERTED = 1'b0;
    parameter [4:0] IS_INMODE_INVERTED = 5'b0;
    parameter [6:0] IS_OPMODE_INVERTED = 7'b0;

	reg CLK;
	reg CEA1, CEA2, CEAD, CEALUMODE, CEB1, CEB2, CEC, CECARRYIN, CECTRL;
	reg CED, CEINMODE, CEM, CEP;
	reg RSTA, RSTALLCARRYIN, RSTALUMODE, RSTB, RSTC, RSTD, RSTINMODE, RSTM, RSTP;
	reg [29:0] A, ACIN;
	reg [17:0] B, BCIN;
	reg [47:0] C;
	reg [24:0] D;
	reg [47:0] PCIN;
	reg [3:0] ALUMODE;
	reg [2:0] CARRYINSEL;
	reg [4:0] INMODE;
	reg [6:0] OPMODE;
	reg CARRYCASCIN, CARRYIN, MULTSIGNIN;

    output [29:0] ACOUT, REF_ACOUT;
    output [17:0] BCOUT, REF_BCOUT;
    output CARRYCASCOUT, REF_CARRYCASCOUT;
    output [3:0] CARRYOUT, REF_CARRYOUT;
    output MULTSIGNOUT, REF_MULTSIGNOUT;
    output OVERFLOW, REF_OVERFLOW;
    output [47:0] P, REF_P;
    output PATTERNBDETECT, REF_PATTERNBDETECT;
    output PATTERNDETECT, REF_PATTERNDETECT;
    output [47:0] PCOUT, REF_PCOUT;
    output UNDERFLOW, REF_UNDERFLOW;

	integer errcount = 0;

	task clkcycle;
		begin
			#5;
			CLK = ~CLK;
			#10;
			CLK = ~CLK;
			#2;

			if (REF_P !== P) begin
				$display("ERROR at %1t: REF_P=%b UUT_P=%b DIFF=%b", $time, REF_P, P, REF_P ^ P);
				errcount = errcount + 1;
			end
			if (REF_CARRYOUT !== CARRYOUT) begin
				$display("ERROR at %1t: REF_CARRYOUT=%b UUT_CARRYOUT=%b", $time, REF_CARRYOUT, CARRYOUT);
				errcount = errcount + 1;
			end
			#3;
		end
	endtask

	reg config_valid = 0;
	task drc;
		config_valid = 1;
		if (AREG != 2 && INMODE[0]) config_valid = 0;
		if (BREG != 2 && INMODE[4]) config_valid = 0;
		if ((OPMODE[3:2] == 2'b01) ^ (OPMODE[1:0] == 2'b01) == 1'b1) config_valid = 0;
		if ((OPMODE[6:4] == 3'b010) && PREG != 1) config_valid = 0;
		if ((OPMODE[6:4] == 3'b010) && (PREG != 1 || OPMODE[3:0] != 4'b1000)) config_valid = 0;
	endtask

	initial begin
		$dumpfile("test_dsp_model.vcd");
		$dumpvars(0, testbench);

		#2;
		CLK = 1'b0;
		{CEA1, CEA2, CEAD, CEALUMODE, CEB1, CEB2, CEC, CECARRYIN, CECTRL} = 9'b111111111;
		{CED, CEINMODE, CEM, CEP} = 4'b1111;

		{A, B, C, D} = 0;
		{ACIN, BCIN, PCIN} = 0;
		{ALUMODE, CARRYINSEL, INMODE} = 0;
		{OPMODE, CARRYCASCIN, CARRYIN, MULTSIGNIN} = 0;

		{RSTA, RSTALLCARRYIN, RSTALUMODE, RSTB, RSTC, RSTD, RSTINMODE, RSTM, RSTP} = ~0;
		#5;
		CLK = 1'b1;
		#10;
		CLK = 1'b0
		#5;
		CLK = 1'b1;
		#10;
		CLK = 1'b0;
		{RSTA, RSTALLCARRYIN, RSTALUMODE, RSTB, RSTC, RSTD, RSTINMODE, RSTM, RSTP} = 0;

		repeat (300) begin
			clkcycle;
			do begin
				A = $urandom;
				ACIN = $urandom;
				B = $urandom;
				BCIN = $urandom;
				C = {$urandom, $urandom};
				D = $urandom;
				PCIN = {$urandom, $urandom};

				{RSTA, RSTALLCARRYIN, RSTALUMODE, RSTB, RSTC, RSTD, RSTINMODE, RSTM, RSTP} = $urandom & $urandom & $urandom;
				{ALUMODE, CARRYINSEL, INMODE} = $urandom & $urandom & $urandom;
				OPMODE = $urandom;
				{CARRYCASCIN, CARRYIN, MULTSIGNIN} = $urandom;
				drc;
			end while (!config_valid);
		end

		if (errcount == 0) begin
			$display("All tests passed.");
			$finish;
		end else begin
			$display("Caught %1d errors.", errcount);
			$stop;
		end
	end

	DSP48E1 #(
		.ACASCREG           (ACASCREG),
		.ADREG              (ADREG),
		.ALUMODEREG         (ALUMODEREG),
		.AREG               (AREG),
		.AUTORESET_PATDET   (AUTORESET_PATDET),
		.A_INPUT            (A_INPUT),
		.BCASCREG           (BCASCREG),
		.BREG               (BREG),
		.B_INPUT            (B_INPUT),
		.CARRYINREG         (CARRYINREG),
		.CARRYINSELREG      (CARRYINSELREG),
		.CREG               (CREG),
		.DREG               (DREG),
		.INMODEREG          (INMODEREG),
		.MREG               (MREG),
		.OPMODEREG          (OPMODEREG),
		.PREG               (PREG),
		.SEL_MASK           (SEL_MASK),
		.SEL_PATTERN        (SEL_PATTERN),
		.USE_DPORT          (USE_DPORT),
		.USE_MULT           (USE_MULT),
		.USE_PATTERN_DETECT (USE_PATTERN_DETECT),
		.USE_SIMD           (USE_SIMD),
		.MASK               (MASK),
		.PATTERN            (PATTERN),
		.IS_ALUMODE_INVERTED(IS_ALUMODE_INVERTED),
		.IS_CARRYIN_INVERTED(IS_CARRYIN_INVERTED),
		.IS_CLK_INVERTED    (IS_CLK_INVERTED),
		.IS_INMODE_INVERTED (IS_INMODE_INVERTED),
		.IS_OPMODE_INVERTED (IS_OPMODE_INVERTED)
	) ref (
		.ACOUT         (REF_ACOUT),
		.BCOUT         (REF_BCOUT),
		.CARRYCASCOUT  (REF_CARRYCASCOUT),
		.CARRYOUT      (REF_CARRYOUT),
		.MULTSIGNOUT   (REF_MULTSIGNOUT),
		.OVERFLOW      (REF_OVERFLOW),
		.P             (REF_P),
		.PATTERNBDETECT(REF_PATTERNBDETECT),
		.PATTERNDETECT (REF_PATTERNDETECT),
		.PCOUT         (REF_PCOUT),
		.UNDERFLOW     (REF_UNDERFLOW),
		.A             (A),
		.ACIN          (ACIN),
		.ALUMODE       (ALUMODE),
		.B             (B),
		.BCIN          (BCIN),
		.C             (C),
		.CARRYCASCIN   (CARRYCASCIN),
		.CEA1          (CEA1),
		.CEA2          (CEA2),
		.CEAD          (CEAD),
		.CEALUMODE     (CEALUMODE),
		.CEB1          (CEB1),
		.CEB2          (CEB2),
		.CEC           (CEC),
		.CECARRYIN     (CECARRYIN),
		.CECTRL        (CECTRL),
		.CED           (CED),
		.CEINMODE      (CEINMODE),
		.CEM           (CEM),
		.CEP           (CEP),
		.CLK           (CLK),
		.D             (D),
		.INMODE        (INMODE),
		.MULTSIGNIN    (MULTSIGNIN),
		.OPMODE        (OPMODE),
		.PCIN          (PCIN),
		.RSTA          (RSTA),
		.RSTALLCARRYIN (RSTALLCARRYIN),
		.RSTALUMODE    (RSTALUMODE),
		.RSTB          (RSTB),
		.RSTC          (RSTC),
		.RSTCTRL       (RSTCTRL),
		.RSTD          (RSTD),
		.RSTINMODE     (RSTINMODE),
		.RSTM          (RSTM),
		.RSTP          (RSTP)
	);

	DSP48E1_UUT #(
		.ACASCREG           (ACASCREG),
		.ADREG              (ADREG),
		.ALUMODEREG         (ALUMODEREG),
		.AREG               (AREG),
		.AUTORESET_PATDET   (AUTORESET_PATDET),
		.A_INPUT            (A_INPUT),
		.BCASCREG           (BCASCREG),
		.BREG               (BREG),
		.B_INPUT            (B_INPUT),
		.CARRYINREG         (CARRYINREG),
		.CARRYINSELREG      (CARRYINSELREG),
		.CREG               (CREG),
		.DREG               (DREG),
		.INMODEREG          (INMODEREG),
		.MREG               (MREG),
		.OPMODEREG          (OPMODEREG),
		.PREG               (PREG),
		.SEL_MASK           (SEL_MASK),
		.SEL_PATTERN        (SEL_PATTERN),
		.USE_DPORT          (USE_DPORT),
		.USE_MULT           (USE_MULT),
		.USE_PATTERN_DETECT (USE_PATTERN_DETECT),
		.USE_SIMD           (USE_SIMD),
		.MASK               (MASK),
		.PATTERN            (PATTERN),
		.IS_ALUMODE_INVERTED(IS_ALUMODE_INVERTED),
		.IS_CARRYIN_INVERTED(IS_CARRYIN_INVERTED),
		.IS_CLK_INVERTED    (IS_CLK_INVERTED),
		.IS_INMODE_INVERTED (IS_INMODE_INVERTED),
		.IS_OPMODE_INVERTED (IS_OPMODE_INVERTED)
	) uut (
		.ACOUT         (ACOUT),
		.BCOUT         (BCOUT),
		.CARRYCASCOUT  (CARRYCASCOUT),
		.CARRYOUT      (CARRYOUT),
		.MULTSIGNOUT   (MULTSIGNOUT),
		.OVERFLOW      (OVERFLOW),
		.P             (P),
		.PATTERNBDETECT(PATTERNBDETECT),
		.PATTERNDETECT (PATTERNDETECT),
		.PCOUT         (PCOUT),
		.UNDERFLOW     (UNDERFLOW),
		.A             (A),
		.ACIN          (ACIN),
		.ALUMODE       (ALUMODE),
		.B             (B),
		.BCIN          (BCIN),
		.C             (C),
		.CARRYCASCIN   (CARRYCASCIN),
		.CEA1          (CEA1),
		.CEA2          (CEA2),
		.CEAD          (CEAD),
		.CEALUMODE     (CEALUMODE),
		.CEB1          (CEB1),
		.CEB2          (CEB2),
		.CEC           (CEC),
		.CECARRYIN     (CECARRYIN),
		.CECTRL        (CECTRL),
		.CED           (CED),
		.CEINMODE      (CEINMODE),
		.CEM           (CEM),
		.CEP           (CEP),
		.CLK           (CLK),
		.D             (D),
		.INMODE        (INMODE),
		.MULTSIGNIN    (MULTSIGNIN),
		.OPMODE        (OPMODE),
		.PCIN          (PCIN),
		.RSTA          (RSTA),
		.RSTALLCARRYIN (RSTALLCARRYIN),
		.RSTALUMODE    (RSTALUMODE),
		.RSTB          (RSTB),
		.RSTC          (RSTC),
		.RSTCTRL       (RSTCTRL),
		.RSTD          (RSTD),
		.RSTINMODE     (RSTINMODE),
		.RSTM          (RSTM),
		.RSTP          (RSTP)
	);


endmodule