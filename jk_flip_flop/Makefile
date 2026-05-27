all: jk_ff

export GHDLFLAGS = --std=08

jk_ff:
	ghdl -a $(GHDLFLAGS) jk_flip_flop.vhd jk_flip_flop_tb.vhd
	ghdl -e $(GHDLFLAGS) jk_flip_flop_tb
	ghdl -r $(GHDLFLAGS) jk_flip_flop_tb

clean:
	ghdl --clean $(GHDLFLAGS)
	rm -f *.vcd *.cf