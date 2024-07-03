
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity top_level is
    Port ( clk : in  STD_LOGIC;
           btn : in  STD_LOGIC_VECTOR (3 downto 0);
           sw : in  STD_LOGIC_VECTOR (7 downto 0);
           led : out  STD_LOGIC_VECTOR (7 downto 0);
           an : out  STD_LOGIC_VECTOR (3 downto 0);
           cat : out  STD_LOGIC_VECTOR (6 downto 0)
           );
end top_level;

architecture Behavioral of top_level is

component MPG is
  Port (btn : in std_logic;
        clk : in std_logic;
        en : out std_logic
         );
end component;


component SSD is
port( clk: in STD_LOGIC;
		digits: in STD_LOGIC_VECTOR(15 DOWNTO 0);
		an: out STD_LOGIC_VECTOR(3 DOWNTO 0);
		cat: out STD_LOGIC_VECTOR(6 DOWNTO 0));
end component;


component Instruction_Fetch is
	Port (  WE : in std_logic;
			reset : in std_logic;
			clk: in std_logic;
			BranchAdress : in std_logic_vector(15 downto 0);
			JumpAddress : in std_logic_vector(15 downto 0);
			jump : in std_logic;
			PCSrc : in std_logic;
			Instruction : out std_logic_vector(15 downto 0);
			PCOut : out std_logic_vector(15 downto 0):=X"0000");
end component;



component Instruction_Decode is
	Port ( clk: in std_logic;
			Instr: in std_logic_vector(15 downto 0);
			WriteData: in std_logic_vector(15 downto 0);
			WA: in std_logic_vector(2 downto 0);
			RegWrite: in std_logic;
			RegDst: in std_logic;
			ExtOp: in std_logic;
			RD1: out std_logic_vector(15 downto 0);
			RD2: out std_logic_vector(15 downto 0);
			ExtImm : out std_logic_vector(15 downto 0);
			func : out std_logic_vector(2 downto 0);
			sa : out std_logic);		
end component;

component MainControl is
Port	(  Instr:in std_logic_vector(2 downto 0);
            RegWrite: out std_logic;
			 RegDst: out std_logic;
			 ExtOp: out std_logic;
			 Jump: out std_logic;
			 Branch: out std_logic;
			 ALUSrc: out std_logic;
			 ALUOp: out std_logic_vector(2 downto 0);
			 MemtoReg: out std_logic;
			 MemWrite: out std_logic
			 );
end component;



component Execution_Unit is
Port(
	PCOut:in std_logic_vector(15 downto 0);
	RD1: in std_logic_vector(15 downto 0);
	RD2: in std_logic_vector(15 downto 0);
	Ext_Imm: in std_logic_vector(15 downto 0);
	Func: in std_logic_vector(2 downto 0);
	SA: in std_logic;
	ALUSrc: in std_logic;
	ALUOp: in std_logic_vector(2 downto 0);
	BranchAdress: out std_logic_vector(15 downto 0);
	ALURes: out std_logic_vector(15 downto 0);
	Zero: out std_logic);
end component;


component Memory_Unit is
	port(
			clk: in std_logic;--
			ALURes : in std_logic_vector(15 downto 0);
			WriteData: in std_logic_vector(15 downto 0);
			MemWrite: in std_logic;			
			MemData:out std_logic_vector(15 downto 0);--
			ALUFinal :out std_logic_vector(15 downto 0)--
	);
end component;


--MPG signals
signal enable: STD_LOGIC;    
signal enable2: STD_LOGIC;	  

--SSD signals
signal digits : std_logic_vector(15 downto 0):=X"0000"; 

--IF signals
signal BranchAdress:std_logic_vector(15 downto 0);  	   
signal JumpAddress:std_logic_vector(15 downto 0); 		   
signal Instr: std_logic_vector(15 downto 0);			 
signal PCOut: std_logic_vector(15 downto 0);	

--ID siganls								
signal RD1: std_logic_vector(15 downto 0);					
signal RD2: std_logic_vector(15 downto 0);					
signal ExtImm : std_logic_vector(15 downto 0);				
signal func :std_logic_vector(2 downto 0);					
signal sa : std_logic;	
signal WriteData: std_logic_vector(15 downto 0);


--Main Control signals
signal RegWrite: std_logic;
signal RegDst: std_logic;
signal ExtOp: std_logic;
signal Jump: std_logic;
signal Branch: std_logic;
signal ALUSrc: std_logic;
signal ALUOp: std_logic_vector(2 downto 0);
signal MemtoReg: std_logic;
signal MemWrite: std_logic;

--EX signals				 
signal ALURes: std_logic_vector(15 downto 0);			  
signal zero: std_logic;		



--MEM_unit signals											
signal MemOut: std_logic_vector(15 downto 0);				
signal ALUFinal: std_logic_vector(15 downto 0);					
signal PCSrc:std_logic;												




-- ID/IF pipeline Registers 
signal ID_IF_PC: std_logic_vector(15 downto 0);
signal ID_IF_Instr: std_logic_vector(15 downto 0);


-- ID/EX Pipeline Register 
signal ID_EX_PC : std_logic_vector(15 downto 0);
signal ID_EX_Instr : std_logic_vector(15 downto 0);
signal ID_EX_RD1 : std_logic_vector(15 downto 0);
signal ID_EX_RD2 : std_logic_vector(15 downto 0);
signal ID_EX_ExtImm : std_logic_vector(15 downto 0);
signal ID_EX_func : std_logic_vector(2 downto 0);
signal ID_EX_sa : std_logic;


-- ID/EX Control signals 
signal ID_EX_RegWrite : std_logic;
signal ID_EX_RegDst : std_logic;
signal ID_EX_ALUSrc : std_logic;
signal ID_EX_ALUOp : std_logic_vector(2 downto 0);
signal ID_EX_MemtoReg : std_logic;
signal ID_EX_MemWrite : std_logic;
signal ID_EX_Branch : std_logic;
signal ID_EX_Jump : std_logic;



-- EX/MEM Pipeline Register Signals
signal EX_MEM_ALURes : std_logic_vector(15 downto 0);
signal EX_MEM_BranchAdress : std_logic_vector(15 downto 0); 
signal EX_MEM_Zero : std_logic; 
signal EX_MEM_WA : std_logic_vector(2 downto 0); 
signal EX_MEM_MemWrite : std_logic;
signal EX_MEM_Branch : std_logic;
signal EX_MEM_MemtoReg : std_logic;
signal EX_MEM_RegWrite : std_logic;
signal EX_MEM_WriteData : std_logic_vector(15 downto 0);


 --MEM/WB Pipeline Register Signals
signal MEM_WB_MemOut: std_logic_vector(15 downto 0);
signal MEM_WB_ALUFinal: std_logic_vector(15 downto 0);
signal MEM_WB_WA : std_logic_vector(2 downto 0); 


-- Control signals for EX/MEM stages
signal MEM_WB_RegWrite : std_logic;
signal MEM_WB_MemtoReg : std_logic;


begin


debouncer1 :MPG port map(btn(0),clk,enable);
debouncer2 :MPG port map(btn(1),clk,enable2);

ssd1 :SSD port map(clk,digits,an,cat);

Intruction_Fetch1: Instruction_Fetch port map(enable,enable2,clk,BranchAdress,JumpAddress,Jump,PCSrc,Instr,PCOut);

Instruction_Decode1 : Instruction_Decode port map (clk,ID_IF_Instr,WriteData,MEM_WB_WA,MEM_WB_RegWrite,RegDst,ExtOp,RD1,RD2,ExtImm,func,sa);

MainControl1 : MainControl port map (ID_IF_Instr(15 downto 13),RegWrite,RegDst,ExtOp,Jump,Branch,ALUSrc,ALUOp,MemWrite,MemtoReg);

Execution_Unit1 : Execution_Unit port map(ID_EX_PC,ID_EX_RD1,RD2,ID_EX_ExtImm,ID_EX_func,ID_EX_sa,ID_EX_ALUSrc,ID_EX_ALUOp,EX_MEM_BranchAdress,EX_MEM_ALURes,EX_MEM_Zero);

Memory_Unit1 : Memory_Unit port map(clk,EX_MEM_ALURes,EX_MEM_WriteData,EX_MEM_MemWrite,MEM_WB_MemOut,MEM_WB_ALUFinal);


process(MEM_WB_MemtoReg,MEM_WB_ALUFinal,MEM_WB_MemOut)
begin
	case (MemtoReg) is
		when '1' => WriteData<=MemOut;
		when '0' => WriteData<=ALUFinal;
		when others => WriteData<=WriteData;
	end case;
end process;	



PCSrc<=EX_MEM_zero and EX_MEM_Branch;

JumpAddress<=ID_IF_PC(15 downto 14) & ID_IF_Instr(13 downto 0);


process(Instr,PCout,RD1,RD2,ExtImm,ALURes,MemOut,WriteData,sw)
begin
	case(sw(7 downto 5)) is
		when "000"=>
				digits<=Instr;			
		when "001"=>
				digits<=PCout;				
		when "010"=>
				digits<=RD1;			
		when "011"=>
				digits<=RD2;				
		when "100"=>
				digits<=ExtImm;			
		when "101" =>
				digits<=ALURes;					
		when "110"=>
				digits<=MemOut;	
		when "111"=>
				digits<=WriteData;	
		when others=>
				digits<=X"B0B0";
	end case;
end process;

process(RegDst,ExtOp,ALUSrc,Branch,Jump,MemWrite,MemtoReg,RegWrite,sw,ALUOp)
begin
	if sw(0)='0' then		
		led(7)<=RegDst;
		led(6)<=ExtOp;
		led(5)<=ALUSrc;
		led(4)<=Branch;
		led(3)<=Jump;
		led(2)<=MemWrite;
		led(1)<=MemtoReg;
		led(0)<=RegWrite;
		
	else
		led(2 downto 0)<=ALUOp(2 downto 0);
		led(7 downto 3)<="00000";
	end if;
end process;	


---pipeline logic ID/IF

process(clk)
begin
    if rising_edge(clk) then
    if enable='1' then
            ID_IF_PC <= PCOut;
            ID_IF_Instr <= Instr;
            end if;
    end if;
end process;

--pipleine logic ID/EX
process(clk)
begin
    if rising_edge(clk) then
       if enable='1' then
        ID_EX_PC <= ID_IF_PC;
        ID_EX_Instr <= Instr;
        ID_EX_RD1 <= RD1;
        ID_EX_RD2 <= RD2;
        ID_EX_ExtImm <= ExtImm;
        ID_EX_func <= func;
        ID_EX_sa <= sa;
        ID_EX_RegWrite <= RegWrite;
        ID_EX_RegDst <= RegDst;
        ID_EX_ALUSrc <= ALUSrc;
        ID_EX_ALUOp <= ALUOp;
        ID_EX_MemtoReg <= MemtoReg;
        ID_EX_MemWrite <= MemWrite;
        ID_EX_Branch <= Branch;
        ID_EX_Jump <= Jump;
        end if;
    end if;
end process;

--doing this mux here now, not in instrunction decode
process(ID_EX_RegDst,ID_EX_Instr)	
begin
	case (ID_EX_RegDst) is
		when '0' =>EX_MEM_WA<=ID_EX_Instr(9 downto 7);
		when '1'=>EX_MEM_WA<=ID_EX_Instr(6 downto 4);
		when others=>EX_MEM_WA<=EX_MEM_WA;
	end case;
end process;


--pipeline logic EX/MEM
process(clk)
begin
    if rising_edge(clk) then
        if enable='1' then
        --EX_MEM_ALURes <= ALURes; 
        --EX_MEM_BranchAdress <= BranchAdress; 
        --EX_MEM_Zero <= zero; 
        EX_MEM_WriteData <= ID_EX_RD2;
        EX_MEM_MemtoReg <= ID_EX_MemtoReg;
        EX_MEM_RegWrite <= ID_EX_RegWrite;
        EX_MEM_MemWrite <= ID_EX_MemWrite;
        EX_MEM_Branch <= ID_EX_Branch;
             end if; 
    end if;
end process;

--pipeline logic MEM/WB
process(clk)
begin
    if rising_edge(clk) then
        if enable='1' then
        MEM_WB_MemtoReg <= EX_MEM_MemtoReg;
        MEM_WB_RegWrite <= EX_MEM_RegWrite;
        MEM_WB_WA<=EX_MEM_WA;
        end if;    
    end if;
end process;
end Behavioral;

