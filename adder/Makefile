full_adder:
	ghdl -a full_adder.vhd full_adder_tb.vhd
	ghdl -e full_adder_tb
	ghdl -r full_adder_tb --vcd=full_adder.vcd
	gtkwave full_adder.vcd

ripple_adder:
	ghdl -a full_adder.vhd ripple_adder.vhd ripple_adder_tb.vhd
	ghdl -e ripple_adder_tb
	ghdl -r ripple_adder_tb --vcd=ripple_adder.vcd
	gtkwave ripple_adder.vcd

clean:
	ghdl --clean
	rm -f *.vcd *.cf
