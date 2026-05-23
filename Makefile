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

clean:
	$(MAKE) -C and_gate clean
	$(MAKE) -C adder clean
	$(MAKE) -C mux clean
	$(MAKE) -C d_flip_flop clean
