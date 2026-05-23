library ieee;
  use ieee.std_logic_1164.all;

entity full_adder_tb is
end entity full_adder_tb;

architecture sim of full_adder_tb is

  signal r_a    : std_logic;
  signal r_b    : std_logic;
  signal r_cin  : std_logic;
  signal w_sum  : std_logic;
  signal w_cout : std_logic;

begin

  uut : entity work.full_adder
    port map (
      a    => r_a,
      b    => r_b,
      cin  => r_cin,
      sum  => w_sum,
      cout => w_cout
    );

  stim_proc : process is
  begin

    r_a   <= '0';
    r_b   <= '0';
    r_cin <= '0';
    wait for 10 ns;
    r_a   <= '1';
    r_b   <= '0';
    r_cin <= '0';
    wait for 10 ns;
    r_a   <= '0';
    r_b   <= '1';
    r_cin <= '0';
    wait for 10 ns;
    r_a   <= '1';
    r_b   <= '1';
    r_cin <= '0';
    wait for 10 ns;
    r_a   <= '0';
    r_b   <= '0';
    r_cin <= '1';
    wait for 10 ns;
    r_a   <= '1';
    r_b   <= '0';
    r_cin <= '1';
    wait for 10 ns;
    r_a   <= '0';
    r_b   <= '1';
    r_cin <= '1';
    wait for 10 ns;
    r_a   <= '1';
    r_b   <= '1';
    r_cin <= '1';
    wait for 10 ns;
    wait;

  end process stim_proc;

end architecture sim;

