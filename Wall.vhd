--File name: Wall.vhd
--Title of design unit: Wall
--Description of design unit (including purpose and model limitations): Controls the positions of the wall objects
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


ENTITY wall IS

   PORT(pixel_row, pixel_column	: IN 	std_logic_vector(9 DOWNTO 0);
        is_wall		 				: OUT std_logic;
		  score							: OUT std_logic_vector(7 downto 0);
        clk								: IN 	std_logic;
		  freeze_wall					: in std_logic;
		  RESET							: IN 	std_logic);
		
END wall;

architecture behavior of wall is

SIGNAL wall_Width			: std_logic_vector(9 DOWNTO 0); 
SIGNAL Height				: std_logic_vector(9 DOWNTO 0);
SIGNAL X_pos1				: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400,10);
SIGNAL X_pos2				: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(660,10);	--the x_pos signals are initialized, i.e., the initial
SIGNAL X_pos3				: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(920,10); --positions of the walls are given
SIGNAL X_pos4				: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(1180,10);
SIGNAL Speed		 		: std_logic_vector(9 DOWNTO 0);
SIGNAL Delta_height1		: std_logic_vector(7 DOWNTO 0) := "00001011";
SIGNAL Delta_height2		: std_logic_vector(7 DOWNTO 0) := "01000011"; -- these Delta_height signals are the random sequences for determining the
SIGNAL Delta_height3		: std_logic_vector(7 DOWNTO 0) := "00100111"; -- positions of the gaps on the walls
SIGNAL Delta_height4		: std_logic_vector(7 DOWNTO 0) := "10010001";
SIGNAL Wall_Gap			: std_logic_vector(7 downto 0);
SIGNAL my_score			: std_logic_vector(7 downto 0) := "00000000";


BEGIN

wall_Width <= CONV_STD_LOGIC_VECTOR(50,10);
Wall_Gap <= CONV_STD_LOGIC_VECTOR(185, 8);
Height <= CONV_STD_LOGIC_VECTOR(0, 10);
Speed <= CONV_STD_LOGIC_VECTOR(-2,10);
score <= my_score;

RGB_Display: Process (X_pos1,X_Pos2,x_pos3,x_pos4, pixel_column, pixel_row, wall_Width, Height, Delta_height1,delta_height2,delta_height3,delta_height4)
BEGIN												--determine the pixels that are within the walls
	IF  ((pixel_column >= X_pos1) AND
		(pixel_column <= X_pos1 + wall_Width) AND
			(((pixel_row >= 0) AND (pixel_row <= Height + Delta_height1)) OR
			 ((pixel_row >= Height + Delta_height1 + Wall_Gap) AND pixel_row <= 480))) or
		((pixel_column >= X_pos2) AND
		(pixel_column <= X_pos2 + wall_Width) AND
			(((pixel_row >= 0) AND (pixel_row <= Height + Delta_height2)) OR
			 ((pixel_row >= Height + Delta_height2 + Wall_Gap) AND pixel_row <= 480))) or
		((pixel_column >= X_pos3) AND
		(pixel_column <= X_pos3 + wall_Width) AND
			(((pixel_row >= 0) AND (pixel_row <= Height + Delta_height3)) OR
			 ((pixel_row >= Height + Delta_height3 + Wall_Gap) AND pixel_row <= 480))) or
		((pixel_column >= X_pos4) AND
		(pixel_column <= X_pos4 + wall_Width) AND
			(((pixel_row >= 0) AND (pixel_row <= Height + Delta_height4)) OR
			 ((pixel_row >= Height + Delta_height4 + Wall_Gap) AND pixel_row <= 480))) THEN
		is_wall <= '1';
 	ELSE
 		is_wall <= '0';
END IF;
END process RGB_Display;


Move_Wall: process
BEGIN
	WAIT UNTIL clk'event and clk = '1';
		
		IF RESET = '1' THEN
			X_pos1 <= CONV_STD_LOGIC_VECTOR(400,10);
			X_pos2 <= CONV_STD_LOGIC_VECTOR(660,10);
			x_pos3 <= CONV_STD_LOGIC_VECTOR(920,10);
			x_pos4 <= CONV_STD_LOGIC_VECTOR(1180,10);
			Delta_height4 <= "10010001";
			
		ELSIF freeze_wall='0' then						--sets a wall to x=640 pixels (right boundary) once it moves beyond the left boundary of the screen
			IF conv_integer(X_pos1) = 924 THEN
				X_pos1 <= CONV_STD_LOGIC_VECTOR(640,10);
				Delta_height1(7 downto 1) <= Delta_height1(6 DOWNTO 0); 
				Delta_height1(0) <= Delta_height1(7) XOR Delta_height1(5) XOR Delta_height1(4) XOR Delta_height1(3);
			elsif conv_integer(x_pos2) = 924 then
				X_pos2 <= CONV_STD_LOGIC_VECTOR(640,10);
				Delta_height2(7 downto 1) <= Delta_height2(6 DOWNTO 0); 
				Delta_height2(0) <= Delta_height2(7) XOR Delta_height2(5) XOR Delta_height2(4) XOR Delta_height2(3);
			elsif conv_integer(x_pos3) = 924 then
				X_pos3 <= CONV_STD_LOGIC_VECTOR(640,10);
				Delta_height3(7 downto 1) <= Delta_height3(6 DOWNTO 0); 
				Delta_height3(0) <= Delta_height3(7) XOR Delta_height3(5) XOR Delta_height3(4) XOR Delta_height3(3);
			elsif conv_integer(x_pos4) = 924 then
				X_pos4 <= CONV_STD_LOGIC_VECTOR(640,10);
				Delta_height4(7 downto 1) <= Delta_height4(6 DOWNTO 0); 
				Delta_height4(0) <= Delta_height4(7) XOR Delta_height4(5) XOR Delta_height4(4) XOR Delta_height4(3);
			END IF;
		
			-- Compute next wall X position
			X_pos1 <= X_pos1 + Speed;
			X_pos2 <= X_pos2 + Speed;
			X_pos3 <= X_pos3 + Speed;
			X_pos4 <= X_pos4 + Speed;
		END IF;
		
END process Move_Wall;

score_calc: process
BEGIN										--increment the score by 1 once the player successfully goes through the gap on a wall
	WAIT UNTIL clk'event and clk = '1';
		
		IF RESET = '1' THEN
			my_score <= "00000000";
		ELSE
			IF conv_integer(X_pos1) = 50 THEN
				my_score <= my_score + 1;
			elsif conv_integer(x_pos2) = 50 then
				my_score <= my_score + 1;
			elsif conv_integer(x_pos3) = 50 then
				my_score <= my_score + 1;
			elsif conv_integer(x_pos4) = 50 then
				my_score <= my_score + 1;
			END IF;
		END IF;
		
END process score_calc;

END behavior;