----------------------------------------------------------------------------------
-- Company: ENGS 31 20X
-- Engineer: Jai K. Smith
-- 
-- Create Date: 08/06/2020 09:28:28 PM
-- Design Name: Digital Filter
-- Module Name: filter - Behavioral
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
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity digital_filter is
  port (clk:			in	std_logic;
  		take_sample:  	in	std_logic; 
		x:				in std_logic_vector(11 downto 0);
        y:				out std_logic_vector(11 downto 0) );
end digital_filter;

architecture behavior of digital_filter is

-- signals
signal sum: unsigned(17 downto 0) := (others => '0');
signal count: unsigned(5 downto 0) := (others => '0');
signal tc: std_logic := '0';

begin

-- count proc
counter: process(clk, count, tc, take_sample)
begin
	if rising_edge(clk) then
        if count = 63 then
            count <= (others => '0');
        else
            if take_sample = '1' then
                count <= count + 1;
            end if;
        end if;
	end if;
	
	if count = 63 then
	   tc <= '1';
    else
        tc <= '0';
    end if;
end process counter;

-- avg proc
avg: process(clk, tc, sum, x, take_sample)
begin
	if rising_edge(clk) then
    	if tc = '1' then
        	y <= std_logic_vector(sum(17 downto 6));
            sum <= "000000" & unsigned(x);
        end if;
        
        if take_sample = '1' then
            sum <= sum + unsigned(x);
        end if;
    end if;
end process avg;

end behavior;
