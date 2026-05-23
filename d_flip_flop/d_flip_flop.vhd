library ieee;
  use ieee.std_logic_1164.all;

entity d_flip_flop is
  port (
    clk : in    std_logic;
    rst : in    std_logic;
    d   : in    std_logic;
    q   : out   std_logic
  );
end entity d_flip_flop;

architecture rtl of d_flip_flop is

begin

  process (clk, rst) is
  begin

    if (rst = '1') then
      q <= '0';
    elsif rising_edge(clk) then
      q <= d;
    end if;

  end process;

end architecture rtl;
