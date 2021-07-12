library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tlctsm_tb is
end tlctsm_tb;

architecture behave of tlctsm_tb is

component tlctsm is
	port ( reset : in std_logic;
		   clk : in std_logic;
		   start : in std_logic;
		   red : out std_logic;
		   yellow : out std_logic;
		   green : out std_logic );
end component tlctsm;

signal reset : std_logic := '0';
signal clk : std_logic := '0';
signal start : std_logic := '0';
signal red : std_logic := '0';
signal yellow : std_logic := '0';
signal green : std_logic := '0';
		   
constant clk_signal : time := 10 ns;

begin
	uut : tlctsm
		port map( reset => reset,
				   clk => clk,
				   start => start,
				   red => red,
				   yellow => yellow,
				   green => green );

		clk_p : process
		begin
			clk <= '0';
			wait for clk_signal/2;
			clk <= '1';
			wait for clk_signal/2;
		end process clk_p;
		
		stim_p : process
		begin
			wait for clk_signal;
			reset <= '1';
			wait for clk_signal;
			reset <= '0';
			wait for clk_signal;
			start <= '1';
			wait for clk_signal * 20;
			start <= '0';
			wait for clk_signal;
			report " tlctsm test bench done";
			wait;
		end process stim_p;
		
end behave;
	
