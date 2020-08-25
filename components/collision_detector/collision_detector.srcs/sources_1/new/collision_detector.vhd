----------------------------------------------------------------------------------
-- Company: ENGS 31 20X
-- Engineer: Yunive Avenda�o
-- Create Date: 08/24/2020 01:07:02 PM
-- Design Name: Collision Detector
-- Module Name: collision_detector - Behavioral
-- Project Name: 20X Pong
-- Target Devices: Diligent Basys3 (Artix 7)
-- Tool Versions: Vivado 2018.2.2
-- Description: ball entity controller
-- 
-- Dependencies: n/a
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity collison_detector is
    Port ( clk      : in std_logic;
    
           -- coordinates to be checked
           check_x  : in std_logic_vector(9 downto 0);
           check_y  : in std_logic_vector(8 downto 0);
           
           -- paddles
           p_width : in std_logic_vector(1 downto 0);
           p_height: in std_logic_vector(3 downto 0);
           p1_x     : in std_logic_vector(9 downto 0);
           p1_y     : in std_logic_vector(8 downto 0);
           p2_x     : in std_logic_vector(9 downto 0);
           p2_y     : in std_logic_vector(8 downto 0);
           
           -- ball
           b_diam   : in std_logic_vector(1 downto 0);
           b_x      : in std_logic_vector(9 downto 0);
           b_y      : in std_logic_vector(8 downto 0);
           
           -- collisions
           p1_collision     : out std_logic;
           p2_collision     : out std_logic;
           ball_collision   : out std_logic;
           top_collision    : out std_logic;
           bottom_collision  : out std_logic;
           right_collision  : out std_logic;
           left_collision   : out std_logic);
end collison_detector;

architecture Behavioral of collison_detector is

-- SIGNALS

-- CONSTANTS

--graphics
constant X_ACTIVE : integer := 640;
constant Y_ACTIVE : integer := 480;
-- collisions

-- PROCESSES

begin
check_col: process(clk)
begin 
    if rising_edge(clk) then
        -- DEFAULT COLLISION VALUES
          p1_collision     <= '0';
          p2_collision     <= '0';
          ball_collision   <= '0';
          top_collision    <= '0';
          bottom_collision <= '0';
          right_collision  <= '0';
          left_collision   <= '0';
           
        -- BORDER COLLISIONS
        
        -- ball collisions
        if b_x = "0000000000" then
            left_collision <= '1';
            ball_collision <= '1';
        elsif b_y = "000000000" then
            top_collision <= '1';
            ball_collision <= '1';
        elsif unsigned(b_x) + unsigned(b_diam) = X_ACTIVE - 1 then
            right_collision <= '1';
            ball_collision <= '1';
        elsif unsigned(b_y) + unsigned(b_diam) = Y_ACTIVE - 1 then
            bottom_collision <= '1';
            ball_collision <= '1';
            
        -- paddle 1 collisions
         elsif p1_y = "000000000" then
            top_collision <= '1';
            p1_collision <= '1';
         elsif unsigned(p1_y) + unsigned(p_height) = Y_ACTIVE - 1 then
            bottom_collision <= '1';
            p1_collision <= '1';
            
         -- paddle 2 collisions
         elsif p2_y = "000000000" then
             top_collision <= '1';
             p1_collision <= '1';
         elsif unsigned(p2_y) + unsigned(p_height) = Y_ACTIVE - 1 then
             bottom_collision <= '1';
             p1_collision <= '1';
             
        -- object collsions
        elsif unsigned(b_x) = unsigned(p1_x) + unsigned(p_width) + 1 then
            if unsigned(b_y) <=  unsigned(p1_x) + unsigned(p_height) and unsigned(b_y) >=  unsigned(p1_x) - unsigned(p_height) then
                ball_collision <= '1';
                p1_collision <= '1';
            end if;
         elsif unsigned(b_x) + unsigned(b_diam) = unsigned(p2_x) - unsigned(p_width) - 1 then
            if unsigned(b_y) <=  unsigned(p1_x) + unsigned(p_height) and unsigned(b_y) >=  unsigned(p1_x) - unsigned(p_height) then
                ball_collision <= '1';
                p1_collision <= '1';
            end if;
        end if;  
    end if;
end process check_col;

end Behavioral;