----------------------------------------------------------------------------------
-- Company: ENGS 31 20X
-- Engineer: Jai K. Smith
-- 
-- Create Date: 08/24/2020 01:07:02 PM
-- Design Name: paddle entity
-- Module Name: paddle - Behavioral
-- Project Name: 20X Pong
-- Target Devices: Diligent Basys3 (Artix 7)
-- Tool Versions: Vivado 2018.2.2
-- Description: paddle entity controller
-- 
-- Dependencies: n/a
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity paddle is
    Port ( clk      : in std_logic;
           en       : in std_logic;
           reset    : in std_logic;
           home     : in std_logic_vector (8 downto 0);
           v        : in std_logic_vector(3 downto 0);
           y        : out std_logic_vector (8 downto 0));
end paddle;

architecture Behavioral of paddle is

-- signals
signal u_v : unsigned(3 downto 0) := (others => '0');
signal u_y : unsigned(8 downto 0) := (others => '0');

begin

reset_proc: process(clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            u_y <= unsigned(home);
        end if;
    end if;
end process reset_proc;

step_proc: process(clk)
begin
    u_v <= unsigned(v);

    if rising_edge(clk) then
        if en = '1' then
            if u_v < 4 then
                u_y <= u_y + (4 - u_v);
            elsif u_v > 4 then
                u_y <= u_y - (u_v - 4);
            end if;
        end if;
    end if;
end process step_proc;

map_proc: process(u_y)
begin
    y <= std_logic_vector(u_y);
end process map_proc;

end Behavioral;
