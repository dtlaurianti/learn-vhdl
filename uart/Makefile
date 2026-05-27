all: uart_8n1_tx

export GHDLFLAGS = --std=08

uart_8n1_tx:
	ghdl -a $(GHDLFLAGS) uart_8n1_tx.vhd uart_8n1_tx_tb.vhd
	ghdl -e $(GHDLFLAGS) uart_8n1_tx_tb
	ghdl -r $(GHDLFLAGS) uart_8n1_tx_tb --vcd=wave.vcd

clean:
	ghdl --clean
	rm -f *.vcd *.cf