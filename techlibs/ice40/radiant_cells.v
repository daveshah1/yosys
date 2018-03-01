/*
This maps new-style Radiant cells, where possible, to the older iCEcube
SB_ cells

Some mappings are not easily possible, for example IO buffers and registers
are separated in the Radiant cell library but were fused in iCEcube
*/

// Bidirectional IO buffer
module BB_B (input T_N, input I, output O, inout B );
 SB_IO #(
   .PIN_TYPE(6'b101001),
   .PULLUP(1'b1)
 ) sb_io_i (
    .PACKAGE_PIN(B),
    .D_OUT_0(I),
    .D_IN_0(O),
    .OUTPUT_ENABLE(T_N)
 );
endmodule

// Bidirectional IO buffer, I3C capable
module BB_I3C (input T_N, I, PU_ENB, WEAK_PU_ENB, output O, inout B);
  parameter PULLMODE = "100K";

  SB_IO_I3C #(
    .PIN_TYPE(6'b101001),
    .PULLUP(1'b1),
    .PULLMODE(PULLMODE) // TODO: make arachne-pnr recognize this as well as the legacy attribute mechanism
  ) sb_io_i3c_i (
     .PACKAGE_PIN(B),
     .D_OUT_0(I),
     .D_IN_0(O),
     .OUTPUT_ENABLE(T_N),
     .PU_ENB(PU_ENB),
     .WEAK_PU_ENB(WEAK_PU_ENB)
  );
endmodule

// Bidirectional IO buffer, open drain
module BB_OD (input T_N, I, output O, inout B);
 SB_IO_OD #(
   .PIN_TYPE(6'b101001),
   .PULLUP(1'b1)
 ) sb_io_od_i (
    .PACKAGEPIN(B),
    .DOUT0(I),
    .DIN0(O),
    .OUTPUTENABLE(T_N)
 );
endmodule

// Non-inverting buffer
module BUF (input A, output Z); assign Z = A; endmodule

// Dual carry chain
module CCU2_B(input A0, B0, C0, CIN, A1, B1, C1, output COUT, S0, S1);
  parameter INIT0 = "0xc33c";
  parameter INIT1 = "0xc33c";

  wire carry;

  SB_LUT4 #(.LUT_INIT(INIT0)) lut_0 (.O(S0), .I0(A0), .I1(B0), .I2(C0), .I3(CIN));
  SB_CARRY carry_0 (.CO(carry), .I0(B0), .I1(C0), .CI(CIN));

  SB_LUT4 #(.LUT_INIT(INIT1)) lut_1 (.O(S1), .I0(A1), .I1(B1), .I2(C1), .I3(carry));
  SB_CARRY carry_1 (.CO(COUT), .I0(B1), .I1(C1), .CI(carry));

endmodule

// 4kbit block RAM
module EBR_B (
	input RADDR10, RADDR9, RADDR8, RADDR7, RADDR6, RADDR5, RADDR4, RADDR3, RADDR2, RADDR1, RADDR0,
				WADDR10, WADDR9, WADDR8, WADDR7, WADDR6, WADDR5, WADDR4, WADDR3, WADDR2, WADDR1, WADDR0,
				MASK_N15, MASK_N14, MASK_N13, MASK_N12, MASK_N11, MASK_N10, MASK_N9, MASK_N8, MASK_N7, MASK_N6, MASK_N5, MASK_N4, MASK_N3, MASK_N2, MASK_N1, MASK_N0,
				WDATA15, WDATA14, WDATA13, WDATA12, WDATA11, WDATA10, WDATA9, WDATA8, WDATA7, WDATA6, WDATA5, WDATA4, WDATA3, WDATA2, WDATA1, WDATA0,
				RCLKE, RCLK, RE, WCLKE, WCLK, WE, 
	output RDATA15, RDATA14, RDATA13, RDATA12, RDATA11, RDATA10, RDATA9, RDATA8, RDATA7, RDATA6, RDATA5, RDATA4, RDATA3, RDATA2, RDATA1, RDATA0);

	parameter INIT_0 = "0x0000000000000000000000000000000000000000000000000000000000000000";
	parameter INIT_1 = "0x0000000000000000000000000000000000000000000000000000000000000000";
	parameter INIT_2 = "0x0000000000000000000000000000000000000000000000000000000000000000";
	parameter INIT_3 = "0x0000000000000000000000000000000000000000000000000000000000000000";
	parameter INIT_4 = "0x0000000000000000000000000000000000000000000000000000000000000000";
	parameter INIT_5 = "0x0000000000000000000000000000000000000000000000000000000000000000";
	parameter INIT_6 = "0x0000000000000000000000000000000000000000000000000000000000000000";
	parameter INIT_7 = "0x0000000000000000000000000000000000000000000000000000000000000000";
	parameter INIT_8 = "0x0000000000000000000000000000000000000000000000000000000000000000";
	parameter INIT_9 = "0x0000000000000000000000000000000000000000000000000000000000000000";
	parameter INIT_A = "0x0000000000000000000000000000000000000000000000000000000000000000";
	parameter INIT_B = "0x0000000000000000000000000000000000000000000000000000000000000000";
	parameter INIT_C = "0x0000000000000000000000000000000000000000000000000000000000000000";
	parameter INIT_D = "0x0000000000000000000000000000000000000000000000000000000000000000";
	parameter INIT_E = "0x0000000000000000000000000000000000000000000000000000000000000000";
	parameter INIT_F = "0x0000000000000000000000000000000000000000000000000000000000000000";
	parameter DATA_WIDTH_W = "2";
	parameter DATA_WIDTH_R = "2";

  wire RADDR = {RADDR10, RADDR9, RADDR8, RADDR7, RADDR6, RADDR5, RADDR4, RADDR3, RADDR2, RADDR1, RADDR0};
  wire WADDR = {WADDR10, WADDR9, WADDR8, WADDR7, WADDR6, WADDR5, WADDR4, WADDR3, WADDR2, WADDR1, WADDR0};
  wire MASK = {MASK_N15, MASK_N14, MASK_N13, MASK_N12, MASK_N11, MASK_N10, MASK_N9, MASK_N8, MASK_N7, MASK_N6, MASK_N5, MASK_N4, MASK_N3, MASK_N2, MASK_N1, MASK_N0};
  wire WDATA = {WDATA15, WDATA14, WDATA13, WDATA12, WDATA11, WDATA10, WDATA9, WDATA8, WDATA7, WDATA6, WDATA5, WDATA4, WDATA3, WDATA2, WDATA1, WDATA0};

  localparam WRITE_MODE = (DATA_WIDTH_W == "16") ? 0 : ((DATA_WIDTH_W == "8") ? 1 : ((DATA_WIDTH_W == "4") ? 2 : 3));
  localparam READ_MODE = (DATA_WIDTH_R == "16") ? 0 : ((DATA_WIDTH_R == "8") ? 1 : ((DATA_WIDTH_R == "4") ? 2 : 3));

  SB_RAM40_4K #(
  	.INIT_0(INIT_0), .INIT_1(INIT_1), .INIT_2(INIT_2), .INIT_3(INIT_3), 
  	.INIT_4(INIT_4), .INIT_5(INIT_5), .INIT_6(INIT_6), .INIT_7(INIT_7), 
  	.INIT_8(INIT_8), .INIT_9(INIT_9), .INIT_A(INIT_A), .INIT_B(INIT_B), 
  	.INIT_C(INIT_C), .INIT_D(INIT_D), .INIT_E(INIT_E), .INIT_F(INIT_F), 
  	.WRITE_MODE(WRITE_MODE),
  	.READ_MODE(READ_MODE),
  ) sb_ram_i (
  	.RDATA({RDATA15, RDATA14, RDATA13, RDATA12, RDATA11, RDATA10, RDATA9, RDATA8, RDATA7, RDATA6, RDATA5, RDATA4, RDATA3, RDATA2, RDATA1, RDATA0}),
  	.RCLK(RCLK), .RCLKE(RCLKE), .RE(RE),
  	.RADDR(RADDR),
  	.WCLK(WCLK), .WCLKE(WCLKE), .WE(WE),
  	.WADDR(WADDR),
  	.MASK(MASK), .WDATA(WDATA)
  );
endmodule 

// Dual full adder
module FA2(input A0, B0, C0, D0, CI0, A1, B1, C1, D1, CI1, output CO0, CO1, S0, S1);
  parameter INIT0 = "0xc33c";
  parameter INIT1 = "0xc33c";

  wire carry;

  SB_LUT4 #(.LUT_INIT(INIT0)) lut_0 (.O(S0), .I0(A0), .I1(B0), .I2(C0), .I3(D0));
  SB_CARRY carry_0 (.CO(CO0), .I0(B0), .I1(C0), .CI(CI0));

  SB_LUT4 #(.LUT_INIT(INIT1)) lut_1 (.O(S1), .I0(A1), .I1(B1), .I2(C1), .I3(D1));
  SB_CARRY carry_1 (.CO(CO1), .I0(B1), .I1(C1), .CI(CI1));

endmodule

// Positive edge triggered DFF with active high enable and active high async preset
module FD1P3BZ(input D, CK, SP, PD, output Q); SB_DFFES dff_i(.D(D), .C(CK), .E(SP), .S(PD), .Q(Q)); endmodule

// Positive edge triggered DFF with active high enable and active high async clear
module FD1P3DZ(input D, CK, SP, CD, output Q); SB_DFFER dff_i(.D(D), .C(CK), .E(SP), .R(CD), .Q(Q)); endmodule

// Positive edge triggered DFF with active high enable and active high sync clear
module FD1P3IZ(input D, CK, SP, CD, output Q); SB_DFFESR dff_i(.D(D), .C(CK), .E(SP), .R(CD), .Q(Q)); endmodule

// Positive edge triggered DFF with active high enable and active high sync preset
module FD1P3JZ(input D, CK, SP, PD, output Q); SB_DFFESS dff_i(.D(D), .C(CK), .E(SP), .S(PD), .Q(Q)); endmodule

// Positive edge triggered DFF with active high enable and active high sync/async clear/preset
module FD1P3XZ(input D, CK, SP, SR, output Q);
  parameter REGSET = "RESET";
  parameter SRMODE = "CE_OVER_LSR";

  generate
  if((REGSET == "RESET") && (SRMODE=="CE_OVER_LSR")) begin
    SB_DFFESR dff_i(.D(D), .C(CK), .E(SP), .R(SR), .Q(Q));
  end else if((REGSET == "SET") && (SRMODE=="CE_OVER_LSR")) begin
    SB_DFFESS dff_i(.D(D), .C(CK), .E(SP), .S(SR), .Q(Q));
  end else if((REGSET == "RESET") && (SRMODE=="ASYNC")) begin
    SB_DFFER dff_i(.D(D), .C(CK), .E(SP), .R(SR), .Q(Q));
  end else if((REGSET == "SET") && (SRMODE=="ASYNC")) begin
    SB_DFFES dff_i(.D(D), .C(CK), .E(SP), .S(SR), .Q(Q));
  end
  endgenerate

endmodule

// TODO: FILTER (blackbox, no corresponding SB_, needs implementation in arachne)

// 48MHz internal oscillator with divider
module HSOSC(input CLKHFPU, input CLKHFEN, output CLKHF);
  parameter CLKHF_DIV = "0b00";
  SB_HFOSC #(.CLKHF_DIV(CLKHF_DIV)) hfosc_i (
    .CLKHFPU(CLKHFPU),
    .CLKHFEN(CLKHFEN),
    .CLKHF(CLKHF)
  );
endmodule

// TODO: other oscillators e.g. 1.8V (blackbox, no corresponding SB_, needs implementation in arachne)

// I2C IP core
module I2C_B (
	input  SBCLKI,
	input  SBRWI,
	input  SBSTBI,
	input  SBADRI7,
	input  SBADRI6,
	input  SBADRI5,
	input  SBADRI4,
	input  SBADRI3,
	input  SBADRI2,
	input  SBADRI1,
	input  SBADRI0,
	input  SBDATI7,
	input  SBDATI6,
	input  SBDATI5,
	input  SBDATI4,
	input  SBDATI3,
	input  SBDATI2,
	input  SBDATI1,
	input  SBDATI0,
	input  SCLI,
	input  SDAI,
	output SBDATO7,
	output SBDATO6,
	output SBDATO5,
	output SBDATO4,
	output SBDATO3,
	output SBDATO2,
	output SBDATO1,
	output SBDATO0,
	output SBACKO,
	output I2CIRQ,
	output I2CWKUP,
	output SCLO,
	output SCLOE,
	output SDAO,
	output SDAOE
);
parameter I2C_SLAVE_INIT_ADDR = "0b1111100001";
parameter BUS_ADDR74 = "0b0001";
parameter I2C_CLK_DIVIDER = "0"; //timing analysis only
parameter SDA_INPUT_DELAYED = "0";
parameter SDA_OUTPUT_DELAYED = "0";
parameter FREQUENCY_PIN_SBCLKI = "0"; //timing analysis only

SB_I2C #(
  .I2C_SLAVE_INIT_ADDR(I2C_SLAVE_INIT_ADDR),
  .BUS_ADDR74(BUS_ADDR74),
  .SDA_INPUT_DELAYED(SDA_INPUT_DELAYED), //both NYI in arachne-pnr
  .SDA_OUTPUT_DELAYED(SDA_OUTPUT_DELAYED)
) i2c_i (
  .SBCLKI(SBCLKI),
  .SBRWI(SBRWI),
  .SBSTBI(SBSTBI),
  .SBADRI0(SBADRI0),
  .SBADRI1(SBADRI1),
  .SBADRI2(SBADRI2),
  .SBADRI3(SBADRI3),
  .SBADRI4(SBADRI4),
  .SBADRI5(SBADRI5),
  .SBADRI6(SBADRI6),
  .SBADRI7(SBADRI7),
  .SBDATI0(SBDATI0),
  .SBDATI1(SBDATI1),
  .SBDATI2(SBDATI2),
  .SBDATI3(SBDATI3),
  .SBDATI4(SBDATI4),
  .SBDATI5(SBDATI5),
  .SBDATI6(SBDATI6),
  .SBDATI7(SBDATI7),
  .SBDATO0(SBDATO0),
  .SBDATO1(SBDATO1),
  .SBDATO2(SBDATO2),
  .SBDATO3(SBDATO3),
  .SBDATO4(SBDATO4),
  .SBDATO5(SBDATO5),
  .SBDATO6(SBDATO6),
  .SBDATO7(SBDATO7),
  .SBACKO(SBACKO),
  .I2CIRQ(I2CIRQ),
  .I2CWKUP(I2CWKUP),
  .SCLI(SCLI),
  .SCLO(SCLO),
  .SCLOE(SCLOE),
  .SDAI(SDAI),
  .SDAO(SDAO),
  .SDAOE(SDAOE)
);

endmodule

// Input buffer
module IB(input I, output O);
SB_IO #(
  .PIN_TYPE(6'b000001),
  .PULLUP(1'b1)
) sb_io_i (
   .PACKAGE_PIN(I),
   .D_IN_0(O)
);
endmodule

// Input flipflop - currently not possible to map to IO flipflop because SB_IO isn't fracturable, so map to a
// regular one for a degree of functional correctness
module IFD1P3AZ(input D, SP, CK, output Q); SB_DFFE dff_i(.D(D), .E(SP), .C(CK), .Q(Q)); endmodule

// Inverter
module INV(input A, output Z); assign Z = ~A; endmodule

// TODO: IOL - impossible without fracturable SB_IO

// 10kHz oscillator
module LSOSC(input CLKLFPU, CLKLFEN, output CLKLF); SB_LFOSC lfosc_i(.CLKLFPU(CLKLFPU), .CLKLFEN(CLKLFEN), .CLKLF(CLKLF)); endmodule

// 4-input LUT
module LUT4(input A, B, C, D, output Z);
parameter INIT = "0x0000";

SB_LUT4 #(.LUT_INIT(INIT)) lut_i (.O(Z), .I0(A), .I1(B), .I2(C), .I3(D));
endmodule

// DSP core
module MAC16 (
  input CLK, CE,
  C15, C14, C13, C12, C11, C10, C9, C8, C7, C6, C5, C4, C3, C2, C1, C0,
  A15, A14, A13, A12, A11, A10, A9, A8, A7, A6, A5, A4, A3, A2, A1, A0,
  B15, B14, B13, B12, B11, B10, B9, B8, B7, B6, B5, B4, B3, B2, B1, B0,
  D15, D14, D13, D12, D11, D10, D9, D8, D7, D6, D5, D4, D3, D2, D1, D0,
  AHOLD, BHOLD, CHOLD, DHOLD,
  IRSTTOP, IRSTBOT, ORSTTOP, ORSTBOT,
  OLOADTOP, OLOADBOT, ADDSUBTOP, ADDSUBBOT,
  OHOLDTOP, OHOLDBOT, CI, ACCUMCI, SIGNEXTIN,
  output O31, O30, O29, O28, O27, O26, O25, O24, O23, O22, O21, O20, O19, O18, O17, O16,
  O15, O14, O13, O12, O11, O10, O9, O8, O7, O6, O5, O4, O3, O2, O1, O0,
  CO, ACCUMCO, SIGNEXTOUT);

  parameter NEG_TRIGGER = "0b0";
  parameter C_REG = "0b0";
  parameter A_REG = "0b0";
  parameter B_REG = "0b0";
  parameter D_REG = "0b0";
  parameter TOP_8x8_MULT_REG = "0b0";
  parameter BOT_8x8_MULT_REG = "0b0";
  parameter PIPELINE_16x16_MULT_REG1 = "0b0";
  parameter PIPELINE_16x16_MULT_REG2 = "0b0";
  parameter TOPOUTPUT_SELECT =  "0b00";
  parameter TOPADDSUB_LOWERINPUT = "0b00";
  parameter TOPADDSUB_UPPERINPUT = "0b0";
  parameter TOPADDSUB_CARRYSELECT = "0b00";
  parameter BOTOUTPUT_SELECT =  "0b00";
  parameter BOTADDSUB_LOWERINPUT = "0b00";
  parameter BOTADDSUB_UPPERINPUT = "0b0";
  parameter BOTADDSUB_CARRYSELECT = "0b00";
  parameter MODE_8x8 = "0b0";
  parameter A_SIGNED = "0b0";
  parameter B_SIGNED = "0b0";
  
  wire [15:0] C = {C15, C14, C13, C12, C11, C10, C9, C8, C7, C6, C5, C4, C3, C2, C1, C0};
  wire [15:0] A = {A15, A14, A13, A12, A11, A10, A9, A8, A7, A6, A5, A4, A3, A2, A1, A0};
  wire [15:0] B = {B15, B14, B13, B12, B11, B10, B9, B8, B7, B6, B5, B4, B3, B2, B1, B0};
  wire [15:0] D = {D15, D14, D13, D12, D11, D10, D9, D8, D7, D6, D5, D4, D3, D2, D1, D0};

  SB_MAC16 #(
    .NEG_TRIGGER(NEG_TRIGGER),
    .C_REG(C_REG),
    .A_REG(A_REG),
    .B_REG(B_REG),
    .D_REG(D_REG),
    .TOP_8x8_MULT_REG(TOP_8x8_MULT_REG),
    .BOT_8x8_MULT_REG(BOT_8x8_MULT_REG),
    .PIPELINE_16x16_MULT_REG1(PIPELINE_16x16_MULT_REG1),
    .PIPELINE_16x16_MULT_REG2(PIPELINE_16x16_MULT_REG2),
    .TOPOUTPUT_SELECT(TOPOUTPUT_SELECT),
    .TOPADDSUB_LOWERINPUT(TOPADDSUB_LOWERINPUT),
    .TOPADDSUB_UPPERINPUT(TOPADDSUB_UPPERINPUT),
    .TOPADDSUB_CARRYSELECT(TOPADDSUB_CARRYSELECT),
    .BOTOUTPUT_SELECT(BOTOUTPUT_SELECT),
    .BOTADDSUB_LOWERINPUT(BOTADDSUB_LOWERINPUT),
    .BOTADDSUB_UPPERINPUT(BOTADDSUB_UPPERINPUT),
    .BOTADDSUB_CARRYSELECT(BOTADDSUB_CARRYSELECT),
    .MODE_8x8(MODE_8x8),
    .A_SIGNED(A_SIGNED),
    .B_SIGNED(B_SIGNED)
  ) i_sbmac16 (
    .A(A),
    .B(B),
    .C(C),
    .D(D),
    .O({O31, O30, O29, O28, O27, O26, O25, O24, O23, O22, O21, O20, O19, O18, O17, O16, O15, O14, O13, O12, O11, O10, O9, O8, O7, O6, O5, O4, O3, O2, O1, O0}),
    .CLK(CLK),
    .IRSTTOP(IRSTTOP),
    .IRSTBOT(IRSTBOT),
    .ORSTTOP(ORSTTOP),
    .ORSTBOT(ORSTBOT),
    .AHOLD(AHOLD),
    .BHOLD(BHOLD),
    .CHOLD(CHOLD),
    .DHOLD(DHOLD),
    .OHOLDTOP(OHOLDTOP),
    .OHOLDBOT(OHOLDBOT),
    .OLOADTOP(OLOADTOP),
    .OLOADBOT(OLOADBOT),
    .ADDSUBTOP(ADDSUBTOP),
    .ADDSUBBOT(ADDSUBBOT),
    .CO(CO),
    .CI(CI),
    .ACCUMCI(ACCUMCI),
    .ACCUMCO(ACCUMCO),
    .SIGNEXTIN(SIGNEXTIN),
    .SIGNEXTOUT(SIGNEXTOUT)
  );
endmodule

// Output buffer
module OB(input I, output O); 
SB_IO #(
  .PIN_TYPE(6'b011000),
  .PULLUP(1'b1)
) sb_io_i (
   .PACKAGE_PIN(O),
   .D_OUT_0(I)
);
endmodule

// OB_RGB not supported, it is not recommended even in Radiant (use RGB instead)

// Output buffer with tristate
module OBZ_B(input I, input T_N, output O); 
SB_IO #(
  .PIN_TYPE(6'b101000),
  .PULLUP(1'b1)
) sb_io_i (
   .PACKAGE_PIN(O),
   .D_OUT_0(I),
   .OUTPUT_ENABLE(T_N)
);
endmodule


// Output flipflop - currently not possible to map to IO flipflop because SB_IO isn't fracturable, so map to a
// regular one for a degree of functional correctness
module OFD1P3AZ(input D, SP, CK, output Q); SB_DFFE dff_i(.D(D), .E(SP), .C(CK), .Q(Q)); endmodule
