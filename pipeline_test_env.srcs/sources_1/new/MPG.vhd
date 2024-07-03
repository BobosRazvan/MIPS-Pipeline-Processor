----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/29/2024 12:46:43 PM
-- Design Name: 
-- Module Name: debouncer - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use ieee.numeric_std.all;  
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MPG is
  Port (btn : in std_logic;
        clk : in std_logic;
        en : out std_logic
         );
end MPG;

architecture Behavioral of MPG is

signal q1 : std_logic := '0';
signal q2 : std_logic := '0';
signal q3 : std_logic := '0';
signal cnt : std_logic_vector(15 downto 0) := (others => '0');

begin

process(clk) 
begin
if rising_edge(clk) then
cnt <= cnt + 1; 
end if;
end process;

process(clk, cnt) 
begin
if rising_edge(clk) then
if cnt = x"FFFF" then 
q1 <= btn;
end if;
end if;
end process;

process(clk) 
begin
if rising_edge(clk) then
q2 <= q1;
end if;
end process;

process(clk) 
begin
if rising_edge(clk) then
q3 <= q2;
end if;
end process;

en <= q2 and (not q3);

end Behavioral;
