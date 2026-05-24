export GHDLFLAGS = --std=08

counter_8bit:
	ghdl -a $(GHDLFLAGS) counter_8bit.vhd counter_8bit_tb.vhd
	ghdl -e $(GHDLFLAGS) counter_8bit_tb
	ghdl -r $(GHDLFLAGS) counter_8bit_tb --vcd=wave.vcd
	gtkwave wave.vcd

clean:
	ghdl --clean
	rm -f *.vcd *.cf
