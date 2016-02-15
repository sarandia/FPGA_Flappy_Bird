library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;
-- Module Generates Video Sync Signals for Video Montor Interface
-- RGB and Sync outputs tie directly to monitor conector pins
ENTITY VGA_SYNC_module IS
	PORT(	clock_50Mhz: in std_logic;
			red, green, blue		: IN	STD_LOGIC_VECTOR(7 downto 0);
			red_out, green_out, blue_out: out std_logic_vector(7 downto 0); 
			horiz_sync_out: out std_logic;
			vert_sync_out, video_on, pixel_clock
				: OUT	STD_LOGIC;
			pixel_row, pixel_column: OUT STD_LOGIC_VECTOR(9 DOWNTO 0));
END VGA_SYNC_module;
ARCHITECTURE a OF VGA_SYNC_module IS
	SIGNAL horiz_sync, vert_sync, pixel_clock_int : STD_LOGIC;
	SIGNAL video_on_int, video_on_v, video_on_h : STD_LOGIC;
	SIGNAL h_count, v_count :STD_LOGIC_VECTOR(9 DOWNTO 0);
--
-- To select a different screen resolution, clock rate, and refresh rate
-- pick a set of new video timing constant values from table at end of code section
-- enter eight new sync timing constants below and
-- adjust PLL frequency output to pixel clock rate from table
-- using MegaWizard to edit video_PLL.vhd
-- Horizontal Timing Constants  
	CONSTANT H_pixels_across: 	Natural := 640;
	CONSTANT H_sync_low: 		Natural := 664;
	CONSTANT H_sync_high: 		Natural := 760;
	CONSTANT H_end_count: 		Natural := 800;
-- Vertical Timing Constants
	CONSTANT V_pixels_down: 	Natural := 480;
	CONSTANT V_sync_low: 		Natural := 491;
	CONSTANT V_sync_high: 		Natural := 493;
	CONSTANT V_end_count: 		Natural := 525;
	COMPONENT video_PLL
	PORT
	(
		inclk0		: IN STD_LOGIC  := '0';
		c0			: OUT STD_LOGIC 
	);
end component;

BEGIN

-- PLL below is used to generate the pixel clock frequency
-- Uses UP 3's 48Mhz USB clock for PLL's input clock
video_PLL_inst : video_PLL PORT MAP (
		inclk0	 => Clock_50Mhz,
		c0	 => pixel_clock_int
	);

-- video_on is high only when RGB pixel data is being displayed
-- used to blank color signals at screen edges during retrace
video_on_int <= video_on_H AND video_on_V;
-- output pixel clock and video on for external user logic
pixel_clock <= pixel_clock_int;
video_on <= video_on_int; 

PROCESS
BEGIN
	WAIT UNTIL(pixel_clock_int'EVENT) AND (pixel_clock_int='1');

--Generate Horizontal and Vertical Timing Signals for Video Signal
-- H_count counts pixels (#pixels across + extra time for sync signals)
-- 
--  Horiz_sync  ------------------------------------__________--------
--  H_count     0                 #pixels            sync low      end
--
	IF (h_count = H_end_count) THEN
   		h_count <= "0000000000";
	ELSE
   		h_count <= h_count + 1;
	END IF;

--Generate Horizontal Sync Signal using H_count
	IF (h_count <= H_sync_high) AND (h_count >= H_sync_low) THEN
 	  	horiz_sync <= '0';
	ELSE
 	  	horiz_sync <= '1';
	END IF;

--V_count counts rows of pixels (#pixel rows down + extra time for V sync signal)
--  
--  Vert_sync      -----------------------------------------------_______------------
--  V_count         0                        last pixel row      V sync low       end
--
	IF (v_count >= V_end_count) AND (h_count >= H_sync_low) THEN
   		v_count <= "0000000000";
	ELSIF (h_count = H_sync_low) THEN
   		v_count <= v_count + 1;
	END IF;

-- Generate Vertical Sync Signal using V_count
	IF (v_count <= V_sync_high) AND (v_count >= V_sync_low) THEN
   		vert_sync <= '0';
	ELSE
  		vert_sync <= '1';
	END IF;

-- Generate Video on Screen Signals for Pixel Data
-- Video on = 1 indicates pixel are being displayed
-- Video on = 0 retrace - user logic can update pixel
-- memory without needing to read memory for display
	IF (h_count < H_pixels_across) THEN
   		video_on_h <= '1';
   		pixel_column <= h_count;
	ELSE
	   	video_on_h <= '0';
	END IF;

	IF (v_count <= V_pixels_down) THEN
   		video_on_v <= '1';
   		pixel_row <= v_count;
	ELSE
   		video_on_v <= '0';
	END IF;

-- Put all video signals through DFFs to elminate any small timing delays that cause a blurry image
		horiz_sync_out <= horiz_sync;
		vert_sync_out <= vert_sync;
-- 		Also turn off RGB color signals at edge of screen during vertical and horizontal retrace
		red_out <= red;
		green_out <= green;
		blue_out <= blue;

END PROCESS;
END a;