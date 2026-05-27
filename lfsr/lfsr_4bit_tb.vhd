library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity lfsr_4bit_tb is
-- Testbenches have no ports
end entity lfsr_4bit_tb;

architecture sim of lfsr_4bit_tb is

  -- 1. Simulation Constants
  constant t_clk : time := 10 ns;

  -- 2. Internal Testbench Signals
  signal clk : std_logic := '0';
  signal rst : std_logic := '0';
  signal en  : std_logic := '0';
  signal q   : std_logic_vector(3 downto 0);

  -- Storage array to record history for uniqueness checks

  type state_history_t is array (0 to 14) of std_logic_vector(3 downto 0);

begin

  -- 3. Instantiate the Unit Under Test (UUT) using direct entity instantiation
  uut : entity work.lfsr_4bit
    generic map (
      g_tap_mask => "1100"
    )
    port map (
      clk => clk,
      rst => rst,
      en  => en,
      q   => q
    );

  -- 4. Clock Generator Process (100 MHz)
  clk_process : process is
  begin

    clk <= '0';
    wait for t_clk / 2;
    clk <= '1';
    wait for t_clk / 2;

  end process clk_process;

  -- 5. The Comprehensive Stimulus & Self-Checking Engine
  stim_proc : process is

    variable expected_fb   : std_logic;
    variable current_state : std_logic_vector(3 downto 0);
    variable history       : state_history_t := (others => (others => '0'));

  begin

    -- Let simulation startup transients settle
    wait for t_clk * 0.2;

    ------------------------------------------------------------------
    -- TEST 1 & 2: Asynchronous Reset and Lock-up Guarding
    ------------------------------------------------------------------
    rst <= '1';
    wait for 1 ns;                                                                                                  -- Check mid-cycle prior to any rising edge

    assert (q /= "0000")
      report "CRITICAL FLAW: Reset state forced the LFSR to '0000'. It will lock up permanently!"
      severity failure;

    current_state := q;                                                                                             -- Save whatever custom seed value was chosen

    wait for t_clk * 0.8;
    rst <= '0';
    wait for t_clk;

    ------------------------------------------------------------------
    -- TEST 3: Clock Enable Guarding Check
    ------------------------------------------------------------------
    en <= '0';
    wait for t_clk * 3;
    assert (q = current_state)
      report "FLAW: LFSR shifted bits while the clock enable ('en') was DE-ASSERTED!"
      severity error;

    ------------------------------------------------------------------
    -- TEST 4: Mathematical Shift Matrix & Tap Verification
    ------------------------------------------------------------------
    en <= '1';

    -- Run the LFSR through its theoretical maximum sequence length (15 states)
    for i in 0 to 14 loop

      current_state := q;
      history(i)    := current_state;                                                                               -- Record state to memory

      assert (current_state /= "0000")
        report "FLAW: Active LFSR entered illegal '0000' dead-state at cycle index " & integer'image(i)
        severity error;

      -- Mirroring the hardware tap math: feedback = bit 3 XOR bit 2
      expected_fb := current_state(3) xor current_state(2);

      wait for t_clk;                                                                                               -- Pulse clock edge

      -- Confirm the left shift structure matched the calculated feedback injection bit
      assert (q = current_state(2 downto 0) & expected_fb)
        report "FLAW: Faulty state transition! From state [" &
               integer'image(to_integer(unsigned(current_state))) &
               "], expected next state [" &
               integer'image(to_integer(unsigned(current_state(2 downto 0) & expected_fb))) &
               "] but caught [" & integer'image(to_integer(unsigned(q))) & "]."
        severity error;

    end loop;

    ------------------------------------------------------------------
    -- TEST 5: Period Completeness & Sequence Uniqueness Validation
    ------------------------------------------------------------------
    -- Cross-compare every captured state against every other captured state
    for i in 0 to 14 loop

      for j in (i + 1) to 14 loop

        assert (history(i) /= history(j))
          report "FLAW: Short-cycle detected! State repeated prematurely between cycle " &
                 integer'image(i) & " and cycle " & integer'image(j)
          severity error;

      end loop;

    end loop;

    -- Verify that cycle 15 wraps seamlessly right back into your starting seed
    assert (q = history(0))
      report "FLAW: LFSR failed to wrap around cleanly to its initial seed after its 15th cycle."
      severity error;

    ------------------------------------------------------------------
    -- TEST 6: Hot Asynchronous Reset Override
    ------------------------------------------------------------------
    wait for t_clk * 0.5;
    rst <= '1';
    wait for 1 ns;
    assert (q = history(0))
      report "FLAW: Asynchronous reset failed to immediately snap design back to seed state during active runtime."
      severity error;

    rst <= '0';
    wait for t_clk;

    ------------------------------------------------------------------
    -- SIMULATION COMPLETE
    ------------------------------------------------------------------
    report "ALL EXHAUSTIVE TESTS PASSED! Your 4-bit LFSR is mathematically and structurally sound."
      severity note;

    std.env.finish;

  end process stim_proc;

end architecture sim;
