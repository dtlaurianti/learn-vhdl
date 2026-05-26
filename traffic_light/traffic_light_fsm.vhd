library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity traffic_light_fsm is
  port (
    clk         : in    std_logic;
    rst         : in    std_logic;
    car_present : in    std_logic;
    red         : out   std_logic := '0';
    yellow      : out   std_logic := '0';
    green       : out   std_logic := '1'
  );
end entity traffic_light_fsm;

architecture rtl of traffic_light_fsm is

  type t_state is (st_green, st_yellow, st_red);

  signal r_current_state : t_state;
  signal w_next_state    : t_state;

  signal r_timer : unsigned(3 downto 0) := (others => '0');

begin

  seq_proc : process (clk, rst) is
  begin

    if (rst = '1') then
      r_current_state <= st_green;
      r_timer         <= (others => '0');
    elsif rising_edge(clk) then
      if (r_current_state /= w_next_state) then
        r_timer <= (others => '0');
      else
        r_timer <= r_timer + 1;
      end if;

      r_current_state <= w_next_state;
    end if;

  end process seq_proc;

  comb_proc : process (r_current_state, r_timer, car_present) is
  begin

    w_next_state <= r_current_state;
    green        <= '0';
    yellow       <= '0';
    red          <= '0';

    case r_current_state is

      when st_green =>

        green <= '1';

        if (car_present = '1' and r_timer >= 5) then
          w_next_state <= st_yellow;
        end if;

      when st_yellow =>

        yellow <= '1';

        if (r_timer >= 2) then
          w_next_state <= st_red;
        end if;

      when st_red =>

        red <= '1';

        if (r_timer >= 6) then
          w_next_state <= st_green;
        end if;

      when others =>

        w_next_state <= st_green;

    end case;

  end process comb_proc;

end architecture rtl;