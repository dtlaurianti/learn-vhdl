library ieee;
  use ieee.std_logic_1164.all;

entity ripple_adder_tb is
end entity ripple_adder_tb;

architecture sim of ripple_adder_tb is

  signal r_x   : std_logic_vector(3 downto 0);
  signal r_y   : std_logic_vector(3 downto 0);
  signal r_cin : std_logic := '0';

  signal w_sum  : std_logic_vector(3 downto 0);
  signal w_cout : std_logic;

begin

  uut : entity work.ripple_adder
    port map (
      x    => r_x,
      y    => r_y,
      cin  => r_cin,
      sum  => w_sum,
      cout => w_cout
    );

  stim_proc : process is
  begin

    r_x   <= "0000";
    r_y   <= "0000";
    r_cin <= '0';
    wait for 10 ns;

    r_x   <= "0100"; -- 4 in binary
    r_y   <= "0011"; -- 3 in binary
    r_cin <= '0';
    wait for 10 ns;

    r_x   <= "1100"; -- 12 in binary
    r_y   <= "0101"; -- 5 in binary
    r_cin <= '0';
    wait for 10 ns;

    r_x   <= "1111"; -- 15
    r_y   <= "0001"; -- 1
    r_cin <= '0';
    wait for 10 ns;

    wait for 10 ns;
    wait;

  end process stim_proc;

end architecture sim;

