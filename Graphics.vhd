--File name: Graphics.vhd
--Title of design unit: Graphics
--Description of design unit (including purpose and model limitations): Controls graphics of the game and collision detection
--Design library where code should be compiled
--Analysis dependencies (e.g., included packages or components): N/A
--Initialization of model (e.g., memory initialization file): N/A
--Simulator(s), simulator version(s), and platform(s) used: ModelSim-Altera
--Notes or other items
--Author(s) and contact information: Ziyuan Chen, Nathan Honold
--Revision list containing version number, author(s), dates and description of changes
	--Date of Creation 12/11/2014

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY Graphics IS

   PORT(pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
        Red,Green,Blue 				: OUT std_logic_vector(7 downto 0);
        graphics_clk					: IN std_logic;
		  memory_clk					: in std_logic;
		  player_jump					: IN std_logic;
		  score							: out std_logic_vector(7 downto 0);
		  difficulty					: in std_logic;
		  theme							: in std_logic;
		  RESET							: IN std_logic);
		
END Graphics;

architecture behavior of Graphics is

COMPONENT wall

    PORT(pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
        is_wall		 				: OUT std_logic;
		  score							: OUT std_logic_vector(7 downto 0);
        clk								: IN std_logic;
		  freeze_wall					: in std_logic;
		  RESET							: IN std_logic);
       
END COMPONENT;

COMPONENT player

   PORT(pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
        is_player		 				: OUT std_logic;
        clk								: IN std_logic;
		  jump							: IN std_logic;
		  graphic_address				: out std_logic_vector(10 downto 0);
		  freeze_player				: in std_logic;
		  difficulty					: in std_logic;
		  RESET							: IN std_logic);
       
END COMPONENT;

COMPONENT Player1_Graphics_Storage_R
	PORT
	(
		address	: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT Player1_Graphics_Storage_G
	PORT
	(
		address	: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT Player1_Graphics_Storage_B
	PORT
	(
		address	: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT Player2_Graphics_Storage_R
	PORT
	(
		address	: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT Player2_Graphics_Storage_G
	PORT
	(
		address	: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT Player2_Graphics_Storage_B
	PORT
	(
		address	: IN STD_LOGIC_VECTOR (10 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT Background_Graphics_Storage_R
	PORT
	(
		address	: IN STD_LOGIC_VECTOR (16 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT Background_Graphics_Storage_G
	PORT
	(
		address	: IN STD_LOGIC_VECTOR (16 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT Background_Graphics_Storage_B
	PORT
	(
		address	: IN STD_LOGIC_VECTOR (16 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END COMPONENT;

signal is_wall1			: std_logic;
signal is_player			: std_logic;
signal score_Int			: std_logic_vector(7 downto 0):= "00000000";
signal pixel_address		: std_logic_vector(10 downto 0);
signal player1_R, player1_G, player1_B,player2_R,player2_G,player2_B	: std_logic_vector(7 downto 0);
signal data_in_player_graphics		: std_LOGIC_vector(7 downto 0);
signal wren_player_graphics			: std_logic;
signal freeze								: std_logic := '0';
signal game_over							: std_logic;
signal freeze_counter					: std_logic_vector(1 downto 0):= "00";

signal Background_add_R,Background_add_G,Background_add_B	: std_logic_vector(18 downto 0);
signal background_R,background_G,background_B					: std_LOGIC_vector(7 downto 0);

signal score_char_display0, score_char_display1: std_Logic;
signal score_address0, score_address1: std_LOGIC_vector(5 downto 0);

BEGIN
	
	score<=score_Int;
	
	wren_player_graphics<='0';
	
	W1: wall PORT MAP
		(pixel_row		=> pixel_row,
		 pixel_column	=> pixel_column,
		 is_wall			=> is_wall1,
		 score			=> score_int,
		 clk				=> graphics_clk,
		 freeze_wall	=> freeze,
		 RESET			=> RESET
		);
	P1: player PORT MAP
		(pixel_row			=> pixel_row,
		 pixel_column		=> pixel_column,
		 is_player			=> is_player,
		 clk					=> graphics_clk,
		 jump					=> player_jump,
		 graphic_address 	=> pixel_address,
		 freeze_player		=> freeze,
		 difficulty			=> difficulty,
		 RESET				=> RESET
		);
	
	Player1R: Player1_Graphics_Storage_R port map
		(
		address	=>		pixel_address,
		clock		=>		memory_clk,
		data		=>		data_in_player_graphics,
		wren		=>		wren_player_graphics,
		q			=>		player1_R
		);
		
	Player1G: Player1_Graphics_Storage_G port map
		(
		address	=>		pixel_address,
		clock		=>		memory_clk,
		data		=>		data_in_player_graphics,
		wren		=>		wren_player_graphics,
		q			=>		player1_G
		);
		
	Player1B: Player1_Graphics_Storage_B port map
		(
		address	=>		pixel_address,
		clock		=>		memory_clk,
		data		=>		data_in_player_graphics,
		wren		=>		wren_player_graphics,
		q			=>		player1_B
		);
		
	Player2R: Player2_Graphics_Storage_R port map
		(
		address	=>		pixel_address,
		clock		=>		memory_clk,
		data		=>		data_in_player_graphics,
		wren		=>		wren_player_graphics,
		q			=>		player2_R
		);
		
	Player2G: Player2_Graphics_Storage_G port map
		(
		address	=>		pixel_address,
		clock		=>		memory_clk,
		data		=>		data_in_player_graphics,
		wren		=>		wren_player_graphics,
		q			=>		player2_G
		);
		
	Player2B: Player2_Graphics_Storage_B port map
		(
		address	=>		pixel_address,
		clock		=>		memory_clk,
		data		=>		data_in_player_graphics,
		wren		=>		wren_player_graphics,
		q			=>		player2_B
		);
		
	BackgroundR: Background_Graphics_Storage_R port map
		(
		address	=>		conv_std_logic_vector(((479-conv_integer(pixel_row)) / 2 * 320) + conv_integer(pixel_column) / 2,17),
		clock		=>		memory_clk,		--in order to hide the latter
		data		=>		data_in_player_graphics,
		wren		=>		wren_player_graphics,
		q			=>		background_R
		);
		
	BackgroundG: Background_Graphics_Storage_G port map
		(
		address	=>		conv_std_logic_vector(((479-conv_integer(pixel_row)) / 2 * 320) + conv_integer(pixel_column) / 2,17),
		clock		=>		memory_clk,		--in order to hide the latter
		data		=>		data_in_player_graphics,
		wren		=>		wren_player_graphics,
		q			=>		background_G
		);
	
	BackgroundB: Background_Graphics_Storage_B port map
		(
		address	=>		conv_std_logic_vector(((479-conv_integer(pixel_row)) / 2 * 320) + conv_integer(pixel_column) / 2,17),
		clock		=>		memory_clk,		--in order to hide the latter
		data		=>		data_in_player_graphics,
		wren		=>		wren_player_graphics,
		q			=>		background_B
	);
		
	get_color : process(is_wall1, is_player,pixel_column,pixel_row)
	begin
		if (conv_integer(pixel_row) >= 440 and (pixel_row(3 downto 0) = "0000" or
		(pixel_row(4) = '1' and pixel_column(5 downto 0) = "000000") or
		(pixel_row(4) = '0' and pixel_column(5 downto 0) = "100000"))) then
			red <= "00000000";
			green <= "00000000";
			blue <= "00000000";
		elsif pixel_row >= CONV_STD_LOGIC_VECTOR(440,10) then -- ground
			red	<=	"10001011";
			green	<=	"01000101";
			blue	<=	"00010011";
		elsif is_wall1 = '1' THEN	--draw the walls
			red	<=	"00000000";
			green	<=	"00000000";
			blue	<=	"10000000";
		elsif is_player = '1' and theme='0' and not (player1_R = "11111111" and player1_G = "11111111" and player1_B = "11111111") and pixel_column >= 101 THEN
			red	<=	player1_R;
			green	<=	player1_G;
			blue	<=	player1_B;
		elsif is_player ='1' and theme='1' and not (player2_R = "11111111" and player2_G = "11111111" and player2_B = "11111111") and pixel_column >= 101 then
			red	<=	player2_R;
			green	<=	player2_G;
			blue	<=	player2_B;
		else								--draw the background
			red	<=	background_R;
			green	<=	background_G;
			blue	<=	background_B;
		end if;
	end process get_color;
	
	check_collisions : process(is_player, is_wall1, graphics_clk)
	begin
		if is_player = '1' and (is_wall1 = '1' or pixel_row >= CONV_STD_LOGIC_VECTOR(440,10)) and
		((NOT (player1_R = "11111111" and player1_G = "11111111" and player1_B = "11111111") and theme='0') 
		or (NOT (player2_R = "11111111" and player2_G = "11111111" and player2_B = "11111111") 
		and theme='1')) then
			game_over <= '1';
		else
			game_over <= '0';
		end if;
	end process;
	
	freeze_game_time: process(game_over,reset)
	begin
		if reset='0' and game_over='1' then
			freeze_counter<=freeze_counter+1;
		elsif reset='1' then
			freeze_counter<="00";
		end if;
	end process;
	
	freeze_game: process(freeze_counter,reset)	--because of different path delays, the player on the screen can get fronzen when it
		begin													--still appears to have a distance to the obstacle (wall/ground/top boundary). These  two processes
		if freeze_counter>"10" and reset='0' then --fix this timing issue by using a counter to delay the signal propagation and to balance the
			freeze<='1';									--different propagation times
		elsif reset='1' then
			freeze<='0';
		end if;
	end process;
	
end behavior;