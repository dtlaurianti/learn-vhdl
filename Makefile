and_gate:
	$(MAKE) -C and_gate

full_adder:
	$(MAKE) -C adder full_adder

ripple_adder:
	$(MAKE) -C adder ripple_adder

clean:
	$(MAKE) -C and_gate clean
	$(MAKE) -C adder clean
