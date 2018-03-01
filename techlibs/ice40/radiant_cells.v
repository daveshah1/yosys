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
