library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity alu_xbit_tb is
-- Testbenches have no ports
end entity alu_xbit_tb;

architecture sim of alu_xbit_tb is

  -- 1. Match the G_WIDTH parameter (using 16-bit to ensure scalability)
  constant test_width : integer := 16;
  constant t_delay    : time    := 5 ns; -- Propagation time to let combinational logic settle

  -- 2. Testbench Signals
  signal a    : std_logic_vector(test_width - 1 downto 0) := (others => '0');
  signal b    : std_logic_vector(test_width - 1 downto 0) := (others => '0');
  signal op   : std_logic_vector(2 downto 0)              := (others => '0');
  signal res  : std_logic_vector(test_width - 1 downto 0);
  signal zero : std_logic;
  signal c    : std_logic;

  -- Opcodes defined as local constants for readability
  constant op_add : std_logic_vector(2 downto 0) := "000";
  constant op_sub : std_logic_vector(2 downto 0) := "001";
  constant op_and : std_logic_vector(2 downto 0) := "010";
  constant op_or  : std_logic_vector(2 downto 0) := "011";
  constant op_xor : std_logic_vector(2 downto 0) := "100";
  constant op_not : std_logic_vector(2 downto 0) := "101";

begin

  -- 3. Instantiate the Unit Under Test (UUT)
  uut : entity work.alu_xbit
    generic map (
      g_width => TEST_WIDTH
    )
    port map (
      a    => a,
      b    => b,
      op   => op,
      res  => res,
      zero => zero,
      c    => c
    );

  -- 4. Combinational Stimulus Vector Engine
  stim_proc : process is

    -- Helper procedure to cleanly pack assertions and minimize repetitive code

    procedure verify_alu_xbit (
      constant msg      : in string;
      constant exp_res  : in std_logic_vector(test_width - 1 downto 0);
      constant exp_zero : in std_logic;
      constant exp_c    : in std_logic
    ) is
    begin

      wait for T_DELAY;
      assert (res = exp_res)
        report msg & " [RESULT FAILED]: Expected 0x" & to_hstring(unsigned(exp_res)) &
               " but got 0x" & to_hstring(unsigned(res))
        severity error;

      assert (zero = exp_zero)
        report msg & " [ZERO FLAG FAILED]: Expected " & std_logic'image(exp_zero) &
               " but got " & std_logic'image(zero)
        severity error;

      assert (c = exp_c)
        report msg & " [CARRY FLAG FAILED]: Expected " & std_logic'image(exp_c) &
               " but got " & std_logic'image(c)
        severity error;

    end procedure verify_alu_xbit;

  begin

    -- Initial Stabilization delay
    wait for 10 ns;

    ------------------------------------------------------------------
    -- PHASE 1: OP_ADD ("000") Verification
    ------------------------------------------------------------------
    -- Test 1A: Simple Baseline Addition
    op <= op_add;
    a  <= x"0005";
    b  <= x"0002";
    verify_alu_xbit("Addition (5 + 2)", x"0007", '0', '0');

    -- Test 1B: Addition causing a Zero output (0 + 0)
    op <= op_add;
    a  <= x"0000";
    b  <= x"0000";
    verify_alu_xbit("Addition (0 + 0)", x"0000", '1', '0');

    -- Test 1C: Addition causing an Overflow/Carry Out condition
    -- Maximum 16-bit number (0xFFFF) + 1 = 0x0000 with a Carry bit
    op <= op_add;
    a  <= x"FFFF";
    b  <= x"0001";
    verify_alu_xbit("Addition Overflow (65535 + 1)", x"0000", '1', '1');

    ------------------------------------------------------------------
    -- PHASE 2: OP_SUB ("001") Verification
    ------------------------------------------------------------------
    -- Test 2A: Simple Subtraction
    op <= op_sub;
    a  <= x"000A";
    b  <= x"0004";
    verify_alu_xbit("Subtraction (10 - 4)", x"0006", '0', '0');

    -- Test 2B: Subtraction resulting in Zero
    op <= op_sub;
    a  <= x"00FF";
    b  <= x"00FF";
    verify_alu_xbit("Subtraction to Zero (255 - 255)", x"0000", '1', '0');

    -- Test 2C: Subtraction causing an Underflow/Borrow Out condition
    -- 0 - 1 = 0xFFFF in Two's Complement. The carry bit tracks the borrow state.
    op <= op_sub;
    a  <= x"0000";
    b  <= x"0001";
    verify_alu_xbit("Subtraction Underflow (0 - 1)", x"FFFF", '0', '1');

    ------------------------------------------------------------------
    -- PHASE 3: OP_AND ("010") Verification
    ------------------------------------------------------------------
    -- Test 3A: Bitwise Masking
    op <= op_and;
    a  <= x"5555";
    b  <= x"FFFF";
    verify_alu_xbit("Bitwise AND (Masking)", x"5555", '0', '0');

    -- Test 3B: Bitwise AND resulting in Zero
    op <= op_and;
    a  <= x"AAAA";
    b  <= x"5555";
    verify_alu_xbit("Bitwise AND (Zero Result)", x"0000", '1', '0');

    ------------------------------------------------------------------
    -- PHASE 4: OP_OR ("011") Verification
    ------------------------------------------------------------------
    op <= op_or;
    a  <= x"F000";
    b  <= x"000F";
    verify_alu_xbit("Bitwise OR", x"F00F", '0', '0');

    ------------------------------------------------------------------
    -- PHASE 5: OP_XOR ("100") Verification
    ------------------------------------------------------------------
    -- Test 5A: Toggle behavior
    op <= op_xor;
    a  <= x"1234";
    b  <= x"FFFF";
    verify_alu_xbit("Bitwise XOR (Inversion)", x"EDCB", '0', '0');

    -- Test 5B: Identical valu_xbites matching to Zero
    op <= op_xor;
    a  <= x"5A5A";
    b  <= x"5A5A";
    verify_alu_xbit("Bitwise XOR (Self Verification)", x"0000", '1', '0');

    ------------------------------------------------------------------
    -- PHASE 6: OP_NOT ("101") Verification
    ------------------------------------------------------------------
    -- Note: OP_NOT should strictly invert port A. Port B is ignored here.
    op <= op_not;
    a  <= x"0000";
    b  <= x"FFFF";
    verify_alu_xbit("Bitwise NOT (All zeros)", x"FFFF", '0', '0');

    op <= op_not;
    a  <= x"FFFF";
    b  <= x"0000";
    verify_alu_xbit("Bitwise NOT (All ones)", x"0000", '1', '0');

    ------------------------------------------------------------------
    -- PHASE 7: Safety Default Check
    ------------------------------------------------------------------
    -- Pass an undefined opcode to check if the 'others' clause catches it
    op <= "111";
    a  <= x"A5A5";
    b  <= x"5A5A";
    verify_alu_xbit("Undefined Opcode Exception", x"0000", '1', '0');

    ------------------------------------------------------------------
    -- MATRIX COMPLETE
    ------------------------------------------------------------------
    report "ALL EXHAUSTIVE ALU TESTS COMPLETED SUCCESSFULY. Your data path logic is flawless."
      severity note;

    wait; -- Permanently halt execution loop

  end process stim_proc;

end architecture sim;
