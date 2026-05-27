library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity uart_8n1_tx_tb is
-- Testbenches have no ports
end entity uart_8n1_tx_tb;

architecture sim of uart_8n1_tx_tb is

  -- 1. Timing and Protocol Constants
  constant t_clk       : time    := 10 ns; -- 100 MHz Main System Clock
  constant c_clk_freq  : integer := 100_000_000;
  constant c_baud_rate : integer := 115_200;

  -- Calculate precise clock counts per bit
  constant c_clks_per_bit : integer := c_clk_freq / c_baud_rate; -- 868 clock cycles

  -- 2. Testbench Interconnect Signals
  signal clk       : std_logic                    := '0';
  signal rst       : std_logic                    := '1';
  signal tx_start  : std_logic                    := '0';
  signal tx_data   : std_logic_vector(7 downto 0) := (others => '0');
  signal tx_active : std_logic;
  signal tx_serial : std_logic;
  signal tx_done   : std_logic;

begin

  -- 3. Device Under Test (DUT) Instantiation
  dut : entity work.uart_8n1_tx
    generic map (
      g_clk_freq  => c_clk_freq,
      g_baud_rate => c_baud_rate
    )
    port map (
      clk       => clk,
      rst       => rst,
      tx_start  => tx_start,
      tx_data   => tx_data,
      tx_active => tx_active,
      tx_serial => tx_serial,
      tx_done   => tx_done
    );

  -- 4. Clock Generation Process (100 MHz)
  clk_process : process is
  begin

    clk <= '0';
    wait for t_clk / 2;
    clk <= '1';
    wait for t_clk / 2;

  end process clk_process;

  -- 5. Main Stimulus & Verification Engine
  stim_proc : process is

    -- Helper procedure to count exact clock cycles on the falling edge

    procedure wait_cycles (
      constant n : in natural
    ) is
    begin

      for i in 1 to n loop

        wait until falling_edge(clk);

      end loop;

    end procedure wait_cycles;

    -- Inline procedure to handle structured byte transmissions and timing verifications

    procedure send_and_verify_byte (
      constant data_pattern : in std_logic_vector(7 downto 0)
    ) is
    begin

      wait until falling_edge(clk);
      tx_data  <= data_pattern;
      tx_start <= '1';
      wait until falling_edge(clk);
      tx_start <= '0';

      -- --- Step A: Verify Start Bit Timing Window ---
      assert (tx_active = '1')
        report "ERROR: tx_active failed to assert on start bit"
        severity failure;
      assert (tx_serial = '0')
        report "ERROR: tx_serial failed to drop low for start bit"
        severity failure;

      -- Move to the exact middle of the start bit window (434 clock cycles)
      wait_cycles(c_clks_per_bit / 2);

      assert (tx_serial = '0')
        report "ERROR: Start bit unstable midway through period"
        severity failure;

      -- --- Step B: Verify Data Bits (LSB First Loop) ---
      for i in 0 to 7 loop

        -- Advance a full bit period (868 clock cycles) to the middle of the next bit
        wait_cycles(c_clks_per_bit);

        assert (tx_serial = data_pattern(i))
          report "ERROR: Bit mismatch at index " & integer'image(i) &
                 " Expected: " & std_logic'image(data_pattern(i)) &
                 " Got: " & std_logic'image(tx_serial)
          severity failure;

      end loop;

      -- --- Step C: Verify Stop Bit Window ---
      -- Advance to the middle of the stop bit
      wait_cycles(c_clks_per_bit);

      assert (tx_serial = '1')
        report "ERROR: Stop bit not driven high"
        severity failure;

      -- Return alignment back to the end of the stop bit window
      wait_cycles(c_clks_per_bit / 2);

    end procedure send_and_verify_byte;

  begin

    ----------------------------------------------------------------------------
    -- PHASE 1: Power-On Reset Validation
    ----------------------------------------------------------------------------
    rst <= '1';
    wait_cycles(5);

    assert (tx_serial = '1')
      report "PHASE 1 FAILED: Serial line must idle high during reset"
      severity failure;
    assert (tx_active = '0')
      report "PHASE 1 FAILED: Active flag must be low during reset"
      severity failure;
    assert (tx_done = '0')
      report "PHASE 1 FAILED: Done flag must be low during reset"
      severity failure;

    wait until falling_edge(clk);
    rst <= '0';
    wait_cycles(2);

    ----------------------------------------------------------------------------
    -- PHASE 2: Single Byte Standard Frame Verification (Data: 0x5A -> 01011010)
    ----------------------------------------------------------------------------
    send_and_verify_byte(X"5A");

    -- Ensure tx_done pulses for exactly one cycle immediately following stop bit
    assert (tx_done = '1')
      report "PHASE 2 FAILED: tx_done pulse missing after stop bit"
      severity failure;
    assert (tx_active = '0')
      report "PHASE 2 FAILED: tx_active did not drop upon completion"
      severity failure;

    wait until falling_edge(clk);
    assert (tx_done = '0')
      report "PHASE 2 FAILED: tx_done stuck high; must clear after 1 cycle"
      severity failure;

    ----------------------------------------------------------------------------
    -- PHASE 3: Back-to-Back Zero-Latency Check
    ----------------------------------------------------------------------------
    wait until falling_edge(clk);
    tx_data  <= x"A5";
    tx_start <= '1';
    wait until falling_edge(clk);
    tx_start <= '0';

    -- Fast-forward past the entire transmission frame: 10 full bits (Start + 8 Data + Stop)
    wait_cycles(c_clks_per_bit * 10);

    -- Check done pulse cycle
    assert (tx_done = '1')
      report "PHASE 3 FAILED: First byte done pulse missed"
      severity failure;

    -- Stream in the second byte immediately on the exact done edge boundary
    tx_data  <= x"FF";
    tx_start <= '1';
    wait until falling_edge(clk);
    tx_start <= '0';

    -- Verify the line did not leak an unidle bit and dropped straight into the start bit
    assert (tx_active = '1')
      report "PHASE 3 FAILED: FSM did not remain active back-to-back"
      severity failure;
    assert (tx_serial = '0')
      report "PHASE 3 FAILED: Second start bit skipped back-to-back"
      severity failure;

    -- Let the second frame clear out completely
    wait_cycles(c_clks_per_bit * 10);
    wait until falling_edge(clk);

    ----------------------------------------------------------------------------
    -- PHASE 4: Mid-Transmission Abort Interruption
    ----------------------------------------------------------------------------
    wait until falling_edge(clk);
    tx_data  <= x"00";
    tx_start <= '1';
    wait until falling_edge(clk);
    tx_start <= '0';

    -- Wait for 4 bit periods to pass (Start bit + 3 data bits deep)
    wait_cycles(c_clks_per_bit * 4);

    assert (tx_active = '1')
      report "Setup error for Phase 4"
      severity failure;

    -- Trigger a disruptive hot asynchronous reset pulse mid-cycle
    rst <= '1';
    wait for 2 ns; -- Asynchronous interrupt delay (absolute time is correct here)

    assert (tx_serial = '1')
      report "PHASE 4 FAILED: Serial line failed to pull high instantly on abort"
      severity failure;
    assert (tx_active = '0')
      report "PHASE 4 FAILED: Active flag failed to drop instantly on abort"
      severity failure;

    wait until falling_edge(clk);
    rst <= '0';

    ----------------------------------------------------------------------------
    -- SIMULATION END
    ----------------------------------------------------------------------------
    report "ALL EXHAUSTIVE UART TX VERIFICATION PHASES PASSED SUCCESSFULLY!"
      severity note;
    std.env.finish;

  end process stim_proc;

end architecture sim;
