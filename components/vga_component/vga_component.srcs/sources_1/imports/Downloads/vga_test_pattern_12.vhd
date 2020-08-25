----------------------------------------------------------------------------------
-- Engineer:		E.W. Hansen, after an original design by J. Graham Keggi
-- 
-- Create Date:	15:10:36 07/12/2010 
-- Module Name:	vga_test_pattern - Behavioral
-- Target Device:	Basys 3 (Artix 7)
--
-- Description:	 Lookup table, receives 10 bit pixel address for 640x480 VGA display
--		and outputs 12-bit SMPTE test pattern
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_test_pattern is
	port(	row             : in std_logic_vector(8 downto 0);
	        column			: in std_logic_vector(9 downto 0);
			color			: out std_logic_vector(11 downto 0) );
end vga_test_pattern;

architecture Behavioral of vga_test_pattern is
	
	-- Predefined 12-bit colors that nearly match real test pattern colors
	-- SMPTE 75% color bars
    constant WHITE      : std_logic_vector(11 downto 0) := "110011001100";
    constant YELLOW     : std_logic_vector(11 downto 0) := "110011000000";
    constant CYAN       : std_logic_vector(11 downto 0) := "000011001100";
    constant GREEN      : std_logic_vector(11 downto 0) := "000011000000";
    constant MAGENTA    : std_logic_vector(11 downto 0) := "110000001100";
    constant RED        : std_logic_vector(11 downto 0) := "110000000000";
    constant BLUE       : std_logic_vector(11 downto 0) := "000000001100";

    constant WHITE100   : std_logic_vector(11 downto 0) := "111111111111";  -- 100% white
    constant BLACK      : std_logic_vector(11 downto 0) := "000000000000";
    constant BLACK75    : std_logic_vector(11 downto 0) := "000100010001";  -- 7.5% black
    constant GRAY0      : std_logic_vector(11 downto 0) := "010001000100";
    constant GRAY1      : std_logic_vector(11 downto 0) := "100010001000";
    constant DARK_BLU   : std_logic_vector(11 downto 0) := "000001001000";
    constant DARK_PUR   : std_logic_vector(11 downto 0) := "010000001000";

	signal urow : unsigned(8 downto 0);
	signal ucolumn : unsigned(9 downto 0);
	
begin

urow <= unsigned(row); 
ucolumn <= unsigned(column);

pixel_color: process(urow, ucolumn)
begin	
		-- large vertical color bands, evenly spaced horizontally, 320px vertically
		-- Gray, yellow, cyan, green, purple, red, blue
		if (ucolumn >= 0) and (ucolumn < 92) and (urow >= 0) and (urow < 320) then
			color <= WHITE;
		elsif (ucolumn >= 92) and (ucolumn < 184) and (urow >= 0) and (urow < 320) then
			color <= YELLOW;
		elsif (ucolumn >= 184) and (ucolumn < 276) and (urow >= 0) and (urow < 320) then
			color <= CYAN;
		elsif (ucolumn >= 276) and (ucolumn < 368) and (urow >= 0) and (urow < 320) then
			color <= GREEN;
		elsif (ucolumn >= 368) and (ucolumn < 460) and (urow >= 0) and (urow < 320) then
			color <= MAGENTA;
		elsif (ucolumn >= 460) and (ucolumn < 552) and (urow >= 0) and (urow < 320) then
			color <= RED;
		elsif (ucolumn >= 552) and (ucolumn <= 640) and (urow >= 0) and (urow < 320) then
			color <= BLUE;
			
		-- small colored rectangles from 320->360 pixels, evenly spaced horizontally
		-- blue, black, purple, black, cyan, black, gray
		elsif (ucolumn >= 0) and (ucolumn < 92) and (urow >= 320) and (urow < 360) then
			color <= BLUE;
		elsif (ucolumn >= 92) and (ucolumn < 184) and (urow >= 320) and (urow < 360) then
			color <= BLACK;
		elsif (ucolumn >= 184) and (ucolumn < 276) and (urow >= 320) and (urow < 360) then
			color <= MAGENTA;
		elsif (ucolumn >= 276) and (ucolumn < 368) and (urow >= 320) and (urow < 360) then
			color <= BLACK;
		elsif (ucolumn >= 368) and (ucolumn < 460) and (urow >= 320) and (urow < 360) then
			color <= CYAN;
		elsif (ucolumn >= 460) and (ucolumn < 552) and (urow >= 320) and (urow < 360) then
			color <= BLACK;
		elsif (ucolumn >= 552) and (ucolumn <= 640) and (urow >= 320) and (urow < 360) then
			color <= WHITE;
			
		-- bottom large blocks
		elsif (ucolumn >= 0) and (ucolumn < 114) and (urow >= 360) and (urow <= 480) then
			color <= DARK_BLU;
		elsif (ucolumn >=114) and (ucolumn < 228) and (urow >= 360) and (urow <= 480) then
			color <= WHITE100;
		elsif (ucolumn >= 228) and (ucolumn < 342) and (urow >= 360) and (urow <= 480) then
			color <= DARK_PUR;
		elsif (ucolumn >= 342) and (ucolumn < 460) and (urow >= 360) and (urow <= 480) then
			color <= BLACK75; 
	    -- vertical pluge pattern
		elsif (ucolumn >= 460) and (ucolumn < 491) and (urow >= 360) and (urow <= 480) then
			color <= BLACK;
		elsif (ucolumn >= 491) and (ucolumn < 521) and (urow >= 360) and (urow <= 480) then
			color <= GRAY0;
		elsif (ucolumn >= 521) and (ucolumn < 552) and (urow >= 360) and (urow <= 480) then
			color <= GRAY1;
		elsif (ucolumn >= 552) and (ucolumn <= 640) and (urow >= 360) and (urow <= 480) then
			color <= BLACK75;
					
		-- black for any gaps, shouldn't be any
		else
			color <= BLACK;
		end if;
end process pixel_color;

end Behavioral;
