----------------------------------------------------------------------------------
-- Company: ENGS 31 20X
-- Engineer: Jai K. Smith
-- 
-- Create Date: 08/24/2020 01:07:02 PM
-- Design Name: paddle entity testbench
-- Module Name: paddle - tb
-- Project Name: 20X Pong
-- Target Devices: Diligent Basys3 (Artix 7)
-- Tool Versions: Vivado 2018.2.2
-- Description: paddle entity controller testbench
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

entity paddle_tb is
end paddle_tb;

architecture Behavioral of paddle_tb is

component paddle
    port (  clk : in std_logic;
            en : in std_logic;
            reset : in std_logic;
            home : in std_logic_vector(8 downto 0);
            v : in std_logic_vector(3 downto 0);
            y : out std_logic_vector(8 downto 0));
end component;

-- inputs
signal clk : std_logic := '0';
signal en : std_logic := '1';
signal home : std_logic_vector(8 downto 0) := (others => '0');
signal reset : std_logic := '0';

-- outputs
signal v : std_logic_vector(3 downto 0) := "0100";
signal y : std_logic_vector(8 downto 0) := (others => '0');

-- constants
constant clk_period : time := 1us;

begin

uut: paddle port map(
    clk => clk,
    en => en,
    home => home,
    reset => reset,
    v => v,
    y => y );
    
-- clock process
clk_proc: process
begin
    clk <= '0';
    wait for clk_period / 2;
    clk <= '1';
    wait for clk_period / 2;
end process clk_proc;

-- stimulus
stim_proc: process
begin
    wait for 2.5 * clk_period;
    
    reset <= '1';
    wait for 1 * clk_period;
    
    reset <= '0';
    wait;
end process stim_proc;

end Behavioral;
