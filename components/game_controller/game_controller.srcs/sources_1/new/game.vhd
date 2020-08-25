----------------------------------------------------------------------------------
-- Company: ENGS 31 20X
-- Engineer: Jai K. Smith
-- 
-- Create Date: 08/24/2020 06:46:17 PM
-- Design Name: game controller
-- Module Name: game - Behavioral
-- Project Name: 20X Pong
-- Target Devices: Diligent Basys3
-- Tool Versions: Vivado 2018.2.2
-- Description: game controller
-- 
-- Dependencies: input_controller, ball, paddle, vga_controller, vga_test_pattern
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


-- TOP LEVEL ENTITY

entity game is
    Port (  mclk            : in std_logic;
            running         : in std_logic;
            reset           : in std_logic;
            
            -- SPI Bus
            spi_sdata_0     : in std_logic;
            spi_sdata_1     : in std_logic;
            spi_sclk        : out std_logic;
            spi_cs          : out std_logic;
            
            -- seven seg (dev)
            seg             : out std_logic_vector(0 to 6);
            dp              : out std_logic;
            an              : out std_logic_vector(3 downto 0);
            
            -- vga
            rgb             : out std_logic_vector(11 downto 0);
            hsync, vsync    : out std_logic );
end game;

architecture Behavioral of game is


-- COMPONENT DECLARATIONS

component input_controller is
    Port (  mclk            : in std_logic;
            spi_sclk        : out std_logic;
            spi_cs          : out std_logic;
            spi_sdata_0     : in std_logic;
            spi_sdata_1     : in std_logic;
            controller_0    : out std_logic_vector(3 downto 0);
            controller_1    : out std_logic_vector(3 downto 0);
            seg             : out std_logic_vector(0 to 6);
            dp              : out std_logic;
            an              : out std_logic_vector(3 downto 0) );
end component;

component ball is
    Port (  clk             : in std_logic;
            en              : in std_logic;
            reset           : in std_logic;
            home_x          : in std_logic_vector(9 downto 0);
            home_y          : in std_logic_vector(8 downto 0);
            v_x             : in std_logic;
            v_y             : in std_logic;
            x               : out std_logic_vector(9 downto 0);
            y               : out std_logic_vector(8 downto 0) );
end component;

component paddle is
    Port (  clk             : in std_logic;
            en              : in std_logic;
            reset           : in std_logic;
            home            : in std_logic_vector(8 downto 0);
            v               : in std_logic_vector(3 downto 0);
            y               : out std_logic_vector(8 downto 0) );
end component;

component vga_controller is
    Port (  mclk            : in std_logic;
            rgb             : out std_logic_vector(11 downto 0);
            hsync, vsync    : out std_logic;
            x               : out std_logic_vector(9 downto 0);
            y               : out std_logic_vector(8 downto 0);
            color           : in std_logic_vector(11 downto 0) );
end component;

component vga_test_pattern is
    Port (  row             : in std_logic_vector(8 downto 0);
            column          : in std_logic_vector(9 downto 0);
            color           : out std_logic_vector(11 downto 0) );
end component;


component collision_detector is
    Port (  clk             : in std_logic;
            check_x         : in std_logic_vector(9 downto 0);
            check_y         : in std_logic_vector(8 downto 0);
            p_width         : in std_logic_vector(1 downto 0);
            p_height        : in std_logic_vector(3 downto 0);
            p1_x            : in std_logic_vector(9 downto 0);
            p1_y            : in std_logic_vector(8 downto 0);
            p2_x            : in std_logic_vector(9 downto 0);
            p2_y            : in std_logic_vector(8 downto 0);
            b_diam          : in std_logic_vector(1 downto 0);
            b_x             : in std_logic_vector(9 downto 0);
            b_y             : in std_logic_vector(8 downto 0);
            p1_collision    : out std_logic;
            p2_collision    : out std_logic;
            ball_collision  : out std_logic;
            top_collision   : out std_logic;
            bottom_collision : out std_logic;
            right_collision : out std_logic;
            left_collision  : out std_logic );
end component;

-- SIGNALS

-- controller
signal controller_0 : std_logic_vector(3 downto 0) := (others => '0');
signal controller_1 : std_logic_vector(3 downto 0) := (others => '0');

-- entities
signal ball_x : std_logic_vector(9 downto 0) := (others => '0');
signal ball_y : std_logic_vector(8 downto 0) := (others => '0');
signal ball_v_x : std_logic := '0';
signal ball_v_y : std_logic := '0';
signal paddle_0_y : std_logic_vector(8 downto 0) := (others => '0');
signal paddle_1_y : std_logic_vector(8 downto 0) := (others => '0');

-- step clk
signal step : std_logic := '0';
signal step_count : integer := 0;

-- vga
signal vga_x : std_logic_vector(9 downto 0) := (others => '0');
signal vga_y : std_logic_vector(8 downto 0) := (others => '0');
signal vga_color : std_logic_vector(11 downto 0) := (others => '0');

-- collision detection signals
signal check_x : std_logic_vector(9 downto 0) := (others => '0');
signal check_y : std_logic_vector(8 downto 0) := (others => '0');
signal paddle_0_collision : std_logic := '0';
signal paddle_1_collision : std_logic := '0';
signal ball_collision : std_logic := '0';
signal top_collision : std_logic := '0';
signal bottom_collision : std_logic := '0';
signal right_collision : std_logic := '0';
signal left_collision : std_logic := '0';


-- CONSTANTS

-- graphics
constant BALL_DIAM : std_logic_vector(1 downto 0) := "11";
constant BALL_HOME_X : std_logic_vector(9 downto 0) := (others => '0');
constant BALL_HOME_Y : std_logic_vector(8 downto 0) := (others => '0');
constant PADDLE_HEIGHT : std_logic_vector(3 downto 0) := "1111";
constant PADDLE_WIDTH : std_logic_vector(1 downto 0) := "11";
constant PADDLE_HOME : std_logic_vector(8 downto 0) := "011110000"; -- 240
constant PADDLE_0_X : std_logic_vector(9 downto 0) := "0001010000"; -- 80
constant PADDLE_1_X : std_logic_vector(9 downto 0) := "1000110000"; -- 560

-- internals
constant STEP_DIV : integer := 10000000; -- 10 Hz step

begin


-- PROCESSES

-- step clk divider
step_proc: process(mclk)
begin
    if rising_edge(mclk) then
        if step_count = (STEP_DIV / 2) - 1 then
            step <= '1';
            step_count <= 0;
        else
            step <= '0';
            step_count <= step_count + 1;
        end if;
    end if;
end process step_proc;


-- COMPONENT INITIALIZATIONS

-- joysticks
INPUT_CONTROLLER_ENT: input_controller port map (
    mclk => mclk,
    spi_sclk => spi_sclk,
    spi_cs => spi_cs,
    spi_sdata_0 => spi_sdata_0,
    spi_sdata_1 => spi_sdata_1,
    controller_0 => controller_0,
    controller_1 => controller_1,
    seg => seg,
    dp => dp,
    an => an );

-- ball
BALL_ENT: ball port map (
    clk => mclk,
    en => step,
    reset => reset,
    home_x => BALL_HOME_X,
    home_y => BALL_HOME_Y,
    v_x => ball_v_x,
    v_y => ball_v_y,
    x => ball_x,
    y => ball_y );
    
-- left paddle
PADDLE_0_ENT: paddle port map (
    clk => mclk,
    en => step,
    reset => reset,
    home => PADDLE_HOME,
    v => controller_0,
    y => paddle_0_y );
    
-- right paddle
PADDLE_1_ENT: paddle port map (
    clk => mclk,
    en => step,
    reset => reset,
    home => PADDLE_HOME,
    v => controller_1,
    y => paddle_1_y );

-- vga output
VGA_ENT: vga_controller port map (
    mclk => mclk,
    rgb => rgb,
    hsync => hsync,
    vsync => vsync,
    x => vga_x,
    y => vga_y,
    color => vga_color );

-- vga test pattern
VGA_TEST_ENT: vga_test_pattern port map (
    row => vga_y,
    column => vga_x,
    color => vga_color );

-- collision detector
COLLISION_DETECTOR_ENT: collision_detector port map (
    clk => mclk,
    check_x => check_x,
    check_y => check_y,
    p_width => PADDLE_WIDTH,
    p_height => PADDLE_HEIGHT,
    p1_x => PADDLE_0_X,
    p1_y => paddle_0_y,
    p2_x => PADDLE_1_X,
    p2_y => paddle_1_y,
    b_diam => BALL_DIAM,
    b_x => ball_x,
    b_y => ball_y,
    p1_collision => paddle_0_collision,
    p2_collision => paddle_1_collision,
    ball_collision => ball_collision,
    top_collision => top_collision,
    bottom_collision => bottom_collision,
    right_collision => right_collision,
    left_collision => left_collision );


end Behavioral;
