----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Yunive Avendaño
-- 
-- Create Date: 08/25/2020 06:22:34 PM
-- Design Name: Collision Detector Testbench
-- Module Name: collision_detector_tb - Behavioral
-- Project Name: 20X Pong
-- Target Devices: Diligent Basys3 (Artix 7)
-- Tool Versions: Vivado 2018.2.2
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
use ieee.numeric_std.all;

entity collision_detector_tb is
end collision_detector_tb;

architecture Behavioral of collision_detector_tb is

component collision_detector
    port ( clk      : in std_logic;
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
end component;

--inputs
signal clk : std_logic := '0';

signal check_x : unsigned(9 downto 0) := (others => '0');
signal check_y : unsigned(8 downto 0) := (others => '0');

signal p_width : std_logic_vector(1 downto 0) := "11";
signal p_height : std_logic_vector(3 downto 0) := "1111";
signal p1_x : std_logic_vector(9 downto 0) := "0001010000";
signal p1_y : std_logic_vector(8 downto 0) := (others => '0');
signal p2_x : std_logic_vector(9 downto 0) := "1000110000";
signal p2_y : std_logic_vector(8 downto 0) := (others => '0');
signal b_diam : std_logic_vector(1 downto 0) := "11";
signal b_x : std_logic_vector(9 downto 0) := (others => '0');
signal b_y : std_logic_vector(8 downto 0):= (others => '0');

--outputs
signal p1_collision     : std_logic;
signal p2_collision     :  std_logic;
signal ball_collision   :  std_logic;
signal top_collision    :  std_logic;
signal bottom_collision  :  std_logic;
signal right_collision  :  std_logic;
signal left_collision   :  std_logic;

-- sim vars
signal y_CE: std_logic := '0';

-- constants
constant clk_period : time := 1us;

begin

uut: collision_detector port map(
    clk => clk,
    check_x => std_logic_vector(check_x),
    check_y => std_logic_vector(check_y),
    p_width => p_width,
    p_height => p_height,
    p1_x => p1_x,
    p1_y => p1_y,
    p2_x => p2_x,
    p2_y => p2_y,
    b_diam => b_diam,
    b_x => b_x,
    b_y => b_y,
    p1_collision =>p1_collision,
    p2_collision => p2_collision,
    ball_collision => ball_collision,
    top_collision => top_collision,
    bottom_collision => bottom_collision,
    right_collision => right_collision,
    left_collision => left_collision);

-- clock process
clk_proc: process
begin
    clk <= '0';
    wait for clk_period / 2;
    clk <= '1';
    wait for clk_period / 2;
end process clk_proc;

-- pixel loop
x_pixel_loop: process (clk)
begin
    if rising_edge(clk) then
        --loop x
        if check_x = 639 then
            check_x <= (others => '0');
            y_CE <= '1';
        else
            y_CE <= '0';
        end if;
        --increment
        check_x <= check_x + 1;
    end if;
           
end process x_pixel_loop;

y_pixel_loop: process (clk)
begin
    if rising_edge(clk) then
        if y_CE = '1' then 
            --loop x
            if unsigned(check_y) = 479 then
                check_y <= (others => '0');
            end if;
            --increment
            check_y <=check_y + 1;
        end if;
    end if;
end process y_pixel_loop;
-- stimulus
stim_proc: process
begin
    wait for 150000* clk_period;
    check_x <= unsigned(p1_x) - 10;
    check_y <= unsigned(p1_y);
    
    b_x <= p1_x;
    b_y <= p1_y;
    wait for 150000* clk_period;
    wait;
end process stim_proc;


end Behavioral;
