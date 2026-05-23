full_adder:
	ghdl -a full_adder.vhd full_adder_tb.vhd
	ghdl -e full_adder_tb
	ghdl -r full_adder_tb --vcd=full_adder.vcd
	gtkwave full_adder.vcd

clean:
	ghdl --clean
	rm -f *.vcd *.cf
