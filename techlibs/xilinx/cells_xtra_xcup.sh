#!/bin/bash

set -e
libdir="/opt/Xilinx/Vivado/2019.1/data/verilog/src"

function xtract_cell_decl()
{
	for dir in $libdir/xeclib $libdir/retarget; do
		[ -f $dir/$1.v ] || continue
		[ -z "$2" ] || echo $2
		egrep '^\s*((end)?module|parameter|input|inout|output|(end)?function|(end)?task)' $dir/$1.v |
			sed -re '/UNPLACED/ d; /^\s*function/,/endfunction/ d; /^\s*task/,/endtask/ d;
			         s,//.*,,; s/^\s*module ([A-Z0-9a-z_]+)+.*/module \1 (...);/; s/^(input|output|parameter)/ \1/;
			         s/\s+$//; s/,$/;/; /input|output|parameter/ s/[^;]$/&;/; s/\s+/ /g;
				 s/^ ((end)?module)/\1/; s/^ /    /; /module.*_bb/,/endmodule/ d;'
		echo; return
	done
	echo "Can't find $1."
	exit 1
}

{
	echo "// Created by cells_xtra.sh from Xilinx models"
	echo

	# Design elements types listed in Xilinx UG974
	xtract_cell_decl BITSLICE_CONTROL
	xtract_cell_decl BSCANE2
	# xtract_cell_decl BUFG
	xtract_cell_decl BUFG_GT
	xtract_cell_decl BUFG_GT_SYNC
	xtract_cell_decl BUFG_PS
	xtract_cell_decl BUFGCE
	xtract_cell_decl BUFGCE_1
	xtract_cell_decl BUFGCE_DIV
	#xtract_cell_decl BUFGCTRL
	xtract_cell_decl BUFGMUX
	xtract_cell_decl BUFGMUX_1
	xtract_cell_decl BUFGMUX_CTRL
	xtract_cell_decl CARRY8
	xtract_cell_decl CFGLUT5
	xtract_cell_decl CMAC
	xtract_cell_decl CMACE4
	xtract_cell_decl DCIRESET "(* keep *)"
	xtract_cell_decl DNA_PORTE2
	xtract_cell_decl DSP48E2
	xtract_cell_decl EFUSE_USR
	# xtract_cell_decl FDCE
	# xtract_cell_decl FDPE
	# xtract_cell_decl FDRE
	# xtract_cell_decl FDSE
	xtract_cell_decl FIFO18E2
	xtract_cell_decl FIFO36E2
	xtract_cell_decl FRAME_ECCE3
	xtract_cell_decl FRAME_ECCE4
	xtract_cell_decl GTHE3_CHANNEL
	xtract_cell_decl GTHE3_COMMON
	xtract_cell_decl GTHE4_CHANNEL
	xtract_cell_decl GTHE4_COMMON
	xtract_cell_decl GTYE3_CHANNEL
	xtract_cell_decl GTYE3_COMMON
	xtract_cell_decl GTYE4_CHANNEL
	xtract_cell_decl GTYE4_COMMON
	xtract_cell_decl HARD_SYNC
	xtract_cell_decl HPIO_VREF
	xtract_cell_decl HPIO_VREF
	# xtract_cell_decl IBUF
	xtract_cell_decl IBUF_ANALOG
	xtract_cell_decl IBUF_IBUFDISABLE
	xtract_cell_decl IBUF_INTERMDISABLE
	xtract_cell_decl IBUFDS
	xtract_cell_decl IBUFDS_DIFF_OUT
	xtract_cell_decl IBUFDS_DIFF_OUT_IBUFDISABLE
	xtract_cell_decl IBUFDS_DIFF_OUT_INTERMDISABLE
	xtract_cell_decl IBUFDS_GTE3
	xtract_cell_decl IBUFDS_GTE4
	xtract_cell_decl IBUFDS_IBUFDISABLE
	xtract_cell_decl IBUFDS_INTERMDISABLE
	xtract_cell_decl IBUFDSE3
	xtract_cell_decl IBUFE3
	xtract_cell_decl ICAPE3 "(* keep *)"
	xtract_cell_decl IDDRE1
	xtract_cell_decl IDELAYCTRL "(* keep *)"
	xtract_cell_decl IDELAYE3
	xtract_cell_decl ILKN
	xtract_cell_decl IOBUF
	xtract_cell_decl IOBUF_DCIEN
	xtract_cell_decl IOBUF_INTERMDISABLE
	xtract_cell_decl IOBUFDS
	xtract_cell_decl IOBUFDS_DCIEN
	xtract_cell_decl IOBUFDS_DIFF_OUT
	xtract_cell_decl IOBUFDS_DIFF_OUT_DCIEN
	xtract_cell_decl IOBUFDS_DIFF_OUT_INTERMDISABLE
	xtract_cell_decl IOBUFDSE3
	xtract_cell_decl IOBUFE3
	xtract_cell_decl ISERDESE3
	xtract_cell_decl KEEPER
	xtract_cell_decl LDCE
	xtract_cell_decl LDPE
	# xtract_cell_decl LUT1
	# xtract_cell_decl LUT2
	# xtract_cell_decl LUT3
	# xtract_cell_decl LUT4
	# xtract_cell_decl LUT5
	# xtract_cell_decl LUT6
	#xtract_cell_decl LUT6_2
	xtract_cell_decl MASTER_JTAG
	xtract_cell_decl MMCME3_ADV
	xtract_cell_decl MMCME3_BASE
	xtract_cell_decl MMCME4_ADV
	# xtract_cell_decl MUXF7
	# xtract_cell_decl MUXF8
	# xtract_cell_decl OBUF
	xtract_cell_decl OBUFDS
	xtract_cell_decl OBUFDS_GTE3
	xtract_cell_decl OBUFDS_GTE3_ADV
	xtract_cell_decl OBUFDS_GTE4
	xtract_cell_decl OBUFDS_GTE4_ADV
	xtract_cell_decl OBUFT
	xtract_cell_decl OBUFTDS
	xtract_cell_decl ODDRE1
	xtract_cell_decl ODELAYE3
	xtract_cell_decl OR2L
	xtract_cell_decl OSERDESE3
	xtract_cell_decl PCIE40E4
	xtract_cell_decl PCIE_3_1
	xtract_cell_decl PLLE3_ADV
	xtract_cell_decl PLLE3_BASE
	xtract_cell_decl PLLE4_ADV
	xtract_cell_decl PS8 "(* keep *)"
	xtract_cell_decl PULLDOWN
	xtract_cell_decl PULLUP
	xtract_cell_decl RAM128X1D
	xtract_cell_decl RAM128X1S
	xtract_cell_decl RAM256X1D
	xtract_cell_decl RAM256X1S
	xtract_cell_decl RAM32M
	xtract_cell_decl RAM32M16
	xtract_cell_decl RAM32X1D
	xtract_cell_decl RAM32X1S
	xtract_cell_decl RAM32X2S
	xtract_cell_decl RAM512X1S
	xtract_cell_decl RAM64M
	xtract_cell_decl RAM64M8
	xtract_cell_decl RAM64X1D
	xtract_cell_decl RAM64X1S
	xtract_cell_decl RAM64X8SW
	xtract_cell_decl RAMB18E2
	xtract_cell_decl RAMB36E2
	xtract_cell_decl RIU_OR
	xtract_cell_decl RX_BITSLICE
	xtract_cell_decl RXTX_BITSLICE
	#xtract_cell_decl SRL16E
	#xtract_cell_decl SRLC32E
	xtract_cell_decl STARTUPE3 "(* keep *)"
	xtract_cell_decl SYSMONE1 "(* keep *)"
	xtract_cell_decl SYSMONE4 "(* keep *)"
	xtract_cell_decl TX_BITSLICE
	xtract_cell_decl TX_BITSLICE_TRI
	xtract_cell_decl URAM288
	xtract_cell_decl URAM288_BASE
	xtract_cell_decl USR_ACCESSE2
} > cells_xtra_xcup.new

mv cells_xtra_xcup.new cells_xtra_xcup.v
exit 0

