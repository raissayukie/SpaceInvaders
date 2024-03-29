library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spaceship is
    Port ( clk   : in STD_LOGIC;
			  reset : in STD_LOGIC;
			  clear : in STD_LOGIC;
           left  : in  STD_LOGIC;
           right : in  STD_LOGIC;
           enable : in  STD_LOGIC;
           posH  : out  STD_LOGIC_VECTOR (4 downto 0));
end spaceship;

architecture Behavioral of spaceship is

begin
	process( reset, clk )
		variable posHAux: integer range 0 to 19; -- To be able to update the ship position
	begin
		-- High level reset
		if reset = '1' then
			posHAux := 9;
			posH <= std_logic_vector( to_unsigned( posHAux, 5) ); --"00111"; -- Center the ship
		-- Synchronous behaviour
		elsif clk'Event and clk = '1' then
			-- Clear
			if Clear = '1' then
			posHAux := 9;
			posH <= std_logic_vector( to_unsigned( posHAux, 5) ); --"00111"; -- Center the ship
			-- When enabled...
			elsif enable = '1' then
				-- Move left/right if possible
				if left = '1' and posHAux /= 0 then
					posHAux := posHAux - 1;
				elsif right = '1' and posHAux /= 19 then
					posHAux := posHAux + 1;
				end if;
			end if;
		end if;
		
		-- Update the position
		posH <= std_logic_vector( to_unsigned( posHAux, 5) );
	end process;

end Behavioral;

