library ieee;
use ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

entity conv_score is
	port(
		score_binary: in std_logic_vector(7 downto 0);
		score_address_digit0: out std_logic_vector(5 downto 0);
		score_address_digit1: out std_logic_vector(5 downto 0)
	);
end conv_score;

architecture arch of conv_score is
begin
	process(score_binary)
	begin
		if conv_integer(score_binary(3 downto 0))=0 then
			score_address_digit0<=conv_std_logic_vector(60,6);
		elsif conv_integer(score_binary(3 downto 0))=1 then
			score_address_digit0<=conv_std_logic_vector(61,6);
		elsif conv_integer(score_binary(3 downto 0))=2 then
			score_address_digit0<=conv_std_logic_vector(62,6);
		elsif conv_integer(score_binary(3 downto 0))=3 then
			score_address_digit0<=conv_std_logic_vector(63,6);
		elsif conv_integer(score_binary(3 downto 0))=4 then
			score_address_digit0<=conv_std_logic_vector(64,6);
		elsif conv_integer(score_binary(3 downto 0))=5 then
			score_address_digit0<=conv_std_logic_vector(65,6);
		elsif conv_integer(score_binary(3 downto 0))=6 then
			score_address_digit0<=conv_std_logic_vector(66,6);
		elsif conv_integer(score_binary(3 downto 0))=7 then
			score_address_digit0<=conv_std_logic_vector(67,6);
		elsif conv_integer(score_binary(3 downto 0))=8 then
			score_address_digit0<=conv_std_logic_vector(70,6);
		elsif conv_integer(score_binary(3 downto 0))=9 then
			score_address_digit0<=conv_std_logic_vector(71,6);
		end if;
		
		if conv_integer(score_binary(7 downto 4))=0 then
			score_address_digit1<=conv_std_logic_vector(60,6);
		elsif conv_integer(score_binary(7 downto 4))=1 then
			score_address_digit1<=conv_std_logic_vector(61,6);
		elsif conv_integer(score_binary(7 downto 4))=2 then
			score_address_digit1<=conv_std_logic_vector(62,6);
		elsif conv_integer(score_binary(7 downto 4))=3 then
			score_address_digit1<=conv_std_logic_vector(63,6);
		elsif conv_integer(score_binary(7 downto 4))=4 then
			score_address_digit1<=conv_std_logic_vector(64,6);
		elsif conv_integer(score_binary(7 downto 4))=5 then
			score_address_digit1<=conv_std_logic_vector(65,6);
		elsif conv_integer(score_binary(7 downto 4))=6 then
			score_address_digit1<=conv_std_logic_vector(66,6);
		elsif conv_integer(score_binary(7 downto 4))=7 then
			score_address_digit1<=conv_std_logic_vector(67,6);
		elsif conv_integer(score_binary(7 downto 4))=8 then
			score_address_digit1<=conv_std_logic_vector(70,6);
		elsif conv_integer(score_binary(7 downto 4))=9 then
			score_address_digit1<=conv_std_logic_vector(71,6);
		end if;
end process;
end architecture;