library ieee;
  use ieee.std_logic_1164.all;

entity mux4to1 is
  port (
    d0  : in    std_logic;
    d1  : in    std_logic;
    d2  : in    std_logic;
    d3  : in    std_logic;
    sel : in    std_logic_vector(1 downto 0);
    q   : out   std_logic
  );
end entity mux4to1;

architecture rtl of mux4to1 is

begin

  with sel select q <=
    d0 when "00",
    d1 when "01",
    d2 when "10",
    d3 when "11",
    '0' when others;

end architecture rtl;
