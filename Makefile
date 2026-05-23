and_gate:
	$(MAKE) -C and_gate

full_adder:
	$(MAKE) -C adder full_adder

ripple_adder:
	$(MAKE) -C adder ripple_adder

mux4to1:
	$(MAKE) -C mux mux4to1

clean:
	$(MAKE) -C and_gate clean
	$(MAKE) -C adder clean
	$(MAKE) -C mux clean
