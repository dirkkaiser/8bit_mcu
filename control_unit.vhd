library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity control_unit is
    port( clock 	: in std_logic;
		 reset 		: in std_logic;
		 IR			: in std_logic_vector(7 downto 0);
		 CCR_Result	: in std_logic_vector(3 downto 0);
		 write_EN	: out std_logic;
		 IR_Load	: out std_logic;
		 MAR_Load	: out std_logic;
		 PC_Load	: out std_logic;
		 PC_Inc		: out std_logic;
		 A_Load		: out std_logic;
		 B_Load		: out std_logic;
		 CCR_Load	: out std_logic;
		 ALU_Sel	: out std_logic_vector(2 downto 0);
		 Bus2_Sel	: out std_logic_vector(1 downto 0);
		 Bus1_Sel	: out std_logic_vector(1 downto 0));
end entity;

architecture control_unit_arch of control_unit is
--------------------------Table of Constants for Programming ROM-------------------------

-- This could have been implemented with global variables, but this works for now

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
	constant BRA : std_logic_vector (7 downto 0) := x"20"; -- Some of the branch instructions are not implemented
	constant BMI : std_logic_vector (7 downto 0) := x"21";
	constant BPL : std_logic_vector (7 downto 0) := x"22";
	constant BEQ : std_logic_vector (7 downto 0) := x"23";
	constant BNE : std_logic_vector (7 downto 0) := x"24";
	constant BVS : std_logic_vector (7 downto 0) := x"25";
	constant BVC : std_logic_vector (7 downto 0) := x"26";
	constant BCS : std_logic_vector (7 downto 0) := x"27";
	constant BCC : std_logic_vector (7 downto 0) := x"28";

---------------------------------SIGNALS------------------------------------------------
type state_type is 
    (S_FETCH_0, S_FETCH_1, S_FETCH_2,
     S_DECODE_3,
     S_LDA_IMM_4, S_LDA_IMM_5, S_LDA_IMM_6, 
     S_LDA_DIR_4, S_LDA_DIR_5, S_LDA_DIR_6, S_LDA_DIR_7, S_LDA_DIR_8,
     S_STA_DIR_4, S_STA_DIR_5, S_STA_DIR_6, S_STA_DIR_7,
     S_ADD_AB_4,
     S_BRA_4, S_BRA_5, S_BRA_6,
     S_BEQ_4, S_BEQ_5, S_BEQ_6, S_BEQ_7,
     S_LDB_IMM_4, S_LDB_IMM_5, S_LDB_IMM_6, 
     S_LDB_DIR_4, S_LDB_DIR_5, S_LDB_DIR_6, S_LDB_DIR_7, S_LDB_DIR_8,
     S_STB_DIR_4, S_STB_DIR_5, S_STB_DIR_6, S_STB_DIR_7,
     S_SUB_AB_4,
     S_AND_AB_4,
     S_OR_AB_4,
	 S_INCA_4,
	 S_INCB_4,
	 S_DECA_4,
	 S_DECB_4,
	 S_BCS_4, S_BCS_5, S_BCS_6, S_BCS_7,
	 S_BVS_4, S_BVS_5, S_BVS_6, S_BVS_7,
	 S_BMI_4, S_BMI_5, S_BMI_6, S_BMI_7);

signal current_state, next_state: state_type;

begin

-------------------------Control Finite State Machine--------------
STATE_MEMORY: process(Clock, Reset)
	begin
		if (Reset = '0') then
			current_state <= S_FETCH_0;
		elsif (rising_edge(Clock)) then
			current_state <= next_state;
		end if;
	end process;

NEXT_STATE_LOGIC: process(current_state, IR, CCR_Result)
	begin
		if (current_state = S_FETCH_0) then
		next_state <= S_FETCH_1;
		elsif (current_state = S_FETCH_1) then
		next_state <= S_FETCH_2;
		elsif (current_state = S_FETCH_2) then
		next_state <= S_DECODE_3;
--------------------------------DECODING---------------------------------------
		elsif (current_state = S_DECODE_3) then
			if (IR = LDA_IMM) then 				-- Load A Immediate
				 next_state <= S_LDA_IMM_4;
			elsif (IR = LDA_DIR) then			-- Load A Direct
				 next_state <= S_LDA_DIR_4;
			elsif (IR = STA_DIR) then			-- Store A Direct
				 next_state <= S_STA_DIR_4;
			elsif (IR = ADD_AB) then			-- Add A and B
				 next_state <= S_ADD_AB_4;
			elsif (IR = BRA) then				-- Branch Always
				 next_state <= S_BRA_4;
			elsif (IR = BEQ and CCR_Result(2)='1' ) then 	-- BEQ and Z=1
				 next_state <= S_BEQ_4;
			elsif (IR = BEQ and CCR_Result(2)='0') then		-- BEQ and Z=0
				 next_state <= S_BEQ_7;
			elsif (IR = LDB_IMM) then			-- Load B Immediate
				 next_state <= S_LDB_IMM_4;
			elsif (IR = LDB_DIR) then			-- Load B Direct
				 next_state <= S_LDB_DIR_4;
			elsif (IR = STB_DIR) then			-- Store B Direct
				 next_state <= S_STB_DIR_4;
			elsif (IR = SUB_AB) then			-- Subtract A and B
				 next_state <= S_SUB_AB_4;
			elsif (IR = AND_AB) then			-- And A and B
				 next_state <= S_AND_AB_4;
			elsif (IR = OR_AB) then				-- Or A and B
				 next_state <= S_OR_AB_4;
			elsif (IR = INCA) then				-- Increment A
				 next_state <= S_INCA_4;
			elsif (IR = INCB) then				-- Increment B
				 next_state <= S_INCB_4;
			elsif (IR = DECA) then				-- Decrement A
				 next_state <= S_DECA_4;
			elsif (IR = DECB) then				-- Decrement B
				 next_state <= S_DECB_4;
			elsif (IR = BCS and CCR_Result(0)='1' ) then 	-- BCS and C=1
				 next_state <= S_BCS_4;
			elsif (IR = BCS and CCR_Result(0)='0') then		-- BCS and C=0
				 next_state <= S_BCS_7;
			elsif (IR = BVS and CCR_Result(1)='1' ) then 	-- BVS and V=1
				 next_state <= S_BVS_4;
			elsif (IR = BEQ and CCR_Result(1)='0') then		-- BVS and V=0
				 next_state <= S_BVS_7;
			elsif (IR = BMI and CCR_Result(3)='1' ) then 	-- BMI and N=1
				 next_state <= S_BMI_4;
			elsif (IR = BMI and CCR_Result(3)='0') then		-- BMI and N=0
				 next_state <= S_BMI_7;
			else
				 next_state <= S_FETCH_0;
			end if;
-----------------------------LOAD A IMMEDIATE------------------------
	   elsif (current_state = S_LDA_IMM_4) then
			next_state <= S_LDA_IMM_5;
	   elsif (current_state = S_LDA_IMM_5) then
			next_state <= S_LDA_IMM_6;
	   elsif (current_state = S_LDA_IMM_6) then
			next_state <= S_FETCH_0;
-----------------------------LOAD A DIRECT----------------------------
	   elsif (current_state = S_LDA_DIR_4) then
			next_state <= S_LDA_DIR_5;
		elsif (current_state = S_LDA_DIR_5) then
			next_state <= S_LDA_DIR_6;
		elsif (current_state = S_LDA_DIR_6) then
			next_state <= S_LDA_DIR_7;
	   elsif (current_state = S_LDA_DIR_7) then
			next_state <= S_LDA_DIR_8;
		elsif (current_state = S_LDA_DIR_8) then
			next_state <= S_FETCH_0;
-----------------------------STORE A DIRECT---------------------------
	   elsif (current_state = S_STA_DIR_4) then
			next_state <= S_STA_DIR_5;
		elsif (current_state = S_STA_DIR_5) then
			next_state <= S_STA_DIR_6;
		elsif (current_state = S_STA_DIR_6) then
			next_state <= S_STA_DIR_7;
		elsif (current_state = S_STA_DIR_7) then
			next_state <= S_FETCH_0;
----------------------------ADD A and B-------------------------------
	   elsif (current_state = S_ADD_AB_4) then
			next_state <= S_FETCH_0;
----------------------------BRANCH ALWAYS-----------------------------
	   elsif (current_state = S_BRA_4) then
			next_state <= S_BRA_5;
	   elsif (current_state = S_BRA_5) then
			next_state <= S_BRA_6;
	   elsif (current_state = S_BRA_6) then
			next_state <= S_FETCH_0;
-----------------------------BRANCH WHEN EQUAL ZERO-------------------
	   elsif (current_state = S_BEQ_4) then
			next_state <= S_BEQ_5;
	   elsif (current_state = S_BEQ_5) then
			next_state <= S_BEQ_6;
	   elsif (current_state = S_BEQ_6) then
			next_state <= S_FETCH_0;
	   elsif (current_state = S_BEQ_7) then
			next_state <= S_FETCH_0;
-----------------------------LOAD B IMMEDIATE------------------------
	   elsif (current_state = S_LDB_IMM_4) then
			next_state <= S_LDB_IMM_5;
	   elsif (current_state = S_LDB_IMM_5) then
			next_state <= S_LDB_IMM_6;
	   elsif (current_state = S_LDB_IMM_6) then
			next_state <= S_FETCH_0;
-----------------------------LOAD B DIRECT----------------------------
	   elsif (current_state = S_LDB_DIR_4) then
			next_state <= S_LDB_DIR_5;
	   elsif (current_state = S_LDB_DIR_5) then
			next_state <= S_LDB_DIR_6;
	   elsif (current_state = S_LDB_DIR_6) then
			next_state <= S_LDB_DIR_7;
	   elsif (current_state = S_LDB_DIR_7) then
			next_state <= S_LDB_DIR_8;
	   elsif (current_state = S_LDB_DIR_8) then
			next_state <= S_FETCH_0;
-----------------------------STORE B DIRECT---------------------------
	   elsif (current_state = S_STB_DIR_4) then
			next_state <= S_STB_DIR_5;
	   elsif (current_state = S_STB_DIR_5) then
			next_state <= S_STB_DIR_6;
	   elsif (current_state = S_STB_DIR_6) then
			next_state <= S_STB_DIR_7;
	   elsif (current_state = S_STB_DIR_7) then
			next_state <= S_FETCH_0;
----------------------------SUB A and B-------------------------------
	   elsif (current_state = S_SUB_AB_4) then
			next_state <= S_FETCH_0;
----------------------------AND A and B-------------------------------
		elsif (current_state = S_AND_AB_4) then
			next_state <= S_FETCH_0;
----------------------------OR A and B--------------------------------
	   elsif (current_state = S_OR_AB_4) then
			next_state <= S_FETCH_0;
----------------------------INCREMENT A-------------------------------
		elsif (current_state = S_INCA_4) then
			next_state <= S_FETCH_0;
----------------------------INCREMENT B-------------------------------
		elsif (current_state = S_INCB_4) then
			next_state <= S_FETCH_0;
----------------------------DECREMENT A-------------------------------
		elsif (current_state = S_DECA_4) then
			next_state <= S_FETCH_0;
----------------------------DECREMENT B-------------------------------
		elsif (current_state = S_DECB_4) then
			next_state <= S_FETCH_0;
-----------------------------BRANCH WHEN CARRY-------------------
	   elsif (current_state = S_BCS_4) then
			next_state <= S_BCS_5;
	   elsif (current_state = S_BCS_5) then
			next_state <= S_BCS_6;
	   elsif (current_state = S_BCS_6) then
			next_state <= S_FETCH_0;
	   elsif (current_state = S_BCS_7) then
			next_state <= S_FETCH_0;
-----------------------------BRANCH WHEN OVERFLOW-------------------
	   elsif (current_state = S_BVS_4) then
			next_state <= S_BVS_5;
	   elsif (current_state = S_BVS_5) then
			next_state <= S_BVS_6;
	   elsif (current_state = S_BVS_6) then
			next_state <= S_FETCH_0;
	   elsif (current_state = S_BVS_7) then
			next_state <= S_FETCH_0;
-----------------------------BRANCH WHEN NEGATIVE-------------------
	   elsif (current_state = S_BMI_4) then
			next_state <= S_BMI_5;
	   elsif (current_state = S_BMI_5) then
			next_state <= S_BMI_6;
	   elsif (current_state = S_BMI_6) then
			next_state <= S_FETCH_0;
	   elsif (current_state = S_BMI_7) then
			next_state <= S_FETCH_0;
--------------------------------------------------------------------
		else
			next_state <= S_FETCH_0;
		end if;
	end process;

OUTPUT_LOGIC : process (current_state)
	begin
		case(current_state) is

----------------------------------FETCH AND DECODE--------------------------
		when S_FETCH_0 => -- Put PC onto MAR to read Opcode
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_FETCH_1 => -- Increment PC
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_FETCH_2 => -- Updating IR
			IR_Load <= '1';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_DECODE_3 => -- Decoding opcode
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

-----------------------------------LOAD A IMMEDIATE--------------------------------------
		when S_LDA_IMM_4 => -- Put PC in MAR
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_LDA_IMM_5 => -- Increment PC
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_LDA_IMM_6 => -- Loading A with opperand
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '1';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';
		
--------------------------------------LOAD A DIRECT-------------------------------------
		when S_LDA_DIR_4 => -- Put PC in MAR
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';
			
		when S_LDA_DIR_5 => -- Increment PC
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_LDA_DIR_6 => -- Loading MAR with opperand
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_LDA_DIR_7 => -- Wait for memory to catch up
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_LDA_DIR_8 => -- Load A with memory addressed at opperand
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '1';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

------------------------------------STORE A DIRECT-------------------------------------
		when S_STA_DIR_4 => -- Put PC in MAR
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_STA_DIR_5 => -- Increment PC
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_STA_DIR_6 => -- Loading MAR with opperand
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_STA_DIR_7 => -- Writing A to address
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "01"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '1';

-------------------------------------BRANCH ALWAYS----------------------------------
		when S_BRA_4 => -- Put PC in MAR
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_BRA_5 => -- Wait for memory to catch up
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_BRA_6 => -- Load PC with opperand
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '1';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

------------------------------------ADD A and B---------------------------------------
		when S_ADD_AB_4 => -- adding A and B with ALU
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '1';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '1';
			Bus1_Sel <= "01"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';
			 
--------------------------------------BRANCH WHEN EQUAL TO ZERO-------------------------------------
		when S_BEQ_4 => -- Put PC in MAR
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_BEQ_5 => -- Wait for memory to catch up
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_BEQ_6 => -- Load PC with opperand
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '1';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';
			 
		when S_BEQ_7 => -- NOT EQUAL Increment PC
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';
			 
-----------------------------------LOAD B IMMEDIATE--------------------------------------
		when S_LDB_IMM_4 => -- Put PC in MAR
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_LDB_IMM_5 => -- Increment PC
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_LDB_IMM_6 => -- Loading B with opperand
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '1';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';
		
--------------------------------------LOAD B DIRECT-------------------------------------
		when S_LDB_DIR_4 => -- Put PC in MAR
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';
			
		when S_LDB_DIR_5 => -- Increment PC
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_LDB_DIR_6 => -- Loading MAR with opperand
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_LDB_DIR_7 => -- Wait for memory to catch up
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_LDB_DIR_8 => -- Load B with memory addressed at opperand
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '1';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

------------------------------------STORE B DIRECT-------------------------------------
		when S_STB_DIR_4 => -- Put PC in MAR
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_STB_DIR_5 => -- Increment PC
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_STB_DIR_6 => -- Loading MAR with opperand
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_STB_DIR_7 => -- Writing B to address
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "10"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '1';

------------------------------------SUB A and B---------------------------------------
		when S_SUB_AB_4 => -- subtracting A and B with ALU
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '1';
			B_Load <= '0';
			ALU_Sel <= "001";
			CCR_Load <= '1';
			Bus1_Sel <= "01"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

------------------------------------AND A and B---------------------------------------
		when S_AND_AB_4 => -- anding A and B with ALU
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '1';
			B_Load <= '0';
			ALU_Sel <= "010";
			CCR_Load <= '1';
			Bus1_Sel <= "01"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

------------------------------------OR A and B---------------------------------------
		when S_OR_AB_4 => -- oring A and B with ALU
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '1';
			B_Load <= '0';
			ALU_Sel <= "011";
			CCR_Load <= '1';
			Bus1_Sel <= "01"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';
			 
------------------------------------INCREMENT A---------------------------------------
		when S_INCA_4 => -- A = A + 1 with ALU
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '1';
			B_Load <= '0';
			ALU_Sel <= "100";
			CCR_Load <= '1';
			Bus1_Sel <= "01"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';
			 
------------------------------------INCREMENT B---------------------------------------
		when S_INCB_4 => -- B = B + 1 with ALU
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '1';
			ALU_Sel <= "100";
			CCR_Load <= '1';
			Bus1_Sel <= "10"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';
			 
------------------------------------DECREMENT A---------------------------------------
		when S_DECA_4 => -- A = A - 1 with ALU
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '1';
			B_Load <= '0';
			ALU_Sel <= "101";
			CCR_Load <= '1';
			Bus1_Sel <= "01"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

------------------------------------DECREMENT B---------------------------------------
		when S_DECB_4 => -- B = B - 1 with ALU
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '1';
			ALU_Sel <= "101";
			CCR_Load <= '1';
			Bus1_Sel <= "10"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';
			 
--------------------------------------BRANCH WHEN CARRY-------------------------------------
		when S_BCS_4 => -- Put PC in MAR
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_BCS_5 => -- Wait for memory to catch up
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_BCS_6 => -- Load PC with opperand
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '1';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';
			 
		when S_BCS_7 => -- NO Carry Increment PC
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';
			 
--------------------------------------BRANCH WHEN OVERFLOW-------------------------------------
		when S_BVS_4 => -- Put PC in MAR
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_BVS_5 => -- Wait for memory to catch up
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_BVS_6 => -- Load PC with opperand
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '1';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';
			 
		when S_BVS_7 => -- NO Overflow Increment PC
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';
			 
--------------------------------------BRANCH WHEN NEGATIVE-------------------------------------
		when S_BMI_4 => -- Put PC in MAR
			IR_Load <= '0';
			MAR_Load <= '1';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_BMI_5 => -- Wait for memory to catch up
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "01"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		when S_BMI_6 => -- Load PC with opperand
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '1';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';
			 
		when S_BMI_7 => -- NOT NEGATIVE Increment PC
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '1';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "10"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

-----------------------------------------------------------------------------------------
		when others => 
			IR_Load <= '0';
			MAR_Load <= '0';
			PC_Load <= '0';
			PC_Inc <= '0';
			A_Load <= '0';
			B_Load <= '0';
			ALU_Sel <= "000";
			CCR_Load <= '0';
			Bus1_Sel <= "00"; --"00"=PC, "01"=A, "10"=B
			Bus2_Sel <= "00"; --"00"=ALU_Result, "01"=Bus1, "10"=from_memory
			write_EN <= '0';

		end case;
	end process;

end architecture;