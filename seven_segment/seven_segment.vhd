library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity seven_segment is
  port (
    val : in    std_logic_vector(3 downto 0);
    seg : out   std_logic_vector(6 downto 0)
  );
end entity seven_segment;

architecture rtl of seven_segment is

  constant a : integer := 10;
  constant b : integer := 11;
  constant c : integer := 12;
  constant d : integer := 13;
  constant e : integer := 14;
  constant f : integer := 15;

  type t_seg_lut is array (0 to 15) of std_logic_vector(seg'length - 1 downto 0);

  constant seg_lut : t_seg_lut :=
  (
    0      => "1111110",
    1      => "0110000",
    2      => "1101101",
    3      => "1111001",
    4      => "0110011",
    5      => "1011011",
    6      => "1011111",
    7      => "1110000",
    8      => "1111111",
    9      => "1111011",
    a      => "1110111",
    b      => "0011111",
    c      => "1001110",
    d      => "0111101",
    e      => "1001111",
    f      => "1000111",
    others => "0000000"
  );

begin

  seg <= seg_lut(to_integer(unsigned(val)));

end architecture rtl;