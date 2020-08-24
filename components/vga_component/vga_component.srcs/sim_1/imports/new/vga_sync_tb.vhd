----------------------------------------------------------------------------------
-- Company: ENGS 031 - 20 X
-- Engineer: Yunive Avendaño
-- 
-- Create Date: 08/24/2020 01:47:44 AM
-- Design Name: 
-- Module Name: vga_sync_tb - Behavioral
-- Project Name: PONG
-- Target Devices: BASYS 3 Board
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
-- Monopulser testbench
-- E.W. Hansen, Engs 31 20X
library IEEE;
use IEEE.std_logic_1164.all;

entity vga_sync_tb is
end vga_sync_tb;

architecture testbench of vga_sync_tb is

component vga_sync is
	port(clk: 		   in  std_logic;
    	 pixel_x, pixel_y: out  std_logic_vector( 9 downto 0);
     
         hsync:            out std_logic;
         vsync:            out std_logic);
end component;

constant clk_period: time := 1ns; --25 MHz
signal clk: std_logic := '1';
signal pixel_x, pixel_y: std_logic_vector(9 downto 0) := (others => '0');
signal  hsync, vsync: std_logic := '0';

begin

dut: vga_sync port map(
		clk => clk,
        pixel_x => pixel_x,
        pixel_y => pixel_y,
        hsync => hsync,
        vsync => vsync);
        
clock_proc: process
begin
	clk <= not(clk);
    wait for clk_period/2;
end process clock_proc;

stim_proc: process
begin
	wait;
end process stim_proc;

end testbench;