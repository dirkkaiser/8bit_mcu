library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu is
    port( A		: in std_logic_vector(7 downto 0);
	  B		: in std_logic_vector(7 downto 0);
	  ALU_Sel	: in std_logic_vector(2 downto 0);
	  NZVC		: out std_logic_vector(3 downto 0) := "0000";
	  ALU_Result 	: out std_logic_vector(7 downto 0) := x"00");
end entity;

architecture alu_arch of alu is

begin

ALU_PROCESS : process (A, B, ALU_Sel)

		variable Sum_uns : unsigned(8 downto 0);

	begin
		if (ALU_Sel = "000") then --Addition
		
			---Sum Calculation----------------------------------
			Sum_uns := unsigned('0' & A) + unsigned('0' & B);
			ALU_Result <= std_logic_vector(Sum_uns(7 downto 0));

			---Negative Flag (N)--------------------------------
			NZVC(3) <= Sum_uns(7);

			---Zero Flag (Z)------------------------------------
			if (Sum_uns(7 downto 0) = x"00") then
				NZVC(2) <= '1';
			else
				NZVC(2) <= '0';
			end if;

			---Overflow Flag (V)--------------------------------
			if ((A(7) = '0' and B(7) = '0' and Sum_uns(7) = '1') or
				(A(7) = '1' and B(7) = '1' and Sum_uns(7) = '0')) then
				NZVC(1) <= '1';
			else
				NZVC(1) <= '0';
			end if;

			---Carry Flag (C)-----------------------------------
			NZVC(0) <= Sum_uns(8);
		
		elsif(ALU_Sel = "001") then  -- Subtraction
		
			---Difference Calculation----------------------------------
			Sum_uns := unsigned('0' & B) - unsigned('0' & A); -- According to diagram B on the ALU is Connected to Register A and A on ALU is connected to Register B
			ALU_Result <= std_logic_vector(Sum_uns(7 downto 0));

			---Negative Flag (N)--------------------------------
			NZVC(3) <= Sum_uns(7);

			---Zero Flag (Z)------------------------------------
			if (Sum_uns(7 downto 0) = x"00") then
				NZVC(2) <= '1';
			else
				NZVC(2) <= '0';
			end if;

			---Overflow Flag (V)--------------------------------
			if ((A(7) = '0' and B(7) = '1' and Sum_uns(7) = '1') or
				(A(7) = '1' and B(7) = '0' and Sum_uns(7) = '0')) then
				NZVC(1) <= '1';
			else
				NZVC(1) <= '0';
			end if;
			
			---Carry(Borrow) Flag (C)-----------------------------------
			NZVC(0) <= Sum_uns(8);
			
		elsif(ALU_Sel = "010") then -- AND
		
			ALU_Result <= A and B;
			
			---Zero Flag (Z)-------------------------------------------
			if (A /= B) then
				NZVC(2) <= '1';
			else
				NZVC(2) <= '0';
			end if;
			
			--Rest of the flags are zero for AND-------------------------
			NZVC(3) <= '0';
			NZVC(1) <= '0';
			NZVC(0) <= '0';
			
		elsif(ALU_Sel = "011") then -- OR
		
			ALU_Result <= A or B;
			
			---Zero Flag (Z)-------------------------------------------
			if (A = x"00" and B = x"00") then
				NZVC(2) <= '1';
			else
				NZVC(2) <= '0';
			end if;
			
			--Rest of the flags are zero for OR-------------------------
			NZVC(3) <= '0';
			NZVC(1) <= '0';
			NZVC(0) <= '0';
			
		elsif(ALU_Sel <= "100") then -- Increment
		
			---Sum Calculation----------------------------------
			Sum_uns := unsigned('0' & B) + "000000001";
			ALU_Result <= std_logic_vector(Sum_uns(7 downto 0));

			---Negative Flag (N)--------------------------------
			NZVC(3) <= Sum_uns(7);

			---Zero Flag (Z)------------------------------------
			if (Sum_uns(7 downto 0) = x"00") then
				NZVC(2) <= '1';
			else
				NZVC(2) <= '0';
			end if;

			---Overflow Flag (V)--------------------------------
			if (A(7) = '0' and Sum_uns(7) = '1') then
				NZVC(1) <= '1';
			else
				NZVC(1) <= '0';
			end if;

			---Carry Flag (C)-----------------------------------
			NZVC(0) <= Sum_uns(8);
			
		elsif(ALU_Sel <= "101") then -- Decrement
		
			---Difference Calculation----------------------------------
			Sum_uns := unsigned('0' & B) - "000000001";
			ALU_Result <= std_logic_vector(Sum_uns(7 downto 0));

			---Negative Flag (N)--------------------------------
			NZVC(3) <= Sum_uns(7);

			---Zero Flag (Z)------------------------------------
			if (Sum_uns(7 downto 0) = x"00") then
				NZVC(2) <= '1';
			else
				NZVC(2) <= '0';
			end if;

			---Overflow Flag (V)--------------------------------
			if ((A(7) = '0' and B(7) = '1' and Sum_uns(7) = '1') or
				(A(7) = '1' and B(7) = '0' and Sum_uns(7) = '0')) then
				NZVC(1) <= '1';
			else
				NZVC(1) <= '0';
			end if;
			
			---Carry(Borrow) Flag (C)-----------------------------------
			NZVC(0) <= Sum_uns(8);
			
		else
			ALU_Result <= x"00";
			NZVC <= "0000";
	   end if;
	end process;
	
end architecture;
