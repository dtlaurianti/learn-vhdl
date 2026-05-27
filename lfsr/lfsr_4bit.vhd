library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity lfsr_4bit is
  generic (
    g_tap_mask : std_logic_vector(3 downto 0) := "1100"
  );
  port (
    clk : in    std_logic;
    rst : in    std_logic;
    en  : in    std_logic;
    q   : out   std_logic_vector(3 downto 0)
  );
end entity lfsr_4bit;

architecture rtl of lfsr_4bit is

  constant seed    : std_logic_vector(3 downto 0) := "0001";
  signal   r_state : std_logic_vector(3 downto 0) := seed;

begin

  process (clk, rst) is

    variable v_masked_bits : std_logic_vector(3 downto 0);
    variable v_feedback    : std_logic;

  begin

    if (rst = '1') then
      r_state <= "0001";
    elsif (rising_edge(clk) and (en = '1')) then
      v_masked_bits := r_state and g_tap_mask;
      v_feedback    := xor v_masked_bits;
      r_state       <= r_state(2 downto 0) & v_feedback;
    end if;

  end process;

  q <= r_state;

end architecture rtl;
