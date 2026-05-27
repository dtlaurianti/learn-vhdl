library ieee;
  use ieee.std_logic_1164.all;

entity jk_flip_flop is
  port (
    clk : in    std_logic;
    j   : in    std_logic;
    k   : in    std_logic;
    q   : out   std_logic
  );
end entity jk_flip_flop;

architecture rtl of jk_flip_flop is

begin

  process (clk) is
  begin

    if rising_edge(clk) then

      case (j & k) is

        when "00" =>

          q <= q;

        when "01" =>

          q <= '0';

        when "10" =>

          q <= '1';

        when "11" =>

          q <= not q;

        when others =>

          q <= '0';

      end case;

    end if;

  end process;

end architecture rtl;
