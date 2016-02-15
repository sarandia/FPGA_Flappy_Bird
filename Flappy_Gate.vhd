--Project name: Flappy_Gate
--File name: Flappy_Gate.vhd
--Title of design unit: Top-level entity of the Flappy_Gate game
--Description of design unit (including purpose and model limitations): Controls system I/O and communications between sub-components
--Design library where code should be compiled
--Analysis dependencies (e.g., included packages or components): N/A
--Initialization of model (e.g., memory initialization file): N/A
--Simulator(s), simulator version(s), and platform(s) used: ModelSim-Altera
--Notes or other items
--Author(s) and contact information: Ziyuan Chen, Nathan Honold
--Revision list containing version number, author(s), dates and description of changes
	--Date of Creation 12/11/2014

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY Flappy_Gate IS

	PORT
	(
    -- Clocks
    CLOCK_50	: IN STD_LOGIC;  -- 50 MHz
 
    -- Buttons 
    KEY 		: IN STD_LOGIC_VECTOR (3 downto 0);         -- Push buttons
	 SW		: IN STD_LOGIC_vector(17 DOWNTO 0);
    LEDG		: OUT std_logic_vector(8 downto 0);
	 
	 HEX0		: out std_logic_vector(0 to 6);
	 HEX1		: out std_Logic_vector(0 to 6);

    -- VGA output
    VGA_BLANK_N : out std_logic;            -- BLANK
    VGA_CLK 	 : out std_logic;            -- Clock
    VGA_HS 		 : out std_logic;            -- H_SYNC
    VGA_SYNC_N  : out std_logic;            -- SYNC
    VGA_VS 		 : out std_logic;            -- V_SYNC
    VGA_R 		 : out std_lOGIC_VECTOR(7 downto 0); -- Red[9:0]
    VGA_G 		 : out std_lOGIC_VECTOR(7 downto 0); -- Green[9:0]
    VGA_B 		 : out std_lOGIC_VECTOR(7 downto 0) -- Blue[9:0]
	);
END Flappy_Gate;


ARCHITECTURE structural OF Flappy_Gate IS

COMPONENT VGA_SYNC_module

	PORT(	clock_50Mhz: in std_logic;
			red, green, blue		: IN	STD_LOGIC_VECTOR(7 downto 0);
			red_out, green_out, blue_out: out std_logic_vector(7 downto 0); 
			horiz_sync_out: out std_logic;
			vert_sync_out, video_on, pixel_clock
				: OUT	STD_LOGIC;
			pixel_row, pixel_column: OUT STD_LOGIC_VECTOR(9 DOWNTO 0));

END COMPONENT;

COMPONENT Graphics

   PORT(pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
        Red,Green,Blue 				: OUT std_logic_vector(7 downto 0);
        graphics_clk					: IN std_logic;
		  memory_clk					: in std_logic;
		  player_jump					: IN std_logic;
		  score							: out std_Logic_vector(7 downto 0);
		  difficulty					: in std_logic;
		  theme							: in std_logic;
		  RESET							: IN std_logic);

END COMPONENT;

COMPONENT hex_display
	port (
	bcd: in std_logic_vector (7 downto 0);
	d0:  out std_LOGIC_VECTOR(0 to 6);
	d1:  out std_LOGIC_VECTOR(0 to 6)
);
end COMPONENT;

SIGNAL red_int, green_int, blue_int : STD_LOGIC_vector(7 downto 0);
SIGNAL video_on_int		: STD_LOGIC;
SIGNAL vert_sync_int		: STD_LOGIC;
SIGNAL horiz_sync_int	: STD_LOGIC;
SIGNAL pixel_clock_int	: STD_LOGIC;
SIGNAL pixel_row_int		: STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL pixel_column_int	: STD_LOGIC_VECTOR(9 DOWNTO 0);

SIGNAL game_over : std_logic;
SIGNAL RESET : std_logic := '1';
SIGNAL reset_counter : std_logic_vector(9 downto 0) := "0000000000";

signal score_buffer: std_logic_vector(7 downto 0):="00000000";

BEGIN

	VGA_HS <= horiz_sync_int;
	VGA_VS <= vert_sync_int;
	
	LEDG(7) <= not KEY(0);
	LEDG(6) <= reset;

	U1: VGA_SYNC_module PORT MAP
		(clock_50Mhz		=>	CLOCK_50,
		 red					=>	red_int,
		 green				=>	green_int,	
		 blue					=>	blue_int,
		 red_out				=>	VGA_R,
		 green_out			=>	VGA_G,
		 blue_out			=>	VGA_B,
		 horiz_sync_out	=>	horiz_sync_int,
		 vert_sync_out		=>	vert_sync_int,
		 video_on			=>	VGA_BLANK_N,
		 pixel_clock		=>	VGA_CLK,
		 pixel_row			=>	pixel_row_int,
		 pixel_column		=>	pixel_column_int
		);

	G1: Graphics PORT MAP
		(pixel_row		=> pixel_row_int,
		 pixel_column	=> pixel_column_int,
		 Red				=> red_int,
		 Green			=> green_int,
		 Blue				=> blue_int,
		 graphics_clk	=> vert_sync_int,
		 memory_clk		=> cloCK_50,
		 player_jump	=> KEY(0),
		 score			=> score_buffer,
		 difficulty		=> SW(1),
		 theme			=> SW(2),
		 RESET			=> RESET
		);
		
	HEX_display_module: hex_display port map
		(
		bcd 	=> score_buffer,
		d0		=> HEX0,
		d1		=> HEX1
		);
	
	reset_game : process
	begin
		wait until vert_sync_int'event and vert_sync_int = '1';
			if SW(0) = '1' THEN
				RESET <= '1';
				reset_counter <= "0000000000";
			elsif RESET = '1' THEN
				reset_counter <= reset_counter + 1;
				if reset_counter = "0000000000" THEN
					RESET <= '0';
				end if;
			end if;
	end process reset_game;
END structural;