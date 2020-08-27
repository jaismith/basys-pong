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


-- ENTITY DECLARATION

entity collision_detector is
    Port ( clk              : in std_logic;
    
           -- coordinates to be checked
           check_x          : in std_logic_vector(9 downto 0);
           check_y          : in std_logic_vector(8 downto 0);
           check_w          : in std_logic_vector(1 downto 0);
           check_h          : in std_logic_vector(3 downto 0);
           
           -- paddles
           p_width          : in std_logic_vector(1 downto 0);
           p_height         : in std_logic_vector(3 downto 0);
           p1_x             : in std_logic_vector(9 downto 0);
           p1_y             : in std_logic_vector(8 downto 0);
           p2_x             : in std_logic_vector(9 downto 0);
           p2_y             : in std_logic_vector(8 downto 0);
           
           -- ball
           b_diam           : in std_logic_vector(1 downto 0);
           b_x              : in std_logic_vector(9 downto 0);
           b_y              : in std_logic_vector(8 downto 0);
           
           -- collisions
           p1_collision     : out std_logic;
           p2_collision     : out std_logic;
           ball_collision   : out std_logic;
           top_collision    : out std_logic;
           bottom_collision : out std_logic;
           right_collision  : out std_logic;
           left_collision   : out std_logic);
end collision_detector;

architecture Behavioral of collision_detector is


begin


-- PROCESSES

check_col: process(clk)
begin 
    if rising_edge(clk) then
        -- DEFAULT COLLISION VALUES
        p1_collision     <= '1';
        p2_collision     <= '1';
        ball_collision   <= '1';
        top_collision    <= '0';
        bottom_collision <= '0';
        right_collision  <= '0';
        left_collision   <= '0';

        -- BORDER COLLISIONS
  
        if unsigned(check_y) <= 1 then
            top_collision <= '1';
        end if;
        if unsigned(check_y) + unsigned(check_h) >= 479 then
            bottom_collision <= '1';
        end if;
        if unsigned(check_x) + unsigned(check_w) >= 639 then
            right_collision <= '1';
        end if;
        if unsigned(check_x) <= 0 then
            left_collision <= '1';
        end if;

        -- OBJECT COLLISIONS
        
        -- ball
        if unsigned(b_x) + unsigned(b_diam) < unsigned(check_x)
            or unsigned(b_x) > unsigned(check_x) + unsigned(check_w) - 1 then
            ball_collision <= '0';
        end if;
        if unsigned(b_y) + unsigned(b_diam) < unsigned(check_y)
            or unsigned(b_y) > unsigned(check_y) + unsigned(check_h) - 1 then
            ball_collision <= '0';
        end if;
        
        -- paddle 1
        if unsigned(p1_x) + unsigned(p_width) < unsigned(check_x)
            or unsigned(p1_x) > unsigned(check_x) + unsigned(check_w) - 1 then
            p1_collision <= '0';
        end if;
        if unsigned(p1_y) + unsigned(p_height) < unsigned(check_y)
            or unsigned(p1_y) > unsigned(check_y) + unsigned(check_h) - 1 then
            p1_collision <= '0';
        end if;
        
        -- paddle 2
        if unsigned(p2_x) + unsigned(p_width) < unsigned(check_x)
            or unsigned(p2_x) > unsigned(check_x) + unsigned(check_w) - 1 then
            p2_collision <= '0';
        end if;
        if unsigned(p2_y) + unsigned(p_height) < unsigned(check_y)
            or unsigned(p2_y) > unsigned(check_y) + unsigned(check_h) - 1 then
            p2_collision <= '0';
        end if;

    end if;
end process check_col;

end Behavioral;