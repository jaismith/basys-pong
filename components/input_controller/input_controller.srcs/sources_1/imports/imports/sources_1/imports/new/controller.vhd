----------------------------------------------------------------------------------
-- Company:         Engs 31 / CoSc 56 20X
-- Engineer:        Jai K. Smith
-- 
-- Create Date:     07/30/2020 09:40:03 PM
-- Design Name:     Lab 4.0.1 Controller
-- Module Name:     controller - behavioral
-- Project Name:    Lab 4
-- Target Devices:  Artix7 / Basys3
-- Tool Versions:   Vivado 2018.3.1
-- Description:     Controller for Lab 4 deliverable 0.1
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
use ieee.NUMERIC_STD.ALL;

entity controller is
-- port map
port (  sclk        :   in STD_LOGIC;
        take_sample :   in STD_LOGIC;
        shift_en    :   out STD_LOGIC;
        load_en     :   out STD_LOGIC;
        spi_cs      :   out STD_LOGIC );
end controller;

architecture behavioral of controller is
-- types
type statetype is (idle, shifting, loading);

-- signals
signal curr_state, next_state : statetype := idle;
signal count : unsigned(3 downto 0) := "0000";
signal count_tc : std_logic := '0';
signal count_rst : std_logic := '0';

-- constants
constant max_count : integer := 14; 

begin

timer_proc: process(sclk, count, count_rst)
begin
    if rising_edge(sclk) then
        if count < max_count then
            count <= count + 1;
        end if;
        
        if count_rst = '1' then
            count <= "0000";
        end if;
    end if;
    
    if count = max_count then
        count_tc <= '1';
    else
        count_tc <= '0';
    end if;
end process timer_proc;

FSM_comb: process(curr_state, count_tc, take_sample)
begin
    -- default
    next_state <= curr_state;
    
    -- fsm
    case curr_state is
        when idle =>
            -- set outputs
            shift_en <= '0';
            load_en <= '0';
            spi_cs <= '1';
            count_rst <= '1';
            
            -- transition
            if take_sample = '1' then
                next_state <= shifting;
            end if;
            
        when shifting =>
            --set outputs
            shift_en <= '1';
            load_en <= '0';
            spi_cs <= '0';
            count_rst <= '0';
            
            -- transition
            if count_tc = '1' then
                next_state <= loading;
            end if;
            
        when loading => 
            -- set outputs
            shift_en <= '0';
            load_en <= '1';
            spi_cs <= '1';
            count_rst <= '0';
            
            -- transition
            next_state <= idle;

    end case;
end process FSM_comb;

FSM_update: process(sclk)
begin
    if rising_edge(sclk) then
        curr_state <= next_state;
    end if;
end process FSM_update;

end behavioral;
