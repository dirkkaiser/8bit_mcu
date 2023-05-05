library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity clock_div_prec is
	port(Clock_in 	: in std_logic;
		 Reset		: in std_logic;
		 Sel		: in std_logic_vector (1 downto 0);
		 Clock_out	: out std_logic);
end entity;

architecture clock_div_prec_arch of clock_div_prec is

signal CNT : integer;
signal Clock_CNT : std_logic;
signal MaxValue : integer;

begin

MAX_VALUE : process(Sel)
	begin
	
		case(Sel) is
			when "00" => MaxValue <= 25000000;
			when "01" => MaxValue <= 2500000;
			when "10" => MaxValue <= 250000;
			when "11" => MaxValue <= 25000;
			when others => MaxValue <= 25;
		end case;
		
	end process;

CLOCK_PREC : process(Clock_in, Reset)
	begin
		if(Reset = '0') then
			CNT <= 0;
			Clock_CNT <= '0';
		elsif(rising_edge(Clock_in)) then
			if(CNT >= MaxValue) then
				CNT <= 0;
				Clock_CNT <= not Clock_CNT;
			else
				CNT <= CNT + 1;
			end if;
		end if;
	end process;

Clock_out <= Clock_CNT;

end architecture;