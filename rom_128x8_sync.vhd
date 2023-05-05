library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity rom_128x8_sync is
    port( clock 	: in std_logic;
	  address	: in std_logic_vector(7 downto 0);
	  data_out	: out std_logic_vector(7 downto 0));
end entity;

architecture rom_128x8_sync_arch of rom_128x8_sync is

--------------------------Table of Constants for Programming ROM-------------------------

	constant LDA_IMM : std_logic_vector (7 downto 0) := x"86";
	constant LDA_DIR : std_logic_vector (7 downto 0) := x"87";
	constant LDB_IMM : std_logic_vector (7 downto 0) := x"88";
	constant LDB_DIR : std_logic_vector (7 downto 0) := x"89";
	constant STA_DIR : std_logic_vector (7 downto 0) := x"96";
	constant STB_DIR : std_logic_vector (7 downto 0) := x"97";
	constant ADD_AB : std_logic_vector (7 downto 0) := x"42";
	constant SUB_AB : std_logic_vector (7 downto 0) := x"43";
	constant AND_AB : std_logic_vector (7 downto 0) := x"44";
	constant OR_AB : std_logic_vector (7 downto 0) := x"45";
	constant INCA : std_logic_vector (7 downto 0) := x"46";
	constant INCB : std_logic_vector (7 downto 0) := x"47";
	constant DECA : std_logic_vector (7 downto 0) := x"48";
	constant DECB : std_logic_vector (7 downto 0) := x"49";
	constant BRA : std_logic_vector (7 downto 0) := x"20";
	constant BMI : std_logic_vector (7 downto 0) := x"21";
	constant BPL : std_logic_vector (7 downto 0) := x"22";
	constant BEQ : std_logic_vector (7 downto 0) := x"23";
	constant BNE : std_logic_vector (7 downto 0) := x"24";
	constant BVS : std_logic_vector (7 downto 0) := x"25";
	constant BVC : std_logic_vector (7 downto 0) := x"26";
	constant BCS : std_logic_vector (7 downto 0) := x"27";
	constant BCC : std_logic_vector (7 downto 0) := x"28";

---------------------------------SIGNAL------------------------------------------------

signal EN : std_logic;

---------------------------------------------------------------------------------------

type rom_type is array (0 to 127) of std_logic_vector(7 downto 0);

constant ROM : rom_type := (
----------------------A LOAD AND STORE TEST----------------------
--			    			0 => LDA_IMM,
--			    			1 => x"AA",
--			    			2 => STA_DIR,
--			    			3 => x"80",
--			    			4 => LDA_IMM,
--	          				5 => x"01",
--			    			6 => LDA_DIR,
--			    			7 => x"80",
--			    			8 => BRA,
--			    			9 => x"00",
										
------------------------B LOAD AND STORE TEST---------------------
--			    			0 => LDB_IMM,
--			    			1 => x"AA",
--			    			2 => STB_DIR,
--			    			3 => x"80",
--			    			4 => LDB_IMM,
--	          				5 => x"01",
--			    			6 => LDB_DIR,
--			    			7 => x"80",
--			    			8 => BRA,
--			    			9 => x"00",

------------------------------ALU TEST-----------------------------
--							0 => LDA_IMM, -- A = x”FE”
--							1 => x"FE",
--							2 => LDB_IMM, -- B = x”01”
--							3 => x"01",
--							4 => ADD_AB, -- A = A+B
--
--							5 => LDA_IMM, -- A = x”FF”
--							6 => x"FF",
--							7 => LDB_IMM, -- B = x”01”
--							8 => x"01",
--							9 => SUB_AB, -- A = A-B
--
--							10 => LDA_IMM, -- A = x”7F”
--							11 => x"7F",
--							12 => LDB_IMM, -- B = x”7F”
--							13 => x"01",
--							14 => AND_AB, -- A = A AND B
--
--							15 => LDB_IMM,
--							16 => x"FE",
--							17 => OR_AB, -- A = A OR B
--
--
--							18 => INCB,
--							19 => DECA,
--							20 => INCA,
--							21 => DECB,
--
--							22 => BRA,
--							23 => x"00",

-----------------------------BRANCH TEST---------------------------
--							0 => LDA_IMM,
--							1 => x"FF",
--							2 => LDB_IMM,
--							3 => x"01",
--							4 => ADD_AB,
--							5 => BEQ,
--							 6 => x"0E", 
--
--							7 => LDA_IMM,
--							8 => x"FF",
--							9 => LDB_IMM,
--							10 => x"01",
--							11 => ADD_AB,
--							12 => BCS,
--							13 => x"15",
--
--							14 => LDA_IMM,
--							15 => x"7F",
--							16 => LDB_IMM,
--							17 => x"7F",
--							18 => ADD_AB,
--							19 => BVS,
--							20 => x"07",
--
--							21 => LDA_IMM,
--							22 => x"FE",
--							23 => LDB_IMM,
--							24 => x"01",
--							25 => ADD_AB,
--							26 => BMI,
--							27 => x"00",
--
--							28 => BRA,
--							29 => x"00",

--------------------------------FPGA TEST---------------------------------

-- This FPGA test program is to check the functionality of all implemented
-- istructions on the FPGA Dev board

							0 => LDA_DIR, -- load from switches
							1 => x"F0",
							2 => LDB_IMM, -- load B immediately
							3 => x"05",
							4 => STA_DIR, -- display A on hex1
							5 => x"E1",
							6 => STB_DIR, -- display B on hex2
							7 => x"E2",
							8 => ADD_AB,
							9 => STA_DIR, -- display sum
							10 => x"E3",
							
							11 => BEQ, -- if sum = zero, error
							12 => x"15",
							13 => BCS, -- if sum has carry, error
							14 => x"15",
							15 => BVS, -- if sum has overflow, error
							16 => x"15",
							17 => BMI, -- if sum is negative, error
							18 => x"15",
							
							19 => BRA, -- if no branch return to start
							20 => x"00",
							
							21 => LDA_IMM, -- if there was a branch flash error
							22 => x"EE",
							23 => STA_DIR,
							24 => x"E3",
							25 => BRA,
							26 => x"00",

							others => x"00");
begin

ENABLE : process (address)
    begin
		if ((to_integer(unsigned(address)) >= 0) and (to_integer(unsigned(address)) <= 127)) then
			EN <= '1';
		else
			 EN <= '0';
		end if;
    end process;

MEMORY : process(clock)
    begin
		if(rising_edge(clock)) then
			if(EN = '1') then
			data_out <= ROM(to_integer(unsigned(address)));
			end if;
		end if;
    end process;

end architecture;