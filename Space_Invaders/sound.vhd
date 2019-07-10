library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sound is
   port (
			clk 			: in 	std_logic;
			specialSound: in 	std_logic_vector(1 downto 0);
			reset			: in  std_logic;
			clear			: in 	std_logic;
         buzzer   	: out std_logic       
         ); 
end sound;   


architecture behavioral of sound is
	  -- Então para 100 Hz: (50.000.000/100)*0,5 = 250.000
  constant FREQ : natural := 50000000;
  
  -- Constantes delimitam limiar do contador para cada frequência
  constant c_FREQ  : natural := (FREQ/1)/2; 
 
  -- Sinais utilizados como contadores
  signal s_FREQ  : natural range 0 to c_FREQ :=0;
  signal flag : std_logic:='0';
	
   component timer
      generic (t: integer);
      port(
         clk   : in  std_logic;
         reset : in  std_logic;
			clear : in  std_logic;
         en    : in  std_logic;
         q     : out std_logic
      );
   end component;
begin
        
process (clk, specialSound)
	begin
	if rising_edge(clk) then
		
			case specialSound is
			when "10" =>
			if(s_FREQ /= c_FREQ and flag = '0') then
				buzzer <= '1';
				s_FREQ <= s_FREQ + 10;
				if  (s_FREQ = c_FREQ-10) then
					flag <= '1';
					s_FREQ <= 0; 
				end if;
			elsif(s_FREQ /= c_FREQ and flag = '1') then
				buzzer <= '0';
				s_FREQ <= s_FREQ + 1;
				if  (s_FREQ = c_FREQ-1) then
					flag <= '0';
					s_FREQ <= 0; 
				end if;	
			end if;
			when "00" =>
			if(s_FREQ /= c_FREQ and flag = '0') then
				buzzer <= '1';
				s_FREQ <= s_FREQ + 5;
				if  (s_FREQ = c_FREQ-5) then
					flag <= '1';
					s_FREQ <= 0; 
				end if;
			elsif(s_FREQ /= c_FREQ and flag = '1') then
				buzzer <= '0';
				s_FREQ <= s_FREQ + 5;
				if  (s_FREQ = c_FREQ-5) then
					flag <= '0';
					s_FREQ <= 0; 
				end if;	
			end if;
			when others =>
				buzzer <= '0';
			end case;
			
		  
		 
	end if;
   end process;

end behavioral;
