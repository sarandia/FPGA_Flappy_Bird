--File name: Player.vhd
--Title of design unit: Player
--Description of design unit (including purpose and model limitations): Controls the movement of the player
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


ENTITY player IS

   PORT(pixel_row, pixel_column	: IN std_logic_vector(9 DOWNTO 0);
        is_player		 				: OUT std_logic;
        clk								: IN std_logic;
		  jump							: IN std_logic;
		  graphic_address				: out std_logic_vector(10 downto 0);
		  freeze_player				: in std_logic;
		  difficulty					: in std_logic;
		  RESET							: IN std_logic);
		
END player;

architecture behavior of player is

SIGNAL Size				: std_logic_vector(9 DOWNTO 0):= conv_STD_LOGIC_VECTOR(40,10);  
SIGNAL X_pos			: std_logic_vector(9 DOWNTO 0);
SIGNAL Y_pos			: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(240,10);
SIGNAL vel				: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0,10);
SIGNAL accel			: std_logic_vector(9 DOWNTO 0);
SIGNAL jump_speed		: std_logic_vector(9 downto 0);
SIGNAL jumped			: std_logic := '0';
SIGNAL accel_counter	: std_logic_vector(1 downto 0) := "00";


BEGIN

Size <= CONV_STD_LOGIC_VECTOR(40,10);		-- the size of the player block is set to be 40-by-40 pixel
X_pos <= CONV_STD_LOGIC_VECTOR(100,10);	-- the x position of the left edge of the player block is fixed at 100 pixels

jump_speed <= CONV_STD_LOGIC_VECTOR(-6,10) when difficulty = '0' else
			CONV_STD_LOGIC_VECTOR(-10,10);		--gravitational acceleration based on the difficulty setting
accel <= CONV_STD_LOGIC_VECTOR(1,10) when difficulty = '0' else
			CONV_STD_LOGIC_VECTOR(2,10);		--gravitational acceleration based on the difficulty setting


RGB_Display: Process (X_pos, Y_pos, Size, pixel_column, pixel_row)
BEGIN
	IF (pixel_column >= X_pos) AND
		(pixel_column < X_pos + Size) AND
		(pixel_row >= Y_pos) AND 
		(pixel_row < Y_pos + Size) THEN
		is_player <= '1';
		
		graphic_address<=conV_STD_LOGIC_VECTOR(conv_integer(pixel_column)-conv_integer(X_pos)+conv_integer(SIZE)*(-conv_integer(Y_pos)+conv_integer(pixel_row)),11);
				--equation that maps a pixel location to its corresponding address in the memory
	ELSE
 		is_player <= '0';
		graphic_address <= "00000000000";
	END IF;
END process RGB_Display;


Move_Player: process
BEGIN						-- the jump and fall mechanism
	WAIT UNTIL clk'event and clk = '1';
		if RESET = '1' THEN
			Y_pos <= CONV_STD_LOGIC_VECTOR(240,10);
			vel <= CONV_STD_LOGIC_VECTOR(0,10);
		ELSIF freeze_player='0' then
			IF jump = '0' and jumped = '0' THEN
				vel <= jump_speed;
				jumped <= '1';
			ELSE
				if jump = '1' and jumped = '1' then
					jumped <= '0';
				end if;
				if accel_counter = "00" THEN
					vel <= vel + accel;
				elsif accel_counter = "01" THEN
					accel_counter <= "11";
				end if;
				accel_counter <= accel_counter + 1;
			END IF;
			
			-- Compute next wall Y position
			Y_pos <= Y_pos + vel;
			
		END IF;
		
END process Move_Player;

END behavior;