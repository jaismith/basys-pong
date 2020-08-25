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


-- ENTITY DECLARATION

entity vga_controller is
    port(   mclk           : in std_logic;
            rgb            : out std_logic_vector( 11 downto 0 );
            hsync, vsync   : out std_logic;
            x              : out std_logic_vector(9 downto 0);
            y              : out std_logic_vector(8 downto 0);
            color          : in std_logic_vector(11 downto 0) );
end vga_controller;

architecture Behavioral of vga_controller is


-- COMPONENT DECLARATION

component vga_sync is
	port(clk:              in std_logic; --25 Mhz clock
         pixel_x, pixel_y: out  std_logic_vector( 9 downto 0); 
         video_on:         out std_logic;
         hsync, vsync:     out std_logic);
end component;

component vga_test_pattern is
	port( row, column			: in  std_logic_vector( 9 downto 0);
		  color				    : out std_logic_vector(11 downto 0));
end component;


-- SIGNALS

-- Signals for the clock divider, which divides the master clock down to 25 MHz
constant CLOCK_DIVIDER_VALUE: integer := 2;  
signal rclkdiv: unsigned(22 downto 0) := (others => '0');    -- clock divider counter
signal rclkdiv_tog: std_logic := '0';                        -- terminal count
signal rclk: std_logic := '0';

--Interconnecting Signals
signal video_on: std_logic := '1';


begin


-- PROCESSES

-- Clock buffer for the 25 MHz clock
-- The BUFG component puts the slow clock onto the FPGA clocking network
slow_clock_buffer: BUFG
      port map (I => rclkdiv_tog,
                O => rclk );

clock_divider: process(mclk)
begin
    if rising_edge(mclk) then
           if rclkdiv = CLOCK_DIVIDER_VALUE-1 then
               rclkdiv_tog <= NOT(rclkdiv_tog);        -- T flip flop
            rclkdiv <= (others => '0');
        else
            rclkdiv <= rclkdiv + 1;                 -- Counter
        end if;
    end if;
end process clock_divider;

video_enabler: process(mclk)
begin  
    if rising_edge(mclk) then
        if video_on = '1' then
            rgb <= color;
        else
            rgb <= "000000000000"; -- set to black if outside active area
        end if;
    end if;
end process video_enabler;


-- COMPONENT INITIALIZATION

-- VGA Sync:
sync: vga_sync port map(
            clk => rclk, 
            pixel_x => x, 
            pixel_y => y, 
            video_on => video_on, 
            hsync => hsync, 
            vsync => vsync);

end Behavioral;
