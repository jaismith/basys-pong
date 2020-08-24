----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/24/2020 02:17:47 AM
-- Design Name: 
-- Module Name: vga_controller - Behavioral
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
library UNISIM;
use UNISIM.VComponents.all;


entity vga_controller is
    port(clk:   in std_logic;
         rgb:   out std_logic_vector( 11 downto 0 );
         hsync: out std_logic;
         vsync: out std_logic);
end vga_controller;

architecture Behavioral of vga_controller is
component vga_sync is
	port(clk:              in std_logic; --25 Mhz clock
         pixel_x, pixel_y: out  std_logic_vector( 9 downto 0); 
         hsync:            out std_logic;
         vsync:            out std_logic);
end component;

component vga_test_pattern is
	port(row, column			: in  std_logic_vector( 9 downto 0);
		 color				    : out std_logic_vector(11 downto 0));
end component;

-- Signals for the clock divider, which divides the master clock down to 25 MHz
constant CLOCK_DIVIDER_VALUE: integer := 100/4;  
signal rclkdiv: unsigned(22 downto 0) := (others => '0');    -- clock divider counter
signal rclkdiv_tog: std_logic := '0';                        -- terminal count
signal rclk: std_logic := '0';

--Interconnecting Signals
signal x, y: std_logic_vector(9 downto 0) := (others => '0'); 

begin
-- Clock buffer for the 25 MHz clock
-- The BUFG component puts the slow clock onto the FPGA clocking network
slow_clock_buffer: BUFG
      port map (I => rclkdiv_tog,
                O => rclk );
clock_divider: process(clk)
begin
    if rising_edge(clk) then
           if rclkdiv = CLOCK_DIVIDER_VALUE-1 then
               rclkdiv_tog <= NOT(rclkdiv_tog);        -- T flip flop
            rclkdiv <= (others => '0');
        else
            rclkdiv <= rclkdiv + 1;                 -- Counter
        end if;
    end if;
end process clock_divider;           
-- VGA Sync:
sync: vga_sync port map(
            clk=>rclk, 
            pixel_x => x, 
            pixel_y => y, 
            hsync=>hsync, 
            vsync=>vsync);
            
-- VGA Test Pattern
pattern: vga_test_pattern port map(
            row=> y, 
            column=>x, 
            color => rgb);
                
end Behavioral;
