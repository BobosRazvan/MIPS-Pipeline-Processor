
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use ieee.numeric_std.all;  
use ieee.std_logic_unsigned.all;


entity REG_FILE is
port (
clk : in std_logic;
ra1 : in std_logic_vector (2 downto 0);
ra2 : in std_logic_vector (2 downto 0);
wa : in std_logic_vector (2 downto 0);
wd : in std_logic_vector (15 downto 0);
wen : in std_logic;
rd1 : out std_logic_vector (15 downto 0);
rd2 : out std_logic_vector (15 downto 0)
);
end REG_FILE;
architecture Behavioral of REG_FILE is
type reg_array is array (0 to 7) of std_logic_vector(15 downto 0);
signal reg_file : reg_array := (
 
  0 => x"1A2C",
  1 => x"6892",
  2 => x"3421",
  3 => x"2231",
  4 => x"AAAA",
  5 => x"1234",
 
  others => x"ABCD"  
);

begin
process(clk)
begin
if rising_edge(clk) then
if wen = '1' then
reg_file(conv_integer(wa)) <= wd;
end if;
end if;
end process;
rd1 <= reg_file(conv_integer(ra1));
rd2 <= reg_file(conv_integer(ra2));
end Behavioral;