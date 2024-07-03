library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Memory_Unit is
	port(
			clk: in std_logic;--
			ALURes : in std_logic_vector(15 downto 0);
			WriteData: in std_logic_vector(15 downto 0);
			MemWrite: in std_logic;			
			MemData:out std_logic_vector(15 downto 0);--
			ALUFinal :out std_logic_vector(15 downto 0)--
	);
end Memory_Unit;

architecture Behavioral of Memory_unit is

signal Address: std_logic_vector(3 downto 0);

type ram_type is array (0 to 15) of std_logic_vector(15 downto 0);
signal RAM:ram_type:=(
		X"0001",
		X"0002",
		X"0003",
		X"0004",
		X"0005",
		X"0006",
		X"0007",
		X"0008",
		
		others =>X"0009");

begin

Address<=ALURes(3 downto 0);


process(clk) 			
begin
	if(rising_edge(clk)) then
			if MemWrite='1' then
				RAM(conv_integer(Address))<=WriteData;			
			end if;
	end if;	
	MemData<=RAM(conv_integer(Address));
end process;

	
ALUFinal<=ALURes;		

end Behavioral;


