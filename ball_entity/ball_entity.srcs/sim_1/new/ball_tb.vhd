----------------------------------------------------------------------------------
-- Company: ENGS 31 20X
-- Engineer: Jai K. Smith
-- 
-- Create Date: 08/24/2020 01:07:02 PM
-- Design Name: ball entity testbench
-- Module Name: ball - tb
-- Project Name: 20X Pong
-- Target Devices: Diligent Basys3 (Artix 7)
-- Tool Versions: Vivado 2018.2.2
-- Description: ball entity controller testbench
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

entity ball_tb is
end ball_tb;

architecture Behavioral of ball_tb is

component ball
    port (  clk : in std_logic;
            en : in std_logic;
            home_x : in std_logic_vector(9 downto 0);
            home_y : in std_logic_vector(8 downto 0);
            reset : in std_logic;
            v_x : in std_logic;
            v_y : in std_logic;
            x : out std_logic_vector(9 downto 0);
            y : out std_logic_vector(8 downto 0));
end component;

-- inputs
signal clk : std_logic := '0';
signal en : std_logic := '1';
signal home_x : std_logic_vector(9 downto 0) := (others => '0');
signal home_y : std_logic_vector(8 downto 0) := (others => '0');
signal reset : std_logic := '0';
signal v_x : std_logic := '1';
signal v_y : std_logic := '1';

-- outputs
signal x : std_logic_vector(9 downto 0);
signal y : std_logic_vector(8 downto 0);

-- constants
constant clk_period : time := 1us;

begin

uut: ball port map(
    clk => clk,
    en => en,
    home_x => home_x,
    home_y => home_y,
    reset => reset,
    v_x => v_x,
    v_y => v_y,
    x => x,
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
