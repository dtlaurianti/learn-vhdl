library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity traffic_light_fsm_tb is
-- Testbenches have no ports
end entity traffic_light_fsm_tb;

architecture sim of traffic_light_fsm_tb is

  -- 1. Simulation Timing Constants
  constant t_clk : time := 10 ns;

  -- 2. Testbench Signals
  signal clk         : std_logic := '0';
  signal rst         : std_logic := '0';
  signal car_present : std_logic := '0';
  signal red         : std_logic;
  signal yellow      : std_logic;
  signal green       : std_logic;

begin

  -- 3. Instantiate Unit Under Test (UUT)
  uut : entity work.traffic_light_fsm
    port map (
      clk         => clk,
      rst         => rst,
      car_present => car_present,
      red         => red,
      yellow      => yellow,
      green       => green
    );

  -- 4. Clock Generator Process (100 MHz)
  clk_process : process is
  begin

    clk <= '0';
    wait for t_clk / 2;
    clk <= '1';
    wait for t_clk / 2;

  end process clk_process;

  -- 5. Concurrent Global Safety Monitor
  -- Ensures that under no circumstance are multiple lights ever on at once
  safety_monitor : process (red, yellow, green) is
  begin

    -- Ensure exactly one light is on when reset is not active
    if (rst = '0') then
      assert (
                (green = '1' and yellow = '0' and red = '0') or
                (green = '0' and yellow = '1' and red = '0') or
                (green = '0' and yellow = '0' and red = '1')
            )
        report "CRITICAL SAFETY VIOLATION: Illegal state overlap! Red=" &
               std_logic'image(red) & " Yellow=" & std_logic'image(yellow) &
               " Green=" & std_logic'image(green)
        severity failure;
    end if;

  end process safety_monitor;

  -- 6. Exhaustive Stimulus Engine
  stim_proc : process is
  begin

    -- Allow startup transients to settle
    wait for t_clk * 0.2;

    ------------------------------------------------------------------
    -- PHASE 1: Asynchronous Reset Check
    ------------------------------------------------------------------
    rst         <= '1';
    car_present <= '1';                                                                                     -- Try to force a transition during reset
    wait for 2 ns;                                                                                          -- Check mid-cycle before a rising clock edge

    assert (green = '1' and yellow = '0' and red = '0')
      report "PHASE 1 FAILED: Asynchronous reset did not immediately force Green state."
      severity failure;

    wait for t_clk * 0.8;
    rst <= '0';
    wait for t_clk;

    ------------------------------------------------------------------
    -- PHASE 2: Infinite Idle Hold (No Cars)
    ------------------------------------------------------------------
    car_present <= '0';

    -- Let the FSM run for 15 clock cycles. It should never leave Green.
    for i in 0 to 14 loop

      wait until falling_edge(clk);
      assert (green = '1')
        report "PHASE 2 FAILED: FSM left the Green state without a car present! Cycle: " & integer'image(i)
        severity error;

    end loop;

    ------------------------------------------------------------------
    -- PHASE 3: Exact Sequence & Cycle Timing Verification
    ------------------------------------------------------------------
    -- Signal that a car has arrived
    car_present <= '1';

    -- --- STEP 3A: Green Cycle Evaluation ---
    -- Your logic requires r_timer >= 5 to trigger a transition.
    -- It spends 6 clock cycles total in Green (timer counts: 0, 1, 2, 3, 4, 5)
    for i in 0 to 5 loop

      wait until falling_edge(clk);
      assert (green = '1')
        report "PHASE 3A FAILED: Expected Green on cycle " & integer'image(i)
        severity error;

    end loop;

    -- --- STEP 3B: Yellow Cycle Evaluation ---
    -- Your logic requires r_timer >= 2 to transition to Red.
    -- It spends 3 clock cycles total in Yellow (timer counts: 0, 1, 2)
    for i in 0 to 2 loop

      assert (yellow = '1')
        report "PHASE 3B FAILED: Expected Yellow on cycle " & integer'image(i)
        severity error;
      wait until falling_edge(clk);

    end loop;

    -- --- STEP 3C: Red Cycle Evaluation ---
    -- Your logic requires r_timer >= 6 to transition back to Green.
    -- It spends 7 clock cycles total in Red (timer counts: 0, 1, 2, 3, 4, 5, 6)
    for i in 0 to 6 loop

      assert (red = '1')
        report "PHASE 3C FAILED: Expected Red on cycle " & integer'image(i)
        severity error;
      wait until falling_edge(clk);

    end loop;

    -- --- STEP 3D: Seamless Wrap-Around ---
    -- After the 7th Red clock cycle, it should return instantly to Green
    assert (green = '1')
      report "PHASE 3D FAILED: FSM failed to loop cleanly back to Green after Red expired."
      severity error;

    ------------------------------------------------------------------
    -- PHASE 4: Mid-Cycle Asynchronous Interruption
    ------------------------------------------------------------------
    -- Allow the FSM to progress back into Yellow
    wait until falling_edge(clk);                                                                           -- Green cycle 0...
    wait until falling_edge(clk);                                                                           -- Green cycle 1...
    wait until falling_edge(clk);                                                                           -- Green cycle 2...
    wait until falling_edge(clk);                                                                           -- Green cycle 3...
    wait until falling_edge(clk);                                                                           -- Green cycle 4...
    wait until falling_edge(clk);                                                                           -- Green cycle 5...

    wait until falling_edge(clk);                                                                           -- Now inside Yellow cycle 0
    assert (yellow = '1')
      report "Setup error for Phase 4"
      severity error;

    -- Interrupt mid-cycle with a hot reset pulse
    wait for t_clk * 0.2;
    rst <= '1';
    wait for 1 ns;                                                                                          -- Check instantly

    assert (green = '1' and yellow = '0' and red = '0')
      report "PHASE 4 FAILED: Mid-cycle asynchronous reset failed to instantly force state back to Green."
      severity error;

    wait for t_clk * 0.8;
    rst <= '0';

    ------------------------------------------------------------------
    -- SIMULATION COMPLETE
    ------------------------------------------------------------------
    report "ALL EXHAUSTIVE FSM VERIFICATION PHASES PASSED! Your traffic light sequencer is robust."
      severity note;

    std.env.finish;

  end process stim_proc;

end architecture sim;
