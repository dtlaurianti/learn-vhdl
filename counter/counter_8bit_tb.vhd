library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity counter_8bit_tb is
end entity counter_8bit_tb;

architecture sim of counter_8bit_tb is

  signal r_clk : std_logic;
  signal r_rst : std_logic;
  signal r_en  : std_logic;

  signal w_q : std_logic_vector(7 downto 0);

  constant clk_period : time := 10 ns;

begin

  uut : entity work.counter_8bit
    port map (
      clk => r_clk,
      rst => r_rst,
      en  => r_en,
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
      r_en  <= '0';
      wait for clk_period;
      r_rst <= '0';
      wait for clk_period;

    end procedure baseline;

    procedure test_counting is
    begin

      baseline;
      r_en <= '1';
      wait for clk_period * 5;

      assert (w_q = std_logic_vector(to_unsigned(5, 8)))
        report "FAIL: counter did not reach 5 after 5 cycles!"
        severity failure;

    end procedure test_counting;

    procedure test_enable_isolation is
    begin

      baseline;
      r_en <= '1';
      wait for clk_period * 5;

      assert (w_q = std_logic_vector(to_unsigned(5, 8)))
        report "FAIL: counter did not reach 5 after 5 cycles!"
        severity failure;

      r_en <= '0';
      wait for clk_period * 5;

      assert (w_q = std_logic_vector(to_unsigned(5, 8)))
        report "FAIL: counter changed while en was low!"
        severity failure;

    end procedure test_enable_isolation;

    procedure test_rollover is
    begin

      baseline;
      r_en <= '1';
      wait for clk_period * 256;

      assert (w_q = "00000000")
        report "FAIL: counter did not roll over to 0!"
        severity failure;

    end procedure test_rollover;

  begin

    test_counting;
    test_enable_isolation;
    test_rollover;

    report ">>> counter_8bit_tb all tests passed! <<<"
      severity note;
    std.env.finish;

  end process stim_proc;

end architecture sim;
