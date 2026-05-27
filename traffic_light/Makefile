all: traffic_light

export GHDLFLAGS = --std=08

traffic_light:
	ghdl -a $(GHDLFLAGS) traffic_light_fsm.vhd traffic_light_fsm_tb.vhd
	ghdl -e $(GHDLFLAGS) traffic_light_fsm_tb
	ghdl -r $(GHDLFLAGS) traffic_light_fsm_tb --vcd=wave.vcd

clean:
	ghdl --clean
	rm -f *.vcd *.cf