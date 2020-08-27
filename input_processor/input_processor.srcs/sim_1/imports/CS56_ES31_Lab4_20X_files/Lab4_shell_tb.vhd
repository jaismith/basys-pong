--------------------------------------------------------------------------------
-- Engineer:        Eric Hansen
-- Course:	 		Engs 31 15S
--
-- Create Date:     07/21/2016
-- Design Name:   
-- Module Name:     lab5_top_tb.vhd
-- Project Name:    Lab5
-- Target Device:  
-- Tool versions:  
-- Description:     VHDL Test Bench for module: Lab5 (top level)
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:

--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;

ENTITY lab4_top_tb IS
END lab4_top_tb;
 
ARCHITECTURE behavior OF lab4_top_tb IS 

component Lab4
port (mclk		: in std_logic;	    -- FPGA board master clock
	-- SPI bus interface to Pmod AD1
      spi_sclk : out std_logic;
      spi_cs : out std_logic;
      spi_sdata : in std_logic;
	  take_sample_LA : out std_logic;
	  filter_en: in std_logic;
      
	-- multiplexed seven segment display
      seg	: out std_logic_vector(0 to 6);
      dp    : out std_logic;
      an 	: out std_logic_vector(3 downto 0) );
end component; 

	--Inputs
	signal clk : std_logic := '0';
	signal spi_sdata : std_logic ;
	signal filter_en: std_logic := '0';
	 
 	--Outputs
	signal spi_sclk : std_logic := '0' ;
	signal spi_cs : std_logic := '1';
--    signal seg : std_logic_vector(0 to 6);
--    signal dp : std_logic;
--    signal an : std_logic_vector(3 downto 0);
--	  signal take_sample_LA : std_logic;
     
   -- Clock period definitions
   constant clk_period : time := 10ns;		-- 100 MHz clock
	
	-- Data definitions
	constant bit_time : time := 1us;		-- 1 MHz
	constant TxData : std_logic_vector(14 downto 0) := "000111101001111";
	signal bit_count : integer := 14;
	
BEGIN 


	-- Instantiate the Unit Under Test (UUT)
 
uut: Lab4 port map(
        mclk => clk, 
        -- SPI bus interface to Pmod AD1
        spi_sclk => spi_sclk,
        spi_cs => spi_cs,
        spi_sdata => spi_sdata,
        filter_en => filter_en,
          
        -- multiplexed seven segment display
		take_sample_LA => open,
		seg => open,
        dp => open,
        an => open );
        
   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   -- Stimulus process:  testbench pretends to be the A/D converter
   stim_proc: process(spi_sclk)
   begin
   if falling_edge(spi_sclk) then       -- clock data out on falling edge, MSB first		
        if spi_cs = '0' then		
			spi_sdata <= TxData(bit_count);
			if bit_count = 0 then bit_count <= 14;
			else bit_count <= bit_count - 1;
			end if;		
		else
			bit_count <= 14;
		end if;			
	end if;
   end process;
END;
