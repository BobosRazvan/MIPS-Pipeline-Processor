
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Instruction_Fetch is
	Port (  WE : in std_logic;
			reset : in std_logic;
			clk: in std_logic;
			BranchAdress : in std_logic_vector(15 downto 0);
			JumpAddress : in std_logic_vector(15 downto 0);
			jump : in std_logic;
			PCSrc : in std_logic;
			Instruction : out std_logic_vector(15 downto 0);
			PCOut : out std_logic_vector(15 downto 0):=X"0000");
end Instruction_Fetch;

architecture Behavioral of Instruction_Fetch is

type rom_type is array(0 to 255) of std_logic_vector(15 downto 0);
signal ROM: rom_type := (
		
        B"000_001_010_011_0_000", -- add $3,$1,$2  (0530) 
        B"000_000_000_000_0_000", -- no-op
        B"000_000_000_000_0_000", -- no-op
        B"000_011_010_100_0_001", -- sub $4,$3,$2  (0D41)   $3 cu hazard
        B"001_000_001_0000010",   -- addi $1,$0,2  (2082) 
        B"000_000_000_000_0_000", -- no-op
        B"000_100_011_111_0_111", -- slt $7,$4,$3  (11F7)  $4 cu hazard
        B"000_000_000_000_0_000", -- no-op
        B"000_000_000_000_0_000", -- no-op
        B"000_110_110_111_1_010", -- sll  $6,$7,1  (167A)  --aici pun no op cu toate ca nu trebuie
        B"000_000_000_000_0_000", -- no-op
        B"000_000_000_000_0_000", -- no-op
        B"000_110_110_111_1_011", -- srl  $6,$7,1  (167B)
        B"000_000_000_000_0_000", -- no-op
        B"000_000_000_000_0_000", -- no-op
        B"000_110_100_111_0_100", -- and $6,$4,$7  (1A74)
        B"000_000_000_000_0_000", -- no-op
        B"000_000_000_000_0_000", -- no-op
        B"000_110_100_111_0_101", -- or  $6,$4,$7  (1A75)    
        B"000_000_000_000_0_000", -- no-op
        B"000_000_000_000_0_000", -- no-op
        B"000_110_100_111_0_110", -- xor $6,$4,$7  (1A76)
        B"111_0000000000010",     -- j 2           (E003) 
        B"000_000_000_000_0_000", -- no-op (flush instruction after jump)
        B"000_000_000_000_0_000", -- no-op (flush instruction after jump)

    others => X"0000");



signal PC: std_logic_vector(15 downto 0) :=X"0000";
signal PC1: std_logic_vector(15 downto 0) :=X"0000";
signal MUX1Out: std_logic_vector(15 downto 0) :=X"0000";
signal NextAdress: std_logic_vector(15 downto 0) :=X"0000";

begin


process(jump,MUX1Out,JumpAddress)
begin
	case(jump) is
		when '0' => NextAdress <= MUX1Out;
		when '1' => NextAdress <= JumpAddress;
		when others => NextAdress <= X"0000";
	end case;
end process;	

process(PCSrc,PC1,BranchAdress)
begin
	case (PCSrc) is 
		when '0' => MUX1Out <= PC1;
		when '1' => MUX1Out<=BranchAdress;
		when others => MUX1Out<=X"0000";
	end case;
end process;	


process(clk,reset)
begin
	if reset='1' then
		PC<=X"0000";
	else if rising_edge(clk) and WE='1' then
		PC<=NextAdress;
		end if;
		end if;
end process;

Instruction<=ROM(conv_integer(PC(7 downto 0)));

PC1<=PC + '1';

PCOut <= PC1;


end Behavioral;

