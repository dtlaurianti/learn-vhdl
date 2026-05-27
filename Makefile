and_gate:
	$(MAKE) -C and_gate

full_adder:
	$(MAKE) -C adder full_adder

ripple_adder:
	$(MAKE) -C adder ripple_adder

mux4to1:
	$(MAKE) -C mux mux4to1

d_ff:
	$(MAKE) -C d_flip_flop d_ff

counter_8bit:
	$(MAKE) -C counter counter_8bit

traffic_light:
	$(MAKE) -C traffic_light

jk_ff:
	$(MAKE) -C jk_flip_flop

lfsr_4bit:
	$(MAKE) -C lfsr lfsr_4bit

alu_xbit:
	$(MAKE) -C alu alu_xbit

clean:
	$(MAKE) -C and_gate clean
	$(MAKE) -C adder clean
	$(MAKE) -C mux clean
	$(MAKE) -C d_flip_flop clean
	$(MAKE) -C counter clean
	$(MAKE) -C traffic_light clean
	$(MAKE) -C jk_flip_flop clean
	$(MAKE) -C lfsr clean
	$(MAKE) -C alu clean