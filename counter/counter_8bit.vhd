library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity counter_8bit is
  port (
    clk : in    std_logic;
    rst : in    std_logic;
    en  : in    std_logic;
    q   : out   std_logic_vector(7 downto 0)
  );
end entity counter_8bit;

architecture rtl of counter_8bit is

  signal r_cnt : unsigned(7 downto 0);

begin

  process (clk, rst) is
  begin

    if (rst = '1') then
      r_cnt <= (others => '0');
    elsif rising_edge(clk) then
      if (en = '1') then
        r_cnt <= r_cnt + 1;
      end if;
    end if;

  end process;

  q <= std_logic_vector(r_cnt);

end architecture rtl;
