library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity uart_8n1_tx is
  generic (
    g_clk_freq  : integer := 100_000_000;
    g_baud_rate : integer := 115_200
  );
  port (
    clk       : in    std_logic;
    rst       : in    std_logic;
    tx_start  : in    std_logic;
    tx_data   : in    std_logic_vector(7 downto 0);
    tx_active : out   std_logic;
    tx_serial : out   std_logic := '1';
    tx_done   : out   std_logic
  );
end entity uart_8n1_tx;

architecture rtl of uart_8n1_tx is

  constant c_clks_per_bit : integer := g_clk_freq / g_baud_rate;

  type t_state is (st_idle, st_start_bit, st_data_bits, st_stop_bit);

  signal r_state     : t_state                                       := st_idle;
  signal r_clk_count : integer range 0 to c_clks_per_bit - 1         := 0;
  signal r_bit_index : integer range 0 to tx_data'length - 1         := 0;
  signal r_tx_data   : std_logic_vector(tx_data'length - 1 downto 0) := (others => '0');

  signal w_bit_done      : std_logic;
  signal w_all_bits_done : std_logic;
  signal w_serial        : std_logic;

begin

  w_bit_done      <= '1' when (r_clk_count = c_clks_per_bit - 1) else
                     '0';
  w_all_bits_done <= '1' when (r_bit_index = tx_data'high and w_bit_done = '1') else
                     '0';

  tx_active <= '0' when r_state = st_idle else
               '1';
  with r_state select w_serial <=
    '0' when st_start_bit,
    r_tx_data(r_bit_index) when st_data_bits,
    '1' when others;

  tx_serial <= '1' when rst = '1' else
               w_serial;

  process (clk, rst) is
  begin

    if (rst = '1') then
      r_state     <= st_idle;
      r_clk_count <= 0;
      r_bit_index <= 0;
      tx_done     <= '0';
    elsif rising_edge(clk) then
      tx_done <= '0';

      if (r_state /= st_idle) then
        if (w_bit_done = '1') then
          r_clk_count <= 0;
        else
          r_clk_count <= r_clk_count + 1;
        end if;
      else
        r_clk_count <= 0;
      end if;

      case r_state is

        when st_idle =>

          r_clk_count <= 0;
          r_bit_index <= 0;

          if (tx_start = '1') then
            r_tx_data <= tx_data;
            r_state   <= st_start_bit;
          end if;

        when st_start_bit =>

          if (w_bit_done = '1') then
            r_state <= st_data_bits;
          end if;

        when st_data_bits =>

          if (w_bit_done = '1') then
            if (w_all_bits_done = '1') then
              r_state <= st_stop_bit;
            else
              r_bit_index <= r_bit_index + 1;
            end if;
          end if;

        when st_stop_bit =>

          if (w_bit_done = '1') then
            tx_done <= '1';
            r_state <= st_idle;
          end if;

      end case;

    end if;

  end process;

end architecture rtl;