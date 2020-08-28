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
            mreset          : in std_logic;
            start           : in std_logic;

            -- SPI Bus
            spi_sdata_0     : in std_logic;
            spi_sdata_1     : in std_logic;
            spi_sclk        : out std_logic;
            spi_cs          : out std_logic;
            
            -- seven seg (dev)
            seg             : out std_logic_vector(0 to 6);
            dp              : out std_logic;
            an              : out std_logic_vector(3 downto 0);
            
            --score
            score_p_0       : out std_logic_vector(3 downto 0);
            score_p_1       : out std_logic_vector(3 downto 0);
                    
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
            height          : in std_logic_vector(5 downto 0);
            v               : in std_logic_vector(3 downto 0);
            y               : out std_logic_vector(8 downto 0) );
end component;

component vga_controller is
    Port (  mclk            : in std_logic;
            rgb             : out std_logic_vector(11 downto 0);
            hsync, vsync    : out std_logic;
            x               : out std_logic_vector(9 downto 0);
            y               : out std_logic_vector(9 downto 0);
            color           : in std_logic_vector(11 downto 0) );
end component;

component collision_detector is
    Port (  clk             : in std_logic;
            check_x         : in std_logic_vector(9 downto 0);
            check_y         : in std_logic_vector(8 downto 0);
            check_w         : in std_logic_vector(3 downto 0);
            check_h         : in std_logic_vector(3 downto 0);
            p_width         : in std_logic_vector(3 downto 0);
            p_height        : in std_logic_vector(5 downto 0);
            p1_x            : in std_logic_vector(9 downto 0);
            p1_y            : in std_logic_vector(8 downto 0);
            p2_x            : in std_logic_vector(9 downto 0);
            p2_y            : in std_logic_vector(8 downto 0);
            b_diam          : in std_logic_vector(3 downto 0);
            b_x             : in std_logic_vector(9 downto 0);
            b_y             : in std_logic_vector(8 downto 0);
            score_0_0_x : in std_logic_vector(9 downto 0);
            score_0_1_x : in std_logic_vector(9 downto 0);
            score_1_0_x : in std_logic_vector(9 downto 0);
            score_1_1_x : in std_logic_vector(9 downto 0);
            score_y : in std_logic_vector(8 downto 0);
            score_0_0_bitmap : in std_logic_vector(24 downto 0);
            score_0_1_bitmap : in std_logic_vector(24 downto 0);
            score_1_0_bitmap : in std_logic_vector(24 downto 0);
            score_1_1_bitmap : in std_logic_vector(24 downto 0);
            p1_collision    : out std_logic;
            p2_collision    : out std_logic;
            ball_collision  : out std_logic;
            top_collision   : out std_logic;
            bottom_collision : out std_logic;
            right_collision : out std_logic;
            left_collision  : out std_logic;
            score_0_0_collision : out std_logic;
            score_0_1_collision : out std_logic;
            score_1_0_collision : out std_logic;
            score_1_1_collision : out std_logic;
            divider_collision : out std_logic;
            greeting_collision: out std_logic;
            game_over_collision: out std_logic );
end component;

component letter is
    Port (  char            : in std_logic_vector(5 downto 0);
            bitmap          : out std_logic_vector(24 downto 0) );
end component;


-- TYPES

type step_statetype is (waiting, enabled, done);
type check_statetype is (waiting, ball_check_setup, ball_check, done);
type main_statetype is (waiting, playing, scored, game_over);


-- SIGNALS

signal reset : std_logic := '0';

-- controller
signal controller_0 : std_logic_vector(3 downto 0) := (others => '0');
signal controller_1 : std_logic_vector(3 downto 0) := (others => '0');

-- entities
signal ball_x : std_logic_vector(9 downto 0) := (others => '0');
signal ball_y : std_logic_vector(8 downto 0) := (others => '0');
signal ball_v_x : std_logic := '1';
signal ball_v_y : std_logic := '1';
signal paddle_0_y : std_logic_vector(8 downto 0) := (others => '0');
signal paddle_1_y : std_logic_vector(8 downto 0) := (others => '0');

-- step clk
signal step : std_logic := '0';
signal step_curr, step_next : step_statetype := waiting;

-- check fsm
signal check : std_logic := '0';
signal check_curr, check_next : check_statetype := waiting;

--check datapath
signal check_vga, check_ball, bounce: std_logic := '0';

-- main fsm
signal main_curr, main_next : main_statetype := waiting;
signal greeting_EN, game_over_EN: std_logic := '0';

-- vga
signal vga_x : std_logic_vector(9 downto 0) := (others => '0');
signal vga_y : std_logic_vector(9 downto 0) := (others => '0');
signal vga_color : std_logic_vector(11 downto 0) := (others => '0');

-- collision detection signals
signal check_x : std_logic_vector(9 downto 0) := (others => '0');
signal check_y : std_logic_vector(8 downto 0) := (others => '0');
signal check_w : std_logic_vector(3 downto 0) := (others => '0');
signal check_h : std_logic_vector(3 downto 0) := (others => '0');

signal paddle_0_collision : std_logic := '0';
signal paddle_1_collision : std_logic := '0';
signal ball_collision : std_logic := '0';
signal top_collision : std_logic := '0';
signal bottom_collision : std_logic := '0';
signal right_collision : std_logic := '0';
signal left_collision : std_logic := '0';
signal score_0_0_collision : std_logic := '0';
signal score_0_1_collision : std_logic := '0';
signal score_1_0_collision : std_logic := '0';
signal score_1_1_collision : std_logic := '0';
signal divider_collision : std_logic := '0';
signal game_over_collision : std_logic := '0';
signal greeting_collision : std_logic := '0';

--score logic signals
signal scored_0 : std_logic := '0';
signal scored_1 : std_logic := '0';
signal uscore_p_0 : unsigned(3 downto 0) := "0000";
signal uscore_p_1 : unsigned(3 downto 0) := "0000";
signal score_0_0_char : std_logic_vector(5 downto 0) := (others => '0');
signal score_0_0_bitmap : std_logic_vector(24 downto 0) := (others => '0');
signal score_0_1_char : std_logic_vector(5 downto 0) := (others => '0');
signal score_0_1_bitmap : std_logic_vector(24 downto 0) := (others => '0');
signal score_1_0_char : std_logic_vector(5 downto 0) := (others => '0');
signal score_1_0_bitmap : std_logic_vector(24 downto 0) := (others => '0');
signal score_1_1_char : std_logic_vector(5 downto 0) := (others => '0');
signal score_1_1_bitmap : std_logic_vector(24 downto 0) := (others => '0');
signal score_reset : std_logic := '0';


-- CONSTANTS

-- graphics
constant BALL_DIAM : std_logic_vector(3 downto 0) := "0101";
constant BALL_HOME_X : std_logic_vector(9 downto 0) := "0101000000";
constant BALL_HOME_Y : std_logic_vector(8 downto 0) := "011110000";
constant PADDLE_HEIGHT : std_logic_vector(5 downto 0) := "010011";
constant PADDLE_WIDTH : std_logic_vector(3 downto 0) := "0011";
constant PADDLE_HOME : std_logic_vector(8 downto 0) := "011110000"; -- 240
constant PADDLE_0_X : std_logic_vector(9 downto 0) := "0001010000"; -- 80
constant PADDLE_1_X : std_logic_vector(9 downto 0) := "1000110000"; -- 560
constant SCORE_0_0_X : std_logic_vector(9 downto 0) := "0100000000";
constant SCORE_0_1_X : std_logic_vector(9 downto 0) := "0100001000";
constant SCORE_1_0_X : std_logic_vector(9 downto 0) := "0101111000";
constant SCORE_1_1_X : std_logic_vector(9 downto 0) := "0110000000";
constant SCORE_Y : std_logic_vector(8 downto 0) := "000001111";


begin

score_logic: process(mclk, uscore_p_0, scored_0, scored_1, uscore_p_1, main_curr)
begin
    if rising_edge(mclk) then
        if main_curr = playing then
            if scored_0 = '1' and main_curr = playing then
                uscore_p_0 <=  uscore_p_0 + 1 ;
            elsif scored_1 = '1' and main_curr = playing then
                uscore_p_1 <=  uscore_p_1 + 1 ;
            end if;    
            if score_reset = '1' then
                uscore_p_0 <= "0000";
                uscore_p_1 <= "0000";
            end if;
            
            -- set chars
            if uscore_p_0 > 9 then
                score_0_0_char <= "000001";
                score_0_1_char <= "00" & std_logic_vector(uscore_p_0 - 10);
            else
                score_0_0_char <= "000000";
                score_0_1_char <= "00" & std_logic_vector(uscore_p_0);
            end if;
            if uscore_p_1 > 9 then
                score_1_0_char <= "000001";
                score_1_1_char <= "00" & std_logic_vector(uscore_p_1 - 10);
            else
                score_1_0_char <= "000000";
                score_1_1_char <= "00" & std_logic_vector(uscore_p_1);
            end if;
        end if;
    end if;
    
    -- map variables
    score_p_0 <= std_logic_vector(uscore_p_0);
    score_p_1 <= std_logic_vector(uscore_p_1);
end process score_logic;

-- main game fsm combinational
main_game_comb: process(main_curr, check_curr, mreset, start, running, scored_0, scored_1, uscore_p_0, uscore_p_1, greeting_EN, game_over_EN)
begin
    main_next <= main_curr;

    case main_curr is
        when waiting => 
            -- enable greeting
            greeting_EN <= '1';
            game_over_EN <= '0';
            reset <= '0';
            score_reset <= '1';
            
            --transition
            if start = '1' and running <= '1' then
               main_next <= playing;
            end if;

        when playing =>
            -- disable greeting
            greeting_EN <= '0';
            game_over_EN <= '0';
            reset <= '0';
            score_reset <= '0';
            
            -- transition
            if mreset = '1' then
                main_next <= waiting;
                reset <= '1';
            elsif scored_0 = '1' or scored_1 = '1' then
                main_next <= scored;
            end if;
        
        when scored =>
            -- set vals
            greeting_EN <= '0';
            game_over_EN <= '0';
            reset <= '1';
            score_reset <= '0';
        
            -- transition
            if mreset = '1' then
                reset <= '1';
                main_next <= waiting;
            elsif uscore_p_0 = 11 or uscore_p_1 = 11 then
                main_next <= game_over;
            else
                main_next <= playing;
            end if;
        
        when game_over =>
            -- show game over
            game_over_EN <= '1'; 
            greeting_EN <= '0';
            reset <= '0';
            score_reset <= '0';
            
            -- transition
            if mreset = '1' or start = '1' then
                reset <= '1';
                main_next <= waiting;
            end if;
         when others =>
            main_next <= main_curr;
     end case;
end process main_game_comb;

check_datapath: process(mclk, check_x, check_y, check_w, check_h)
begin
    if rising_edge(mclk)then
        if check_vga = '1' then
            --set vals
            check_x <= vga_x;
            check_y <= vga_y(8 downto 0);
            check_w <= "0001";
            check_h <= "0001";
            scored_0 <= '0';
            scored_1 <= '0';
            
        elsif check_ball = '1' then
            -- set vals (start with ball)
            if ball_v_x = '1' then
                check_x <= std_logic_vector(unsigned(ball_x) + 1);
            else
                check_x <= std_logic_vector(unsigned(ball_x) - 1);
            end if;
            if ball_v_y = '1' then
                check_y <= std_logic_vector(unsigned(ball_y) + 1);
            else
                check_y <= std_logic_vector(unsigned(ball_y) - 1);
            end if;
            
            check_w <= BALL_DIAM;
            check_h <= BALL_DIAM;
            
        elsif bounce = '1' then
    
            -- paddles bounce
            if paddle_0_collision = '1'
                or paddle_1_collision = '1' then
                ball_v_x <= not(ball_v_x);
            end if;
    
            -- top wall bounce
            if top_collision = '1' then
                ball_v_y <= '1';
            end if;
            
            -- bottom wall bounce
            if bottom_collision = '1' then
                ball_v_y <= '0';
            end if;
            
            -- right wall bounce
            if right_collision = '1' then
                ball_v_x <= '0';
                scored_0 <= '1';
            else
                scored_0 <= '0';
            end if;
            
            -- left wall bounce
            if left_collision = '1' then
                ball_v_x <= '1';
                scored_1 <= '1';
            else
                scored_1 <= '0';
            end if;
        else
            scored_0 <= '0';
            scored_1 <= '0';      
        end if;
    end if;
end process check_datapath;

-- bounce check combinational logic
check_comb: process(check_curr, step_curr, vga_x, vga_y, ball_x, ball_y, ball_v_x, ball_v_y, paddle_0_collision, paddle_1_collision, top_collision, bottom_collision, right_collision, left_collision, check_w)
begin
    check_next <= check_curr;

    case check_curr is
        when waiting =>
            check_vga <= '1'; 
            check_ball <= '0';
            bounce <= '1';
            
            -- transition
            if step_curr = done then
                check_next <= ball_check_setup;
            end if;
            
        when ball_check_setup =>
            check_vga <= '0'; 
            check_ball <= '1';
            bounce <= '0';
            
            -- transition
            if check_w = BALL_DIAM then
                check_next <= ball_check;
            end if;

        when ball_check =>
            check_vga <= '0'; 
            check_ball <= '0';
            bounce <= '1';
            
            -- transition
            check_next <= done;
            
        when done =>
            check_vga <= '0'; 
            check_ball <= '0';
            bounce <= '0';
            
            -- transition
            if step_curr = waiting then
                check_next <= waiting;
            end if;
    end case;
end process check_comb;

-- step combinational logic
step_comb: process(vga_y, step_curr,running)
begin
    step_next <= step_curr;
    
    case step_curr is
        when waiting =>
            -- set step
            step <= '0';
        
            -- transition
            if vga_y = "0111100000" and running = '1' then
                step_next <= enabled;
            end if;
            
        when enabled =>
            -- set step
            step <= '1';
            
            -- transition
            step_next <= done;
            
        when done =>
            -- set step
            step <= '0';
            
            -- transition
            if vga_y = "0000000000" then
                step_next <= waiting;
            end if;
    end case;
end process step_comb;

-- fsm update logic
fsm_update: process(mclk)
begin
    if rising_edge(mclk) then
        step_curr <= step_next;
        check_curr <= check_next;
        main_curr <= main_next;
    end if;
end process fsm_update;

-- gen pixel logic
gen_pixel: process(mclk, greeting_EN, game_over_EN)
begin
    if rising_edge(mclk) then
        vga_color <= "000000000000";
        
        if ball_collision = '1' then
            vga_color <= "111111111111";
        end if;
        
        if right_collision = '1' then
            vga_color <= "000011000000";
        end if;
        
        if left_collision = '1' then
            vga_color <= "000000001100";
        end if;
        
        if score_0_0_collision = '1'
            or score_0_1_collision = '1'
            or score_1_0_collision = '1'
            or score_1_1_collision = '1' then
            vga_color <= "111111111111";
        end if;
        
        -- only show during games
        if main_curr = playing or main_curr = scored then
            -- paddles
            if paddle_0_collision = '1' then
                vga_color <= "110011001100";
            end if;
            
            if paddle_1_collision = '1' then
                vga_color <= "110011000000";
            end if;
                
            -- dividers
            if divider_collision = '1' then
                vga_color <= "111111111111";
            end if;
        end if;
        
        -- new game splash
        if greeting_EN = '1' and greeting_collision = '1' then
            vga_color <= "111111111111";
        end if;
        
        -- game over splash
        if game_over_EN = '1' and game_over_collision = '1' then
            vga_color <= "111111111111";
        end if;
    end if;
end process gen_pixel; 


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
    reset => mreset,
    home => PADDLE_HOME,
    height => PADDLE_HEIGHT,
    v => controller_0,
    y => paddle_0_y );
    
-- right paddle
PADDLE_1_ENT: paddle port map (
    clk => mclk,
    en => step,
    reset => mreset,
    home => PADDLE_HOME,
    height => PADDLE_HEIGHT,
    v => controller_1,
    y => paddle_1_y );

-- letters (text mux)
LETTER_0_0_ENT: letter port map (
    char => score_0_0_char,
    bitmap => score_0_0_bitmap );
    
LETTER_0_1_ENT: letter port map (
    char => score_0_1_char,
    bitmap => score_0_1_bitmap );
    
LETTER_1_0_ENT: letter port map (
    char => score_1_0_char,
    bitmap => score_1_0_bitmap );
    
LETTER_1_1_ENT: letter port map (
    char => score_1_1_char,
    bitmap => score_1_1_bitmap );

-- vga output
VGA_ENT: vga_controller port map (
    mclk => mclk,
    rgb => rgb,
    hsync => hsync,
    vsync => vsync,
    x => vga_x,
    y => vga_y,
    color => vga_color );

-- collision detector
COLLISION_DETECTOR_ENT: collision_detector port map (
    clk => mclk,
    check_x => check_x,
    check_y => check_y,
    check_w => check_w,
    check_h => check_h,
    p_width => PADDLE_WIDTH,
    p_height => PADDLE_HEIGHT,
    p1_x => PADDLE_0_X,
    p1_y => paddle_0_y,
    p2_x => PADDLE_1_X,
    p2_y => paddle_1_y,
    b_diam => BALL_DIAM,
    b_x => ball_x,
    b_y => ball_y,
    score_0_0_x => SCORE_0_0_X,
    score_0_1_x => SCORE_0_1_X,
    score_1_0_x => SCORE_1_0_X,
    score_1_1_x => SCORE_1_1_X,
    score_y => SCORE_Y,
    score_0_0_bitmap => score_0_0_bitmap,
    score_0_1_bitmap => score_0_1_bitmap,
    score_1_0_bitmap => score_1_0_bitmap,
    score_1_1_bitmap => score_1_1_bitmap,
    p1_collision => paddle_0_collision,
    p2_collision => paddle_1_collision,
    ball_collision => ball_collision,
    top_collision => top_collision,
    bottom_collision => bottom_collision,
    right_collision => right_collision,
    left_collision => left_collision,
    score_0_0_collision => score_0_0_collision,
    score_0_1_collision => score_0_1_collision,
    score_1_0_collision => score_1_0_collision,
    score_1_1_collision => score_1_1_collision,
    divider_collision => divider_collision,
    game_over_collision => game_over_collision,
    greeting_collision => greeting_collision);


end Behavioral;
