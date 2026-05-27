export GHDLFLAGS = --std=08

lfsr_4bit:
	ghdl -a $(GHDLFLAGS) lfsr_4bit.vhd lfsr_4bit_tb.vhd
	ghdl -e $(GHDLFLAGS) lfsr_4bit_tb
	ghdl -r $(GHDLFLAGS) lfsr_4bit_tb

clean:
	ghdl --clean $(GHDLFLAGS)
	rm -f *.vcd *.cf