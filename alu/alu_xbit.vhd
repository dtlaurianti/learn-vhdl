library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity alu_xbit is
  generic (
    g_width : integer := 8
  );
  port (
    a    : in    std_logic_vector(g_width - 1 downto 0);
    b    : in    std_logic_vector(g_width - 1 downto 0);
    op   : in    std_logic_vector(2 downto 0);
    res  : out   std_logic_vector(g_width - 1 downto 0);
    zero : out   std_logic;
    c    : out   std_logic
  );
end entity alu_xbit;

architecture rtl of alu_xbit is

  signal r_res : std_logic_vector(g_width - 1 downto 0) := (others => '0');

  constant op_add : std_logic_vector(2 downto 0) := "000";
  constant op_sub : std_logic_vector(2 downto 0) := "001";
  constant op_and : std_logic_vector(2 downto 0) := "010";
  constant op_or  : std_logic_vector(2 downto 0) := "011";
  constant op_xor : std_logic_vector(2 downto 0) := "100";
  constant op_not : std_logic_vector(2 downto 0) := "101";

begin

  process (a, b, op) is

    variable v_sum_ext : std_logic_vector(g_width downto 0);

  begin

    r_res <= (others => '0');
    c     <= '0';

    case op is

      when op_add =>

        v_sum_ext := std_logic_vector(resize(unsigned(a), g_width + 1) + resize(unsigned(b), g_width + 1));
        r_res     <= v_sum_ext(g_width - 1 downto 0);
        c         <= v_sum_ext(g_width);

      when op_sub =>

        v_sum_ext := std_logic_vector(resize(unsigned(a), g_width + 1) - resize(unsigned(b), g_width + 1));
        r_res     <= v_sum_ext(g_width - 1 downto 0);
        c         <= v_sum_ext(g_width);

      when op_and =>

        r_res <= a and b;

      when op_or =>

        r_res <= a or b;

      when op_xor =>

        r_res <= a xor b;

      when op_not =>

        r_res <= not a;

      when others =>

        r_res <= (others => '0');

    end case;

  end process;

  res <= r_res;

  zero <= '1' when unsigned(r_res) = 0 else
          '0';

end architecture rtl;
