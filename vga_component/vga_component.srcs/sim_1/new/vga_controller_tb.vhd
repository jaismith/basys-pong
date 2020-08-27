----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/24/2020 03:24:14 AM
-- Design Name: 
-- Module Name: vga_controller_tb - Behavioral
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

entity vga_controller_tb is
end vga_controller_tb;

architecture testbench of vga_controller_tb is

component vga_controller is
	port(   clk:   in std_logic;
--          data:  in std_logic; -- not needed for sample
            rgb:   out std_logic_vector( 11 downto 0 );
            hsync: out std_logic;
            vsync: out std_logic);
end component;

constant clk_period: time := 10 ns; --100 Mhz
signal clk, hsync, vsync: std_logic := '0';
signal rgb: std_logic_vector( 11 downto 0 );

begin
dut: vga_controller port map(
		clk => clk,
        rgb => rgb,
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
