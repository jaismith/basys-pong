----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/24/2020 04:10:50 PM
-- Design Name: 
-- Module Name: paddle - Behavioral
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

entity paddle is
    Port ( clk      : in std_logic;
           en       : in std_logic;
           reset    : in std_logic;
           home     : in std_logic_vector (8 downto 0);
           v        : in std_logic;
           y        : out std_logic_vector (8 downto 0));
end paddle;

architecture Behavioral of paddle is

-- signals
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
    if rising_edge(clk) then
        if en = '1' then
            if v = '1' then
                u_y <= u_y + 1;
            else
                u_y <= u_y - 1;
            end if;
        end if;
    end if;
end process step_proc;

map_proc: process(u_y)
begin
    y <= std_logic_vector(u_y);
end process map_proc;

end Behavioral;
