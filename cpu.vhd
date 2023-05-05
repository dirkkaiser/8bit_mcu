library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cpu is
    port(clock			: in std_logic;
		 reset			: in std_logic;
		 from_memory	: in std_logic_vector(7 downto 0);
		 to_memory		: out std_logic_vector(7 downto 0);
		 write_EN		: out std_logic;
		 address		: out std_logic_vector(7 downto 0));
end entity;

architecture cpu_arch of cpu is

-----------------------COMPONENTS---------------------------------

component control_unit is
    port(clock 		: in std_logic;
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
end component;

component data_path is
    port(clock 			: in std_logic;
		 reset 			: in std_logic;
		 IR_Load		: in std_logic;
		 MAR_Load		: in std_logic;
		 PC_Load		: in std_logic;
		 PC_Inc			: in std_logic;
		 A_Load			: in std_logic;
		 B_Load			: in std_logic;
		 CCR_load		: in std_logic;
		 ALU_Sel		: in std_logic_vector(2 downto 0);
		 Bus2_Sel		: in std_logic_vector(1 downto 0);
		 Bus1_Sel		: in std_logic_vector(1 downto 0);
		 from_memory	: in std_logic_vector(7 downto 0);
		 IR				: out std_logic_vector(7 downto 0);
		 CCR_Result		: out std_logic_vector(3 downto 0);
		 to_memory 		: out std_logic_vector(7 downto 0);
		 address		: out std_logic_vector(7 downto 0));
end component;

------------------------SIGNALS-----------------------------------

signal IR_internal : std_logic_vector(7 downto 0);
signal IR_Load_internal : std_logic;
signal MAR_Load_internal : std_logic;
signal PC_Load_internal : std_logic;
signal PC_Inc_internal : std_logic;
signal A_Load_internal : std_logic;
signal B_Load_internal : std_logic;
signal ALU_Sel_internal : std_logic_vector(2 downto 0);
signal CCR_Result_internal : std_logic_vector(3 downto 0);
signal CCR_Load_internal : std_logic;
signal Bus2_Sel_internal : std_logic_vector(1 downto 0);
signal Bus1_Sel_internal : std_logic_vector(1 downto 0);

------------------------------------------------------------------
begin

CU1 : control_unit port map(clock,reset,IR_internal,CCR_Result_internal,write_EN,IR_Load_internal,MAR_Load_internal,PC_Load_internal,PC_Inc_internal,A_Load_internal,B_Load_internal,CCR_Load_internal,ALU_Sel_internal,Bus2_Sel_internal,Bus1_Sel_internal);
DP1 : data_path port map(clock,reset,IR_Load_internal,MAR_Load_internal,PC_Load_internal,PC_Inc_internal,A_Load_internal,B_Load_internal,CCR_Load_internal,ALU_Sel_internal,Bus2_Sel_internal,Bus1_Sel_internal,from_memory,IR_internal,CCR_Result_internal,to_memory,address);

end architecture;