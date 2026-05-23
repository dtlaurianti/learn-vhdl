library ieee;
  use ieee.std_logic_1164.all;

entity ripple_adder is
  port (
    x    : in    std_logic_vector(3 downto 0);
    y    : in    std_logic_vector(3 downto 0);
    cin  : in    std_logic;
    sum  : out   std_logic_vector(3 downto 0);
    cout : out   std_logic
  );
end entity ripple_adder;

architecture structural of ripple_adder is

  signal c : std_logic_vector(3 downto 1);

begin

  fa0 : entity work.full_adder
    port map (
      a    => x(0),
      b    => y (0),
      cin  => cin,
      sum  => sum(0),
      cout => c(1)
    );

  fa1 : entity work.full_adder
    port map (
      a    => x(1),
      b    => y (1),
      cin  => c(1),
      sum  => sum(1),
      cout => c(2)
    );

  fa2 : entity work.full_adder
    port map (
      a    => x(2),
      b    => y (2),
      cin  => c(2),
      sum  => sum(2),
      cout => c(3)
    );

  fa3 : entity work.full_adder
    port map (
      a    => x(3),
      b    => y (3),
      cin  => c(3),
      sum  => sum(3),
      cout => cout
    );

end architecture structural;
