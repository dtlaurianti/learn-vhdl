export GHDLFLAGS = --std=08

d_ff:
	ghdl -a $(GHDLFLAGS) d_flip_flop.vhd d_flip_flop_tb.vhd
	ghdl -e $(GHDLFLAGS) d_flip_flop_tb
	ghdl -r $(GHDLFLAGS) d_flip_flop_tb

clean:
	ghdl --clean $(GHDLFLAGS)
	rm -f *.vcd *.cf
