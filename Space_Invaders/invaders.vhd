library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity invaders is
   port (
				clk   					: in  std_logic;
				reset 					: in  std_logic;
				clear 					: in  std_logic;
				start 					: in  std_logic;
				bullX1 					: in  std_logic_vector(4 downto 0);
				bullY1 					: in  std_logic_vector(3 downto 0);				       
				bullX2 					: in  std_logic_vector(4 downto 0);
				bullY2 					: in  std_logic_vector(3 downto 0);
				level  					: in  std_logic_vector( 2 downto 0);
				hitP1						: in	std_logic;
				hitP2						: in	std_logic;
				hit1   					: out std_logic;  
				hit2   					: out std_logic;
				bullInvaderX 			: out  std_logic_vector(4 downto 0);
				bullInvaderY 			: out  std_logic_vector(3 downto 0);	
				invArray 				: inout std_logic_vector(39 downto 0);
				invLine  				: inout std_logic_vector(3 downto 0);
				BulletInvaderActive	: out std_logic
				
         ); 
end invaders;   


architecture behavioral of invaders is
   signal right : std_logic := '0'; -- movement of invaders: 1 = right;
   signal tick, tick1, tick2  : std_logic; -- Signal from timer
	signal moving : std_logic; 
	signal sighit1, sighit2: std_logic;
	signal hitSomeone: std_logic;

	
	type INVADERMATRIX is array( 0 to 7) of std_logic_vector( 39 downto 0);
	constant initArray : INVADERMATRIX := ( 
															"0000000000000000000001010101010101010101",  -- level 1
															"0000000000000000000001010101101001010101",  -- level 2
															"0000000000000000000001010110101010010101",  -- level 3
															"0000000000000000000001011010101010100101",  -- level 4
															"0000000000000000000010101010101010101010",  -- level 5
															"0000000000000000000001011010111110100101",  -- level 6
															"0000000000000000000001011011111111100101",  -- level 7
															"0000000000000000000011111111111111111111"   -- level 8
														);
	--signal internalInvLine: std_logic_vector( 3 downto 0);   
	
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
	
	component BulletInvader
       port (
			clk      	: in  std_logic;
         reset    	: in  std_logic;
			clear			: in  std_logic;
			enable		: in 	std_logic;
         hitInvader  : in  std_logic;  -- '1' when an invader has been hit
         shoot    	: in  std_logic;  -- pushbutton
         posH     	: in  std_logic_vector(4 downto 0);   -- h position of invader
			posV     	: in  std_logic_vector(3 downto 0);   -- v position of invaders
         flying   	: out std_logic;-- '1' if there is a bullet moving   
         bullX    	: out std_logic_vector(4 downto 0);
         bullY    	: out std_logic_vector(3 downto 0)
         ); 
   end component;

   signal enableTim1, enableTim2: std_logic;
	signal posHBullet: std_logic_vector(4 downto 0);
   
begin

	hitSomeone<=hitP1 or hitP2;
	-- Instantiate a timer for invaders movement timing
   speedTimer1: timer
      generic  map (400) -- Set this to a value around 10 for a faster simulation
      port map ( clk => clk, reset => reset, clear => clear, en => enableTim1, q => tick1 );

   speedTimer2: timer
      generic  map (200) -- Set this to a value around 10 for a faster simulation
      port map ( clk => clk, reset => reset, clear => clear, en => enableTim2, q => tick2 );
		
		YoTambienPuedo: bulletInvader
		PORT MAP(
				clk 			=> clk,
				reset 		=> reset,
				clear			=> clear,
				enable  		=> '1',
				hitInvader  => hitSomeone,
				shoot 		=>	'1', 
				posH    		=> posHBullet, -- Adicionar
				posV			=>	invLine, -- Adicionar
				flying		=> BulletInvaderActive,   
				bullX  		=> bullInvaderX,
				bullY  		=> bullInvaderY
				); 
   
   -- Timers control
   tick <= tick1 or tick2;
   enableTim1 <= '1' when level(2) = '0' else '0';
   enableTim2 <= not enableTim1;
      
	-- Main process
   process (reset, clk, sighit1, sighit2)
		variable intBulletX1: integer range 0 to 39; -- Temporarily storage for bullet 1 X position translated into 2-bit-per-alien coordinates
		variable intBulletX2: integer range 0 to 39; -- Temporarily storage for bullet 2 X position translated into 2-bit-per-alien coordinates
		variable intLevel: integer range 0 to 7; 	 -- Temporarily storage for level
		variable currentInvader: std_logic_vector(1 downto 0);
   begin
      if reset = '1' then 
			--Default values:
			moving <= '0';
			right <= '0';
			sighit1 <= '0';
			sighit2 <= '0';
			
			-- Choose this value for simulating 'you win' state:
         --invArray <=  "0000000000000000000000000000000000000000" ;
			-- Otherwise, this is the correct value (for first level):
			intLevel :=  to_integer( unsigned( level));
			invArray <=  initArray( intLevel );
			
			-- Choose this value for simulating 'you lose' state:
			invLine <= "1101";
			-- Otherwise, this is the correct value:
         --invLine <= "0000"; 
			

      elsif clk'event and clk = '1' then
			if Clear = '1' then
					--Default values:
					moving <= '0';
					right <= '0';
					sighit1 <= '0';
					sighit2 <= '0';
			
					-- Choose this value for simulating 'you win' state:
					--invArray <=  "0000000000000000000000000000000000000000" ;
					-- Otherwise, this is the correct value (for first level):
					intLevel :=  to_integer( unsigned( level));
					invArray <=  initArray( intLevel );
			
					-- Choose this value for simulating 'you lose' state:
					-- invLine <= "1101";
					-- Otherwise, this is the correct value:
					invLine <= "0000"; 
			else	
				-- Sequential behaviors:
				if (start = '1') then
					moving <= '1'; -- Set this to '0' to stop the invaders when testing the bullet
				end if;
		
				if (tick = '1') and (moving = '1') then
					-- Moving to the right
					if right = '0' then 
						-- Condition for reaching the end of the line: there is at least a '1' in either of the 2 final values
						if invArray(39 downto 38) /= "00" then
							right <= '1';
							-- Prevent further movement if the end has been reached
							if invLine /= "1110" then
							 case level is
   							when "000" => invLine <= std_logic_vector(unsigned(invLine) + to_unsigned(1,4)); -- Invaders Line ++ 
								when "001" => invLine <= std_logic_vector(unsigned(invLine) + to_unsigned(1,4)); -- Invaders Line ++ 
								when "010" => invLine <= std_logic_vector(unsigned(invLine) + to_unsigned(1,4)); -- Invaders Line ++ 
     							when "011" => invLine <= std_logic_vector(unsigned(invLine) + to_unsigned(2,4)); -- Invaders Line ++ 	
								when "100" => invLine <= std_logic_vector(unsigned(invLine) + to_unsigned(2,4)); -- Invaders Line ++ 	
								when "101" => invLine <= std_logic_vector(unsigned(invLine) + to_unsigned(2,4)); -- Invaders Line ++ 	
								when "110" => invLine <= std_logic_vector(unsigned(invLine) + to_unsigned(3,4)); -- Invaders Line ++ 
								when others => invLine <= std_logic_vector(unsigned(invLine) + to_unsigned(3,4)); -- Invaders Line ++ 			
								end case;
							else
								moving <= '0';
							end if;
						else
							invArray <= invArray(37 downto 0) & "00";
						end if;
				
					-- Moving to the left
					else
						-- Condition for reaching the beginning of the line: there is at least a '1' in either of the 2 first positions				
						if invArray(1 downto 0) /= "00" then
							right <= '0';
							-- Prevent further movement if the end has been reached
							if invLine /= "1110" then
								case level is
   								when "000" => invLine <= std_logic_vector(unsigned(invLine) + to_unsigned(1,4)); -- Invaders Line ++ 
									when "001" => invLine <= std_logic_vector(unsigned(invLine) + to_unsigned(1,4)); -- Invaders Line ++ 
     								when "010" => invLine <= std_logic_vector(unsigned(invLine) + to_unsigned(1,4)); -- Invaders Line ++ 
									when "011" => invLine <= std_logic_vector(unsigned(invLine) + to_unsigned(2,4)); -- Invaders Line ++
								   when "100" => invLine <= std_logic_vector(unsigned(invLine) + to_unsigned(2,4)); -- Invaders Line ++ 	
									when "101" => invLine <= std_logic_vector(unsigned(invLine) + to_unsigned(2,4)); -- Invaders Line ++ 	
									when "110" => invLine <= std_logic_vector(unsigned(invLine) + to_unsigned(3,4)); -- Invaders Line ++ 
									when others => invLine <= std_logic_vector(unsigned(invLine) + to_unsigned(3,4)); -- Invaders Line ++ 			
									end case;
							else
								moving <= '0';
							end if;
						else
							invArray <= "00" & invArray(39 downto 2);
						end if;
					end if;
				end if;
				
				loop1: for i in 19 downto 0 loop
						if(invArray(2*i+1 downto 2*i)>"00") then
							posHBullet<=std_logic_vector(to_unsigned(i,5));
						end if;
				end loop;
			
				-- Checking for bullet 1
				-- [ There is an alien if there is a '1' in either the position bullX*2 or bullX*2+1 ]
				intBulletX1 := to_integer(unsigned(bullX1))*2;
				if (sighit1 = '0' ) and (bullY1 = invLine) and invArray( intBulletX1 + 1 downto intBulletX1 ) /= "00" then
					sighit1 <= '1';
					-- Substract 1 to the alien power
--					currentInvader := invArray( intBulletX1+1 downto intBulletX1 ) ;
--					case currentInvader is
--						when "01" => invArray( intBulletX1+1 downto intBulletX1 ) <= "00";
--						when "10" => invArray( intBulletX1+1 downto intBulletX1 ) <= "01";
--						when "11" => invArray( intBulletX1+1 downto intBulletX1 ) <= "10";
--						when others => invArray( intBulletX1+1 downto intBulletX1 ) <= "00";
--					end case;
					invArray( intBulletX1+1 downto intBulletX1 ) <= std_logic_vector(unsigned( invArray( intBulletX1+1 downto intBulletX1 )) - 1 );
				else
					sighit1 <= '0';
				end if ;
				
				-- Checking for bullet2
				-- [ There is an alien if there is a '1' in either the position bullX*2 or bullX*2+1 ]
				intBulletX2 := to_integer(unsigned(bullX2))*2;
				if ( sighit2 = '0' ) and (bullY2 = invLine) and invArray( intBulletX2 + 1 downto intBulletX2 ) /= "00" then
					sighit2 <= '1';
					-- Substract 1 to the alien power
--					currentInvader := invArray( intBulletX2+1 downto intBulletX2 ) ;
--					case currentInvader is
--						when "01" => invArray( intBulletX2+1 downto intBulletX2 ) <= "00";
--						when "10" => invArray( intBulletX2+1 downto intBulletX2 ) <= "01";
--						when "11" => invArray( intBulletX2+1 downto intBulletX2 ) <= "10";
--						when others => invArray( intBulletX1+1 downto intBulletX1 ) <= "00";
--					end case;
					invArray( intBulletX2+1 downto intBulletX2 ) <= std_logic_vector(unsigned( invArray( intBulletX2+1 downto intBulletX2 )) - 1 );
				else
					sighit2 <= '0';
				end if ;
				
   		end if;	
		end if; 	
			
		-- Set hit outputs
		hit1 <= sighit1;
		hit2 <= sighit2;
		
   end process;

end behavioral;
