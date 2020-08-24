----------------------------------------------------------------------------------
-- Company: 			Engs 31 20X
-- Engineer: 			Jai K. Smith
-- 
-- Create Date:    	 	08/23/2020
-- Design Name: 		input controller 
-- Module Name:    		input controller
-- Project Name: 		20X Pong
-- Target Devices: 		Digilent Basys3 (Artix 7)
-- Tool versions: 		Vivado 2018.2.2
-- Description: 		SPI Bus input controller
--				
-- Dependencies: 		mux7seg, multiplexed 7 segment display
--						pmod_ad1, SPI bus interface to Pmod AD1
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;			-- needed for arithmetic
use ieee.math_real.all;				-- needed for automatic register sizing

library UNISIM;						-- needed for the BUFG component
use UNISIM.Vcomponents.ALL;

entity Input_Controller is
port (mclk		: in std_logic;	    -- FPGA board master clock (100 MHz)
	  -- SPI bus interface to Pmod AD1
      spi_sclk : out std_logic;
	  spi_cs : out std_logic;
      spi_sdata_0 : in std_logic;
      spi_sdata_1 : in std_logic;
      
	  -- multiplexed seven segment display
      seg	: out std_logic_vector(0 to 6);
      dp    : out std_logic;
      an 	: out std_logic_vector(3 downto 0);
      
      -- primary output
      controller_0 : out std_logic_vector(2 downto 0);
      controller_1 : out std_logic_vector(2 downto 0) );
end Input_Controller;

architecture Behavioral of Input_Controller is

-- COMPONENT DECLARATIONS
-- Multiplexed seven segment display
component mux7seg is
    Port ( 	clk : in  STD_LOGIC;
           	y0, y1, y2, y3 : in  STD_LOGIC_VECTOR (3 downto 0);	
           	dp_set : in std_logic_vector(3 downto 0);					
           	seg : out  STD_LOGIC_VECTOR (0 to 6);	
          	dp : out std_logic;
           	an : out  STD_LOGIC_VECTOR (3 downto 0) );			
end component;

-- =========================================================================
-- YOUR COMPONENT DECLARATIONS GO HERE
-- =========================================================================

-- interface
component interface
    port (  sclk:		in	std_logic;
            spi_sdata:	in	std_logic; 
            shift_en:	in	std_logic;
            load_en:	in	std_logic;
            ad_data:	out std_logic_vector(11 downto 0) );
end component;

-- controller
component controller
    port (  sclk:           in STD_LOGIC;
            take_sample:    in STD_LOGIC;
            shift_en:       out STD_LOGIC;
            load_en:        out STD_LOGIC;
            spi_cs:         out STD_LOGIC );
end component;

-- filter
component digital_filter
    port ( clk:             in STD_LOGIC;
           take_sample:     in STD_LOGIC;
           x:               in STD_LOGIC_VECTOR(11 downto 0);
           y:               out STD_LOGIC_VECTOR(11 downto 0) );
end component;

-------------------------------------------------
-- SIGNAL DECLARATIONS 
-- Signals for the serial clock divider, which divides the 100 MHz clock down to 1 MHz
constant SCLK_DIVIDER_VALUE: integer := 100 / 4;
--constant CLOCK_DIVIDER_VALUE: integer := 5;     -- for simulation
constant COUNT_LEN: integer := integer(ceil( log2( real(SCLK_DIVIDER_VALUE) ) ));
signal sclkdiv: unsigned(COUNT_LEN-1 downto 0) := (others => '0');  -- clock divider counter
signal sclk_unbuf: std_logic := '0';    -- unbuffered serial clock 
signal sclk: std_logic := '0';          -- internal serial clock

-- =========================================================================
-- SIGNAL DECLARATIONS FOR YOUR CODE GO HERE
-- =========================================================================
-- constants for sampling clock
constant take_sample_count_max: integer := 3124; -- (100000/(640/10))*2-1
constant take_sample_count_len: integer := integer(ceil(log2(real(take_sample_count_max))));

-- Signals for the sampling clock, which ticks at 640 Hz
signal take_sample_internal : std_logic := '0';
signal take_sample_counter: unsigned(take_sample_count_len downto 0) := (others => '0');

-- internal signals
signal shift_en: std_logic := '0';
signal load_en: std_logic := '0';

-- data signals for A0
signal ad_data_0: std_logic_vector(11 downto 0) := (others => '0');
signal ad_data_filtered_0: std_logic_vector(11 downto 0);

-- data signals for A1
signal ad_data_1: std_logic_vector(11 downto 0) := (others => '0');
signal ad_data_filtered_1: std_logic_vector(11 downto 0);

-- scaled output values
signal out_0: unsigned(11 downto 0);
signal out_1: unsigned(11 downto 0);

-------------------------------------------------
begin
-- Clock buffer for sclk
-- The BUFG component puts the signal onto the FPGA clocking network
Slow_clock_buffer: BUFG
	port map (I => sclk_unbuf,
		      O => sclk );

-- Divide the 100 MHz clock down to 4 MHz, then toggling a flip flop gives the final 
-- 2 MHz system clock
Serial_clock_divider: process(mclk)
begin
	if rising_edge(mclk) then
	   	if sclkdiv = SCLK_DIVIDER_VALUE-1 then 
			sclkdiv <= (others => '0');
			sclk_unbuf <= NOT(sclk_unbuf);
		else
			sclkdiv <= sclkdiv + 1;
		end if;
	end if;
end process Serial_clock_divider;

-- divide sclk down to 640 hz
take_sample_proc: process(sclk, take_sample_counter, take_sample_internal)
begin
    if rising_edge(sclk) then
        if take_sample_counter = take_sample_count_max then
            take_sample_internal <= '1';
            take_sample_counter <= (others => '0');
        else
            take_sample_internal <= '0';
            take_sample_counter <= take_sample_counter + 1;
        end if;
    end if;
end process take_sample_proc;

-- scale outputs
scale_output_proc: process(ad_data_filtered_0, ad_data_filtered_1, out_0, out_1)
begin
    -- set internal output signals
    out_0 <= unsigned(ad_data_filtered_0) / 455;
    out_1 <= unsigned(ad_data_filtered_1) / 455;

    -- map final controller outputs
    controller_0 <= std_logic_vector(out_0(2 downto 0));
    controller_1 <= std_logic_vector(out_1(2 downto 0));
end process scale_output_proc;

-- controller
CONTROLLER_ENT: controller port map (
    sclk => sclk,
    take_sample => take_sample_internal,
    shift_en => shift_en,
    load_en => load_en,
    spi_cs => spi_cs );

-- interface
INTERFACE_ENT_0: interface port map (
    sclk => sclk,
    spi_sdata => spi_sdata_0,
    shift_en => shift_en,
    load_en => load_en,
    ad_data => ad_data_0 );
    
INTERFACE_ENT_1: interface port map (
    sclk => sclk,
    spi_sdata => spi_sdata_1,
    shift_en => shift_en,
    load_en => load_en,
    ad_data => ad_data_1 );

-- filter
FILTER_ENT_0: digital_filter port map (
    clk => sclk,
    take_sample => take_sample_internal,
    x => ad_data_0,
    y => ad_data_filtered_0 );
    
FILTER_ENT_1: digital_filter port map (
    clk => sclk,
    take_sample => take_sample_internal,
    x => ad_data_1,
    y => ad_data_filtered_1 );

ODDR_inst : ODDR
generic map(
	DDR_CLK_EDGE => "SAME_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE"
	INIT => '0', -- Initial value for Q port ('1' or '0')
	SRTYPE => "SYNC") -- Reset Type ("ASYNC" or "SYNC")
port map (
	Q => spi_sclk, -- 1-bit DDR output
	C => sclk, -- 1-bit clock input
	CE => '1', -- 1-bit clock enable input
	D1 => '1', -- 1-bit data input (positive edge)
	D2 => '0', -- 1-bit data input (negative edge)
	R => '0', -- 1-bit reset input
	S => '0' -- 1-bit set input
);

-- Instantiate the multiplexed seven segment display
display: mux7seg port map( 
    clk => sclk,				-- runs on the 1 MHz clock
    y3 => "0000", 		        
    y2 => std_logic_vector(out_1(3 downto 0)), -- A/D converter output  
    y1 => "0000",
    y0 => std_logic_vector(out_0(3 downto 0)),		
    dp_set => "0000",           -- decimal points off
    seg => seg,
    dp => dp,
    an => an );	

end Behavioral;
