--File name: hex_display.vhd
--Title of design unit: hex_display
--Description of design unit (including purpose and model limitations): Converts the binary score signal into decimal and shows the result on the
--Design library where code should be compiled																										7-segment HEX display.
--Analysis dependencies (e.g., included packages or components): N/A
--Initialization of model (e.g., memory initialization file): N/A
--Simulator(s), simulator version(s), and platform(s) used: ModelSim-Altera
--Notes or other items
--Author(s) and contact information: Ziyuan Chen, Nathan Honold
--Revision list containing version number, author(s), dates and description of changes
	--Date of Creation 12/11/2014

library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

entity hex_display is
port (
	bcd: in std_logic_vector (7 downto 0);
	d0: out std_logic_vector (0 to 6);
	d1: out std_logic_vector (0 to 6)
);
end entity hex_display;

architecture behavioral of hex_display is		-- converts the score signal into decimal display on 7-segment LEDs
begin
			d0 <= "0000001" when conv_integer(bcd) mod 10 = 0 else
					"1001111" when conv_integer(bcd) mod 10 = 1 else
					"0010010" when conv_integer(bcd) mod 10 = 2 else
					"0000110" when conv_integer(bcd) mod 10 = 3 else
					"1001100" when conv_integer(bcd) mod 10 = 4 else
					"0100100" when conv_integer(bcd) mod 10 = 5 else
					"0100000" when conv_integer(bcd) mod 10 = 6 else
					"0001111" when conv_integer(bcd) mod 10 = 7 else
					"0000000" when conv_integer(bcd) mod 10 = 8 else
					"0000100" when conv_integer(bcd) mod 10 = 9 else "1111111";
					
			d1	<=	"0000001" when conv_integer(bcd) / 10 = 0 else
					"1001111" when conv_integer(bcd) / 10 = 1 else
					"0010010" when conv_integer(bcd) / 10 = 2 else
					"0000110" when conv_integer(bcd) / 10 = 3 else
					"1001100" when conv_integer(bcd) / 10 = 4 else
					"0100100" when conv_integer(bcd) / 10 = 5 else
					"0100000" when conv_integer(bcd) / 10 = 6 else
					"0001111" when conv_integer(bcd) / 10 = 7 else
					"0000000" when conv_integer(bcd) / 10 = 8 else
					"0000100" when conv_integer(bcd) / 10 = 9 else "1111111";
end architecture behavioral;