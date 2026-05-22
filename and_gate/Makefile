and_gate:
	ghdl -a and_gate.vhd and_gate_tb.vhd
	ghdl -e and_gate_tb
	ghdl -r and_gate_tb --vcd=wave.vcd
	gtkwave wave.vcd

clean:
	ghdl --clean
	rm -f *.vcd *.cf
