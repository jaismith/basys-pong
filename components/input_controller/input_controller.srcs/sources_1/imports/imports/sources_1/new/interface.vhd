----------------------------------------------------------------------------------
-- Company: 
-- Engineer:  
-- Create Date: 08/07/2020 03:22:57 AM
-- Design Name: 
-- Module Name: interface - Behavioral
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

entity interface is
  port ( sclk:		in	std_logic;
  		 spi_sdata:	in	std_logic; 
         shift_en:	in	std_logic;
         load_en:	in	std_logic;
		 ad_data:	out std_logic_vector(11 downto 0) );
end interface;

architecture behavior of interface is
-- signals
signal ser_data_reg:	unsigned(11 downto 0) := "000000000000";

begin

-- shift reg
shift_reg: process(sclk, spi_sdata, shift_en)
begin
	if rising_edge(sclk) then
		if shift_en = '1' then
        	ser_data_reg <= ser_data_reg(10 downto 0) & spi_sdata;
        end if;
	end if;
end process shift_reg;

-- output reg
output_reg: process(sclk, load_en)
begin
	if rising_edge(sclk) then
    	if load_en = '1' then
        	ad_data <= std_logic_vector(ser_data_reg);
    	end if;
    end if;
end process output_reg;

end behavior;

