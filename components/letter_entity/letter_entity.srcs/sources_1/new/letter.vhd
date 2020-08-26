----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/25/2020 11:36:15 PM
-- Design Name: 
-- Module Name: letter - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


-- ENTITY DECLARATION

entity letter is
    Port (  char    : in std_logic_vector(5 downto 0);
            bitmap  : out std_logic_vector(24 downto 0) );
end letter;

architecture Behavioral of letter is


-- CONSTANTS

-- bitmaps
constant A      : std_logic_vector(24 downto 0) := "0111010001111111000110001";
constant B      : std_logic_vector(24 downto 0) := "1111010001111101000111110";
constant C      : std_logic_vector(24 downto 0) := "0111110000100001000001111";
constant D      : std_logic_vector(24 downto 0) := "1111010001100011000111110";
constant E      : std_logic_vector(24 downto 0) := "1111110000111001000011111";
constant F      : std_logic_vector(24 downto 0) := "1111110000111001000010000";
constant G      : std_logic_vector(24 downto 0) := "0111110000101101000101111";
constant H      : std_logic_vector(24 downto 0) := "1000110001111111000110001";
constant I      : std_logic_vector(24 downto 0) := "1111111011110111101111111";
constant J      : std_logic_vector(24 downto 0) := "1111100001000011000101110";
constant K      : std_logic_vector(24 downto 0) := "1000110001111101000110001";
constant L      : std_logic_vector(24 downto 0) := "1000010000100001000011111";
constant M      : std_logic_vector(24 downto 0) := "1101110101101011000110001";
constant N      : std_logic_vector(24 downto 0) := "1100110101101011010110011";
constant O      : std_logic_vector(24 downto 0) := "0111010001100011000101110";
constant P      : std_logic_vector(24 downto 0) := "1111010001111101000010000";
constant Q      : std_logic_vector(24 downto 0) := "0111010001100011010101111";
constant R      : std_logic_vector(24 downto 0) := "1111010001111111010010011";
constant S      : std_logic_vector(24 downto 0) := "0111110000011100000111110";
constant T      : std_logic_vector(24 downto 0) := "1111100100001000010000100";
constant U      : std_logic_vector(24 downto 0) := "1000110001100011000101110";
constant V      : std_logic_vector(24 downto 0) := "1000110001010010010100011";
constant W      : std_logic_vector(24 downto 0) := "1000110001101011010111011";
constant X      : std_logic_vector(24 downto 0) := "1000110001011101000110001";
constant Y      : std_logic_vector(24 downto 0) := "1000110001011100010000100";
constant Z      : std_logic_vector(24 downto 0) := "1111100001011101000011111";
constant ZERO   : std_logic_vector(24 downto 0) := "1111110001101011000111111";
constant ONE    : std_logic_vector(24 downto 0) := "0110000100001000010011111";
constant TWO    : std_logic_vector(24 downto 0) := "1111100001111111000011111";
constant THREE  : std_logic_vector(24 downto 0) := "1111100001111110000111111";
constant FOUR   : std_logic_vector(24 downto 0) := "1000110001111110000100001";
constant FIVE   : std_logic_vector(24 downto 0) := "1111110000111110000111111";
constant SIX    : std_logic_vector(24 downto 0) := "1111110000111111000111111";
constant SEVEN  : std_logic_vector(24 downto 0) := "1111100001000110000100001";
constant EIGHT  : std_logic_vector(24 downto 0) := "1111110001111111000111111";
constant NINE   : std_logic_vector(24 downto 0) := "1111110001111110000100001";


begin


-- PROCESSES

map_output: process(char)
begin
    case char is
        when "000000" => bitmap <= ZERO;
        when "000001" => bitmap <= ONE;
        when "000010" => bitmap <= TWO;
        when "000011" => bitmap <= THREE;
        when "000100" => bitmap <= FOUR;
        when "000101" => bitmap <= FIVE;
        when "000110" => bitmap <= SIX;
        when "000111" => bitmap <= SEVEN;
        when "001000" => bitmap <= EIGHT;
        when "001001" => bitmap <= NINE;
        when "001010" => bitmap <= A;
        when "001011" => bitmap <= B;
        when "001100" => bitmap <= C;
        when "001101" => bitmap <= D;
        when "001110" => bitmap <= E;
        when "001111" => bitmap <= F;
        when "010000" => bitmap <= G;
        when "010001" => bitmap <= H;
        when "010010" => bitmap <= I;
        when "010011" => bitmap <= J;
        when "010100" => bitmap <= K;
        when "010101" => bitmap <= L;
        when "010110" => bitmap <= M;
        when "010111" => bitmap <= N;
        when "011000" => bitmap <= O;
        when "011001" => bitmap <= P;
        when "011010" => bitmap <= Q;
        when "011011" => bitmap <= R;
        when "011100" => bitmap <= S;
        when "011101" => bitmap <= T;
        when "011110" => bitmap <= U;
        when "011111" => bitmap <= V;
        when "100000" => bitmap <= W;
        when "100001" => bitmap <= X;
        when "100010" => bitmap <= Y;
        when "100011" => bitmap <= Z;
    end case;
end process map_output;


end Behavioral;
