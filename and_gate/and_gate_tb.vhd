library ieee;
  use ieee.std_logic_1164.all;

entity and_gate_tb is
end entity and_gate_tb;

architecture sim of and_gate_tb is

  signal r_a : std_logic;
  signal r_b : std_logic;
  signal w_c : std_logic;

begin

  uut : entity work.and_gate
    port map (
      a => r_a,
      b => r_b,
      c => w_c
    );

  stim_proc : process is
  begin

    r_a <= '0';
    r_b <= '0';
    wait for 10 ns;
    r_a <= '1';
    r_b <= '0';
    wait for 10 ns;
    r_a <= '1';
    r_b <= '1';
    wait for 10 ns;
    wait;

  end process stim_proc;

end architecture sim;

