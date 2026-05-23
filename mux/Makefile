mux4to1:
	ghdl -a mux4to1.vhd mux4to1_tb.vhd
	ghdl -e mux4to1_tb
	ghdl -r mux4to1_tb --vcd=wave.vcd
	gtkwave wave.vcd

clean:
	ghdl --clean
	rm -f *.vcd *.cf
