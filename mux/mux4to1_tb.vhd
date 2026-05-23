library ieee;
  use ieee.std_logic_1164.all;

entity mux4to1_tb is
end entity mux4to1_tb;

architecture sim of mux4to1_tb is

  signal r_d0  : std_logic := '1';
  signal r_d1  : std_logic := '0';
  signal r_d2  : std_logic := '1';
  signal r_d3  : std_logic := '0';
  signal r_sel : std_logic_vector(1 downto 0);
  signal w_q   : std_logic;

begin

  uut : entity work.mux4to1
    port map (
      d0  => r_d0,
      d1  => r_d1,
      d2  => r_d2,
      d3  => r_d3,
      sel => r_sel,
      q   => w_q
    );

  stim_proc : process is
  begin

    r_sel <= "00";
    wait for 10 ns;
    r_sel <= "01";
    wait for 10 ns;
    r_sel <= "10";
    wait for 10 ns;
    r_sel <= "11";
    wait for 10 ns;
    wait;

  end process stim_proc;

end architecture sim;

