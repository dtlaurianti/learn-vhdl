library ieee;
  use ieee.std_logic_1164.all;

entity jk_flip_flop_tb is
-- Testbench entities are always empty
end entity jk_flip_flop_tb;

architecture sim of jk_flip_flop_tb is

  -- 1. Declare the Unit Under Test (UUT)
  component jk_flip_flop is
    port (
      clk : in    std_logic;
      j   : in    std_logic;
      k   : in    std_logic;
      q   : out   std_logic
    );
  end component jk_flip_flop;

  -- 2. Testbench Signals
  signal clk : std_logic := '0';
  signal j   : std_logic := '0';
  signal k   : std_logic := '0';
  signal q   : std_logic;

  -- Define clock speed (100 MHz)
  constant clk_period : time := 10 ns;

begin

  -- 3. Instantiate your design
  uut : component jk_flip_flop
    port map (
      clk => clk,
      j   => j,
      k   => k,
      q   => q
    );

  -- 4. Generate the Clock
  clk_process : process is
  begin

    clk <= '0';
    wait for clk_period / 2;
    clk <= '1';
    wait for clk_period / 2;

  end process clk_process;

  -- 5. The Brutal Stimulus & Verification Process
  stim_proc : process is
  begin

    -- Give the simulation a moment to settle
    wait for 5 ns;

    ------------------------------------------------------------------
    -- PHASE 1: Initialization & Reset
    ------------------------------------------------------------------
    -- A real FF starts in an unknown state ('U'). Let's force a reset.
    j <= '0';
    k <= '1';
    wait for clk_period;
    assert (q = '0')
      report "FAILED: Reset state (J=0, K=1) did not force Q to '0'."
      severity error;

    ------------------------------------------------------------------
    -- PHASE 2: The Hold State (from 0)
    ------------------------------------------------------------------
    j <= '0';
    k <= '0';
    wait for clk_period;
    assert (q = '0')
      report "FAILED: Hold state (J=0, K=0) failed to hold the '0'."
      severity error;

    ------------------------------------------------------------------
    -- PHASE 3: The Set State
    ------------------------------------------------------------------
    j <= '1';
    k <= '0';
    wait for clk_period;
    assert (q = '1')
      report "FAILED: Set state (J=1, K=0) did not force Q to '1'."
      severity error;

    ------------------------------------------------------------------
    -- PHASE 4: The Hold State (from 1)
    ------------------------------------------------------------------
    j <= '0';
    k <= '0';
    wait for clk_period;
    assert (q = '1')
      report "FAILED: Hold state (J=0, K=0) failed to hold the '1'."
      severity error;

    ------------------------------------------------------------------
    -- PHASE 5: The Toggle State (1 -> 0)
    ------------------------------------------------------------------
    j <= '1';
    k <= '1';
    wait for clk_period;
    assert (q = '0')
      report "FAILED: Toggle state (J=1, K=1) failed to flip Q from '1' to '0'."
      severity error;

    ------------------------------------------------------------------
    -- PHASE 6: The Toggle State (0 -> 1)
    ------------------------------------------------------------------
    -- Leave J=1, K=1 active for one more clock cycle
    wait for clk_period;
    assert (q = '1')
      report "FAILED: Toggle state (J=1, K=1) failed to flip Q from '0' to '1'."
      severity error;

    ------------------------------------------------------------------
    -- PHASE 7: Asynchronous Glitch Immunity
    ------------------------------------------------------------------
    -- Start with a known Set state
    j <= '1';
    k <= '0';
    wait for clk_period;

    -- Now, violently change J and K while the clock is low (between edges)
    wait for clk_period / 4;
    j <= '0';
    k <= '1'; -- Try to reset it asynchronously
    wait for 1 ns;
    assert (q = '1')
      report "FAILED: Your FF is reacting asynchronously! It changed state without a clock edge."
      severity error;

    -- Settle back to a Set state before the rising edge hits
    j <= '1';
    k <= '0';
    wait for clk_period * 3 / 4;

    ------------------------------------------------------------------
    -- VICTORY
    ------------------------------------------------------------------
    report "All tests completed successfully. Your JK Flip-Flop is structurally sound."
      severity note;

    -- Halt the simulation to prevent an infinite clock loop
    std.env.finish;

  end process stim_proc;

end architecture sim;
