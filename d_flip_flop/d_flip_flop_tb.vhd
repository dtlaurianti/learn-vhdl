library ieee;
  use ieee.std_logic_1164.all;

entity d_flip_flop_tb is
end entity d_flip_flop_tb;

architecture sim of d_flip_flop_tb is

  signal   r_clk      : std_logic;
  signal   r_rst      : std_logic;
  signal   r_d        : std_logic;
  signal   w_q        : std_logic;
  constant clk_period : time := 10 ns;

begin

  uut : entity work.d_flip_flop
    port map (
      clk => r_clk,
      rst => r_rst,
      d   => r_d,
      q   => w_q
    );

  clk_proc : process is
  begin

    r_clk <= '0';
    wait for clk_period / 2;
    r_clk <= '1';
    wait for clk_period / 2;

  end process clk_proc;

  stim_proc : process is

    procedure baseline is
    begin

      r_rst <= '1';
      r_d   <= '0';
      wait for CLK_PERIOD;
      r_rst <= '0';
      wait for CLK_PERIOD;

    end procedure baseline;

    procedure test_async_reset is
    begin

      baseline;
      r_rst <= '1';
      r_d   <= '1';
      wait for 2 ns;
      assert (w_q = '0')
        report "FAIL: q should be 0 while rst 1!"
        severity failure;

    end procedure test_async_reset;

    procedure test_clock_edge_capture is
    begin

      baseline;
      r_rst <= '0';
      r_d   <= '1';
      wait until rising_edge(r_clk);
      wait for 1 ns;
      assert (w_q = '1')
        report "FAIL: q failed to capture d on rising edge!"
        severity failure;

    end procedure test_clock_edge_capture;

    procedure test_mid_cycle_isolation is
    begin

      baseline;
      r_rst <= '0';
      r_d   <= '1';
      wait until rising_edge(r_clk);
      wait for 1 ns;
      assert (w_q = '1')
        report "FAIL: q failed to capture d on rising edge!"
        severity failure;
      r_d   <= '0';
      wait for 1 ns;
      assert (w_q = '1')
        report "FAIL: q changed mid-cycle!"
        severity failure;

    end procedure test_mid_cycle_isolation;

  begin

    test_async_reset;
    test_clock_edge_capture;
    test_mid_cycle_isolation;

    report ">>> d_flip_flop_tb all tests passed! <<<"
      severity note;
    std.env.finish;

  end process stim_proc;

end architecture sim;

