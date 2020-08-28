----------------------------------------------------------------------------------
-- Company: ENGS 31 20X
-- Engineer: Jai K. Smith
-- 
-- Create Date: 08/24/2020 01:07:02 PM
-- Design Name: ball entity
-- Module Name: ball - Behavioral
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

entity ball is
    Port ( clk      : in std_logic;
           en       : in std_logic;
           home_x   : in std_logic_vector(9 downto 0);
           home_y   : in std_logic_vector(8 downto 0);
           reset    : in std_logic;
           v_x      : in std_logic;
           v_y      : in std_logic;
           v_x_mult : in std_logic_vector(1 downto 0);
           x        : out std_logic_vector(9 downto 0);
           y        : out std_logic_vector(8 downto 0));
end ball;

architecture Behavioral of ball is

-- signals
signal u_x : unsigned(9 downto 0) := (others => '0');
signal u_y : unsigned(8 downto 0) := (others => '0');

begin

step_proc: process(clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            -- home
            u_x <= unsigned(home_x);
            u_y <= unsigned(home_y);
        elsif en = '1' then
            -- update x
            if v_x = '1' then
                u_x <= u_x + 1 + unsigned(v_x_mult);
            else
                u_x <= u_x - 1 - unsigned(v_x_mult);
            end if;
            
            -- update y
            if v_y = '1' then
                u_y <= u_y + 1;
            else
                u_y <= u_y - 1;
            end if;
        end if;
    end if;
end process step_proc;

map_proc: process(u_x, u_y)
begin
    x <= std_logic_vector(u_x);
    y <= std_logic_vector(u_y);
end process map_proc;

end Behavioral;
