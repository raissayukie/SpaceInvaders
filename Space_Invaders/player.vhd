library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity player is
    Port ( 
				-- User controls
			  Right : in  STD_LOGIC;
           Left  : in  STD_LOGIC;
           Start : in  STD_LOGIC;
           Shoot : in  STD_LOGIC;
			  
			  -- Control signals
           clk   : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
           Clear : in  STD_LOGIC;
			  ScoreClear : in STD_LOGIC;
			  Enable: in  STD_LOGIC;
			  
			  -- Internal signals
			  hit	  				: in  STD_LOGIC;
			  BulletInvaderX	: in STD_LOGIC_VECTOR(4 downto 0);
			  BulletInvaderY	: in STD_LOGIC_VECTOR(3 downto 0);
           posShip      	: out STD_LOGIC_VECTOR(4 downto 0);
           startPulse   	: out STD_LOGIC;
           BulletX      	: out STD_LOGIC_VECTOR(4 downto 0);
           BulletY      	: out STD_LOGIC_VECTOR(3 downto 0);
           BulletActive 	: out STD_LOGIC;
           Score        	: out STD_LOGIC_VECTOR(7 downto 0);
			  hitShip			: out STD_LOGIC;
			  Life				: out	STD_LOGIC_VECTOR(2 downto 0)
	);
end player;

architecture Structural of player is

-- Component declaration for player spaceship control block:
	COMPONENT spaceship
	PORT (  
			clk : in STD_LOGIC;
			reset : in  STD_LOGIC;
			clear: in  STD_LOGIC;
         left : in  STD_LOGIC;
         right : in  STD_LOGIC;
         enable : in  STD_LOGIC;
         posH : out  STD_LOGIC_VECTOR (4 downto 0)
		  );
	END COMPONENT;
	
	-- Component declaration for button edge detector (without debouncing )
--	COMPONENT edgeDetector
--	PORT ( 
--			clk: in STD_LOGIC;
--			reset: in STD_LOGIC;
--			clear: in STD_LOGIC;
--			enable: in STD_LOGIC;
--			input: in STD_LOGIC;
--			detected: out STD_LOGIC 
--			);
--	END COMPONENT;
--	
	-- Component declaration for button edge detector (with/ debouncing )
	COMPONENT edgeDetectorDebounce
	PORT ( 
			clk: in STD_LOGIC;
			reset: in STD_LOGIC;
			clear: in STD_LOGIC;
			enable: in STD_LOGIC;
			input: in STD_LOGIC;
			detected: out STD_LOGIC 
			);
	END COMPONENT;
	
	-- Component declaration for bullet shooting control
	COMPONENT bullet
   PORT (
			clk      : in  std_logic;
         reset    : in  std_logic;
			clear		: in  std_logic;
			enable	: in 	std_logic;
         hit      : in  std_logic;
         shoot    : in  std_logic;
         posH     : in  std_logic_vector(4 downto 0);
         flying   : out std_logic;   
         bullX    : out std_logic_vector(4 downto 0);
         bullY    : out std_logic_vector(3 downto 0)
         ); 
	END COMPONENT;
	
	-- Signals to connect things internally
	signal leftDetected: std_logic;
	signal rightDetected: std_logic;
	signal posHBus: std_logic_vector( 4 downto 0);
	signal sigHitShip: std_logic;
	
begin
	spaceshipControl: spaceship
		PORT MAP( 
					clk => clk,
					reset => Reset,
					clear => clear,
					left => leftDetected,
					right => rightDetected,
					enable => enable,
					posH => posHBus 
					);
				
	leftEdgeDetector: edgeDetectorDebounce
		PORT MAP(
					clk => clk,
					reset => Reset,
					clear => clear,
					enable => enable,
					input => Left,
					detected => leftDetected
					);
					
	rightEdgeDetector: edgeDetectorDebounce
		PORT MAP(
					clk => clk,
					reset => Reset,
					clear => clear,
					enable =>  enable,
					input => Right,
					detected => rightDetected
					);
					
	startEdgeDetector: edgeDetectorDebounce
			PORT MAP(
					clk => clk,
					reset => Reset,
					clear => '0',
					enable =>  '1',
					input => Start,
					detected => startPulse
					);
	
	laserGun: bullet
		PORT MAP(
				clk 	=> clk,
				reset 	=> Reset,
				clear	=> clear,
				enable  => enable,
				hit   	=> hit,
				shoot 	=>	Shoot, 
				posH    => posHBus,
				flying	=> BulletActive,   
				bullX  	=> BulletX,
				bullY  	=> BulletY
				); 
				
	posShip <= posHBus;
	
	process( clk, reset )
		variable intScore: integer range 0 to 255;
		variable vidas: integer range 0 to 3:=3;
	begin
		if Reset = '1' or Clear = '1' then
			intScore := 0;
			vidas:=3;
		
		elsif clk'event and clk = '1' then
			-- Erase score
			if ScoreClear = '1' then
				intScore := 0;
			
			-- Increase score when alien is hit
			elsif hit = '1' then
				intScore := intScore + 1;
			
			end if;
			
			-- Checking for bullets
			if (sigHitShip='0') and (BulletInvaderX = posHBus) and (BulletInvaderY = "1110") then
				sigHitShip<='1';
				if(vidas>0) then
					vidas:=vidas-1;
				end if;
			else
				sigHitShip<='0';
			end if;			
		end if;
		case vidas is
			when 1 =>
				Life<= "001";
			when 2 =>
				Life<= "011";
			when 3 =>
				Life<= "111";			
			when others =>
				Life<= "000";
		end case;
		score <= std_logic_vector( to_unsigned( intScore, 8));
	end process;
	
	hitShip<=sigHitShip;
	
end Structural;

