----------------------------------------------------------------------------------
-- Company: ENGS 031 - 20 X
-- Engineer: Yunive Avendaño
-- 
-- Create Date: 08/23/2020 11:03:21 PM
-- Design Name: 
-- Module Name: vga_sync - Behavioral
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
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_sync is
    port(   clk:              in std_logic; --25 Mhz clock
            pixel_x, pixel_y: out  std_logic_vector( 9 downto 0);
--            video_on:         out std_logic;
            hsync:            out std_logic;
            vsync:            out std_logic);
end vga_sync;

architecture Behavioral of vga_sync is
--CONSTANTS
constant H_FRONT_PORCH: integer := 16;
constant H_SYNC_PULSE: integer := 96;
constant H_BACK_PORCH: integer := 48;
constant H_ACTIVE: integer := 640;

constant V_FRONT_PORCH: integer := 11;
constant V_SYNC_PULSE: integer := 2;
constant V_BACK_PORCH: integer := 31;
constant V_ACTIVE: integer := 480;

--STATE VARIABLES
signal uh_count, uv_count: unsigned(9 downto 0) := (others => '0');
signal ux,uy: unsigned(9 downto 0) :=  (others => '0');

--signal vblank, hblank: std_logic := '1';
signal h_CE: std_logic:= '0';--indicates end of horizontal counting

begin 

--horizontal counter   
h_counter: process(clk, h_CE, uh_count)
begin
    -- counter functionality
    if rising_edge(clk) then
       
        --inside active pixels
        if  uh_count < (H_ACTIVE) - 1 then
--            hblank <= '0';
            ux <= ux + 1; -- x pixel count
--        else
--            hblank <= '1';
        end if;
        
        --increment
        uh_count <= uh_count + 1;
        
        --loop count at pixel 799
        if uh_count = (H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH + H_ACTIVE) - 1 then
            uh_count <= (others => '0');
            ux <= (others =>'0');
            h_CE <= '1';
         else
            h_CE <= '0';
        end if;
     end if;
     
    --inside sync area check
    if  uh_count > (H_FRONT_PORCH + H_ACTIVE) - 2 AND uh_count < (H_FRONT_PORCH + H_ACTIVE + H_SYNC_PULSE) - 1  then
        hsync <= '0';
    else 
        hsync <= '1';
    end if;  
end process h_counter;

--vertical counter
v_counter: process(clk, h_CE, uv_count)
begin
     --counter functionality
     if rising_edge(clk) then
         --increment vertical row
         if h_CE='1' then    
             --inside active pixels
             if  uv_count < (V_ACTIVE) - 1 then
--                 vblank <= '0';
                 uy <= uy + 1; -- x pixel count
--             else
--                 vblank <= '1';
             end if;
            --increment
            uv_count <= uv_count + 1;
         end if;
         
        --loop count at pixel 524 and 
        if uv_count = (V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH + V_ACTIVE) - 1 then
           uv_count <= (others => '0');
           uy <= (others =>'0');
        end if;
    end if;
    
    --inside sync area check
    if  uv_count > (V_ACTIVE + V_FRONT_PORCH) - 2 AND uv_count < (V_ACTIVE + V_SYNC_PULSE + V_FRONT_PORCH) - 1  then
        vsync <= '0';
    else 
        vsync <= '1';
    end if;  
    
--    --enable video, if appropriate
--    if hblank = '0' AND vblank = '0' then
--        video_on <= '1';
--    else
--        video_on <= '0';
--    end if;

end process v_counter;



pixel_x <= std_logic_vector(ux);
pixel_y <= std_logic_vector(uy);

end Behavioral;
