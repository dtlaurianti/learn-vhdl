export GHDLFLAGS = --std=08

alu_xbit:
	ghdl -a $(GHDLFLAGS) alu_xbit.vhd alu_xbit_tb.vhd
	ghdl -e $(GHDLFLAGS) alu_xbit_tb
	ghdl -r $(GHDLFLAGS) alu_xbit_tb

clean:
	ghdl --clean $(GHDLFLAGS)
	rm -f *.vcd *.cf