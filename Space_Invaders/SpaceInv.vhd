library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SpaceInv is
    Port (
				clk 									: in  STD_LOGIC;
				reset 								: in  STD_LOGIC;
				Test									: in STD_LOGIC; 	 
				left1, right1, start1, shoot1	: in STD_LOGIC;
				left2, right2, start2, shoot2	: in STD_LOGIC;
				VIDA1, VIDA2						: out STD_LOGIC_VECTOR(2 downto 0);
				FASE									: out STD_LOGIC_VECTOR(7 downto 0);
				buzzer								: out STD_LOGIC;
				HSync 								: out  STD_LOGIC;
				VSync 								: out  STD_LOGIC;
				R,G,B 								: out  STD_LOGIC
          
);
end SpaceInv;

architecture Behavioral of SpaceInv is

	 -- Component declaration for vga controller:
    COMPONENT vga
    PORT(
         clk 	: IN  std_logic;
         reset : IN  std_logic;
         RGB 	: IN  std_logic_vector(2 downto 0);
         HSync : OUT  std_logic;
         VSync : OUT  std_logic;
         R 		: OUT  std_logic;
         G 		: OUT  std_logic;
         B 		: OUT  std_logic;
         X 		: OUT  std_logic_vector(9 downto 0);
         Y 		: OUT  std_logic_vector(9 downto 0)
        );
    END COMPONENT;

	-- Compoment declaration for screen format:
	COMPONENT screenFormat
		port (
					VGAx 						: in std_logic_vector (9 downto 0);
					VGAy 						: in std_logic_vector (9 downto 0);
					test 						: in std_logic;
					invArray					: in std_logic_vector (39 downto 0);
					invLine 					: in std_logic_vector (3 downto 0);
					shipX1					: in std_logic_vector (4 downto 0);
					bullX1 					: in std_logic_vector (4 downto 0);  
					bullY1 					: in std_logic_vector (3 downto 0);
					bulletFlying1			: in std_logic;
					player2shown 			: in std_logic;
					shipX2					: in std_logic_vector (4 downto 0);
					bullX2 					: in std_logic_vector (4 downto 0);  
					bullY2 					: in std_logic_vector (3 downto 0);
					bulletFlying2			: in std_logic;
					bullInvaderX			: in std_logic_vector (4 downto 0);  
					bullInvaderY			: in std_logic_vector (3 downto 0);
					bulletInvaderActive	: in std_logic;
					specialScreen			: in std_logic_vector( 2 downto 0);
					p1Score					: in std_logic_vector(7 downto 0);
					p2Score					: in std_logic_vector(7 downto 0);
					rgb 						: out std_logic_vector(2 downto 0)
		);
	END COMPONENT;
	
	COMPONENT sound is
		port (
				clk 			: in 	std_logic;
				specialSound: in 	std_logic_vector(1 downto 0);
				reset			: in  std_logic;
				clear			: in 	std_logic;
				buzzer   	: out std_logic         
				); 
	end COMPONENT;
   
	component invaders is
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
	end component;   

	-- Declaration of component player
	component player is
   Port ( 
				-- User controls
			  Right : in  STD_LOGIC;
           Left  : in  STD_LOGIC;
           Start : in  STD_LOGIC;
           Shoot : in  STD_LOGIC;
			  
			  -- Control signals
           clk   			: in  STD_LOGIC;
           Reset 			: in  STD_LOGIC;
           Clear 			: in  STD_LOGIC;
			  ScoreClear 	: in STD_LOGIC;
			  Enable			: in  STD_LOGIC;
			  
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
	end component;

	-- Clear lines:
	----------------------------------------------------
	signal player1Clear: STD_LOGIC;
	signal p1ScoreClear: STD_LOGIC;
	signal player2Clear: STD_LOGIC;
	signal p2ScoreClear: STD_LOGIC;
	signal invadersClear: STD_LOGIC;
	
	-- Inputs for sound
	----------------------------------------------------
	signal specialSound: STD_LOGIC_VECTOR(1 downto 0);
	signal signalBuzzer: STD_LOGIC;
	
	-- Inputs for life
	----------------------------------------------------
	signal LifeP1,LifeP2: STD_LOGIC_VECTOR(2 downto 0);

	-- Inputs to ScreenFormat
	----------------------------------------------------
	signal RGB: STD_LOGIC_VECTOR (2 downto 0);
	signal X, Y: STD_LOGIC_VECTOR (9 downto 0);
	signal specialScreen: STD_LOGIC_VECTOR( 2 downto 0);
	signal testEnable: STD_LOGIC;
	signal invArray: std_logic_vector (39 downto 0);
	signal invLine : std_logic_vector (3 downto 0);
	
	-- Invaders trigger and things:
	----------------------------------------------------
	signal invadersStart: STD_LOGIC;
	signal BulletIX : STD_LOGIC_VECTOR(4 downto 0);	
	signal BulletIY : STD_LOGIC_VECTOR(3 downto 0);
	signal BulletIActive: STD_LOGIC;
	
	-- Player 1 signals:
	----------------------------------------------------
	-- User control signals
	signal p1right: std_logic;
	signal p1left: std_logic;
	signal p1start: std_logic;
	signal p1shoot: std_logic;
	signal p1enable: std_logic;
	
	-- Internal signals
	signal p1startPulse: std_logic;
	signal p1posH	: std_logic_vector (4 downto 0);
	signal p1hit : std_logic;
	signal p1bullX 	: std_logic_vector (4 downto 0);  
	signal p1bullY 	: std_logic_vector (3 downto 0);
	signal p1bulletFlying  : std_logic;
	signal p1Score:  std_logic_vector (7 downto 0);
	signal p1hitP1: std_logic;
	
	-- Player 2 signals
	---------------------------------------------------
	-- User control signals	
	signal p2right: std_logic;
	signal p2left: std_logic;
	signal p2start: std_logic;
	signal p2shoot: std_logic;
	signal p2enable: std_logic;
	
	-- Internal signals
	signal p2startPulse: std_logic;
	signal p2posH	: std_logic_vector (4 downto 0);
	signal p2hit : std_logic;
	signal p2bullX 	: std_logic_vector (4 downto 0);  
	signal p2bullY 	: std_logic_vector (3 downto 0);
	signal p2bulletFlying  : std_logic;
	signal p2Score:  std_logic_vector (7 downto 0);
	signal p2hitP2: std_logic;
	
	-- State machine things:
	------------------------------------------------------
	type State is ( testState, Start, Playing, YouWin, YouLose, WinGame );
	signal currentState, nextState: State;
	
	-- Level control:
	------------------------------------------------------
	signal level: std_logic_vector( 2 downto 0 );
	signal levelClear: std_logic;
	signal levelUp: std_logic;

begin
	vgaController: vga 
		PORT MAP( 
					clk => clk, 
					reset => reset, 
					RGB => RGB, 
					HSync => HSync, 
					VSync => VSync, 
					R => R, 
					G => G, 
					B => B, 
					X => X, 
					Y => Y 
					);

	framebuffer: screenFormat
		PORT MAP(
						VGAx 						=> X,
						VGAy 						=> Y,
						test 						=> testEnable,
						invArray 				=> invArray,
						invLine 					=> invLine,
						shipX1	 				=> p1posH,
						bullX1 					=> p1bullX,
						bullY1 					=> p1bullY,
						bulletFlying1  		=> p1bulletFlying,
						player2shown   		=> p2Enable,
						shipX2	 				=> p2posH,
						bullX2 					=> p2bullX,
						bullY2 					=> p2bullY,
						bulletFlying2  		=> p2bulletFlying,
						bullInvaderX			=> BulletIX,
						bullInvaderY			=>	BulletIY,
						bulletInvaderActive	=>	BulletIActive,
						specialScreen  		=> specialScreen,
						p1Score       			=> p1Score, 
						p2Score       			=> p2Score,
						rgb 	 					=> rgb
					);
					
	soundBuzzer: sound 
		PORT MAP(
					clk => clk,
					specialSound => specialSound,
					reset => reset,
					clear => invadersClear,
					buzzer => buzzer
					);
					
	badGuys: invaders
		PORT MAP(
					clk 						=> clk,
					reset 					=> Reset,
					Clear 					=> invadersClear,
					start 					=> invadersStart,
					bullX1 					=> p1bullX,
					bullY1 					=> p1bullY,
					bullX2 					=> p2bullX,
					bullY2 					=> p2bullY,
					level 					=> level,
					hitP1 					=> p1hitP1,
					hitP2 					=> p2hitP2,
					bullInvaderX 			=> BulletIX,
					bullInvaderY			=> BulletIY,
					hit1 						=> p1hit,					
					hit2 						=> p2hit,
					invArray 				=> invArray,
					invLine 					=> invLine,
					BulletInvaderActive 	=> BulletIActive
        			);	
	
	player1: player
	   PORT MAP ( 
			  Right 				=> p1right,
           Left  				=> p1left,
           Start 				=> p1start,
           Shoot 				=> p1shoot,
           clk   				=> clk,
           Reset 				=> reset,
           Clear 				=> player1Clear,
			  ScoreClear 		=> p1ScoreClear,
			  Enable 			=> p1Enable,
			  hit 				=> p1hit,
			  BulletInvaderX 	=> BulletIX,
			  BulletInvaderY 	=> BulletIY,
           posShip 			=> p1posH,
           startPulse 		=> p1startPulse,
           BulletX    		=> p1bullX,
           BulletY    		=> p1bullY,
           BulletActive 	=> p1bulletFlying,
           Score        	=> p1Score,
			  hitShip 			=> p1hitP1,
			  Life 				=> LifeP1
			  );
			  
	player2: player
	   PORT MAP ( 
			  Right 				=> p2right,
           Left  				=> p2left,
           Start 				=> p2start,
           Shoot 				=> p2shoot,
           clk   				=> clk,
           Reset 				=> reset,
           Clear 				=> player2Clear,
			  ScoreClear 		=> p2ScoreClear,
			  Enable 			=> p2Enable,
			  hit 				=> p2hit,
			  BulletInvaderX 	=> BulletIX,
			  BulletInvaderY 	=> BulletIY,
           posShip 			=> p2posH,
           startPulse 		=> p2startPulse,
           BulletX    		=> p2bullX,
           BulletY    		=> p2bullY,
           BulletActive 	=> p2bulletFlying,
           Score        	=> p2Score,
			  hitShip 			=> p2hitP2,
			  Life 				=> LifeP2
			  );
   
	-- Linking external I/O lines with players:
	p1right <= right1;
	p1left <= left1;
	p1start <= start1;
	p1shoot <= shoot1;
	
	p2right <= right2;
	p2left <= left2;
	p2start <= start2;
	p2shoot <= shoot2;
	
	VIDA1<=LifeP1;
	VIDA2<=LifeP2;
	
	-- Process for changing states:
	process( clk, reset)
	begin
		-- Reset
		if reset = '1' then
			currentState <= Start;
		-- Update State
		elsif clk'Event and clk = '1' then
					currentState <= nextState;				
		end if;
	end process;
	
	-- Process for modelling the transitions / outputs 
	-- of the state machine
	process( currentState, Test, invArray, invLine, p1startPulse, p2startPulse, level)
	begin
		nextState <= currentState;
		
			case currentState is
				when testState=> 
					-- Show checkerboard pattern
					-- Set outputs:
					-----------------------------
					-- Special signals
					testEnable <= '1';
					specialScreen <= "000";
					-- Invaders signals
					invadersClear <= '1';
					invadersStart <= '0';
					-- Player signals
					p1Enable <= '0';
					player1Clear <= '1';
					player2Clear <= '1';
					-- Level control
					levelUp <= '0';
					
					-- Next state:
					if ( Test = '0' ) then
						nextState <= Start;
					else
						nextState <= currentState;
					end if;
				
				when Start =>
					-- Wait for user to start the game
					-- Set outputs:
					-----------------------------
					-- Special signals
					specialSound <= "01";
					testEnable <= '0';
					specialScreen <= "000";
					-- Invaders signals
					invadersClear <= '1';
					invadersStart <= '0';
					-- Player signals
					p1Enable <= '0';
					player1Clear <= '0';
					player2Clear <= '0';
					-- Level control
					levelUp <= '0';
					
					-- Next state:
					if ( Test = '1' ) then
						nextState <= testState;
					elsif ( p1startPulse = '1' ) then 
						nextState <= Playing;
					else
						nextState <= currentState;
					end if;
				
				when Playing =>
					-- Playing the game
					-- Set outputs:
					-----------------------------
					-- Special signals
					specialSound <= "01";
					testEnable <= '0';
					specialScreen <= "000";
					-- Invaders signals
					invadersClear <= '0';
					invadersStart <= '1';
					-- Player signals
					p1Enable <= '1';
					player1Clear <= '0';
					player2Clear <= '0';
					-- Level control
					levelUp <= '0';

					
					-- Next state:
					if ( Test = '1' ) then 
						nextState <= testState;
					elsif ( invArray = "0000000000000000000000000000000000000000" ) then
						nextState <= YouWin;
					elsif ( invLine = "1110" or LifeP1="000" or LifeP2="000") then
						nextState <= YouLose;
					else
						nextState <= currentState;
					end if;

				when YouWin =>
					-- Winning screen 
					-- Set outputs:
					-----------------------------
					-- Special signals
					specialSound <= "10";
					testEnable <= '0';
					specialScreen <= "001";
					-- Invaders signals
					invadersClear <= '1';
					invadersStart <= '0';
					-- Player signals
					p1Enable <= '0';
					player1Clear <= '0';
					player2Clear <= '0';
					-- Level control
					levelUp <= '1';

					-- Next state:
					if ( Test = '1' ) then 
						nextState <= testState;
					elsif ( (p1startPulse = '1') or (p2startPulse = '1')) and (level = "000" ) then
						nextState <= WinGame;
					elsif ( p1startPulse = '1') or (p2startPulse = '1') then
						nextState <= Start;
					else
						nextState <= currentState;
					end if;
					
				when YouLose =>
					-- Losing screen
					-- Set outputs:
					-----------------------------
					--Special sound
					specialSound <= "00";
					-- Special signals
					testEnable <= '0';
					specialScreen <= "010";
					-- Invaders signals
					invadersClear <= '1';
					invadersStart <= '0';
					-- Player signals
					p1Enable <= '0';
					player1Clear <= '1';
					player2Clear <= '1';
					-- Level control
					levelUp <= '0';
					
					-- Next state:
					if ( Test = '1' ) then
						nextState <= testState;
					elsif ( p1startPulse = '1') or (p2startPulse = '1') then
						nextState <= Start;
					else
						nextState <= currentState;
					end if;
					
				when WinGame =>
					-- Win game screen
					-- Set outputs:
					-----------------------------
					-- Special signals
					specialSound <= "01";
					testEnable <= '0';
					specialScreen <= "011";
					-- Invaders signals
					invadersClear <= '1';
					invadersStart <= '0';
					-- Player signals
					p1Enable <= '0';
					player1Clear <= '0';
					player2Clear <= '0';
					-- Level control
					levelUp <= '0';
					
					-- Next state:
					if ( Test = '1' ) then
						nextState <= testState;
					elsif ( p1startPulse = '1') or (p2startPulse = '1') then
						nextState <= Start;
					else
						nextState <= currentState;
					end if;				
			end case;
		end process;
		
		-- Score and level clear control:
		process( clk )
		begin
			if clk'event and clk = '1' then
				if ((nextState = Start) and ( currentState = YouLose or currentState = WinGame)) or currentState = testState then
						p1ScoreClear <= '1';
						p2ScoreClear <= '1';
						levelClear <= '1';
				else
						p1ScoreClear <= '0';
						p2ScoreClear <= '0';
						levelClear <= '0';
				end if;
			end if;
		end process;
		
		-- Latch for the player 2 enable signal
		process( clk, Reset)
		begin
			if Reset = '1' then
				p2Enable <= '0';
			elsif clk'event and clk = '1' then
				-- Player 2 enable:
				-------------------------------------------------------------------------------------------------------
				-- Enable player 2 if p2start is pressed on start screen
				if ( currentState = Start ) and (p2startPulse = '1') then
						p2Enable <= '1';
						
				-- Disable player 2 when game is lost
				elsif ( currentState = YouLose or  currentState = WinGame ) and (p1startPulse = '1' or p2startPulse = '1') then
						p2Enable <= '0';
				end if;
			end if;
		end process;

		-- Process controlling the level
		process( clk, Reset)
			variable intLevel : integer range 0 to 7;
			variable previousLevelUp: std_logic;
		begin
			-- Counter for the level (counts edges)
			-- Reset
			if  Reset = '1' then
				intLevel := 0;
				previousLevelUp := '0';
				
			elsif clk'event and clk = '1' then
				-- Clear
				if levelClear = '1' then
					intLevel := 0;
				-- Up counter
				elsif levelUp = '1' and previousLevelUp = '0' then
					if intLevel = 7 then
						intlevel := 0;
					else
						intLevel := intLevel + 1;
					end if;
				end if;
				
				-- Store the last value
				previousLevelUp := levelUp;
				
			end if;
			
			level <= std_logic_vector( to_unsigned( intLevel, 3));
		end process;
			

		-- Show score on the leds:
		FASE <= 
					"00000001" when level = "000" else
					"00000011" when level = "001" else
					"00000111" when level = "010" else
					"00001111" when level = "011" else
					"00011111" when level = "100" else
					"00111111" when level = "101" else
					"01111111" when level = "110" else
					"11111111" when level = "111" else
					"00000000";
end Behavioral;

