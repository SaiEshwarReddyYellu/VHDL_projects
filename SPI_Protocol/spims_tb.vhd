-- spi Master (transmit and receive) test bench

library ieee;
use ieee.std_logic_1164.all;

entity spims_tb is
end spims_tb;

architecture behave of spims_tb is

constant spi_nbits : integer := 16;

component spims is
generic ( uspi_size : integer := 16 );
	port( resetn : in std_logic;
		  bclk : in std_logic;
		  start : in std_logic;
		  done : out std_logic;
		  scsq : out std_logic; -- spi signal
		  sclk : out std_logic; -- spi signal
		  sdo : out std_logic; -- spi signal
		  sdi : in std_logic; -- spi signal
		  snddata : in std_logic_vector ( uspi_size-1 downto 0);
		  recvdata : out std_logic_vector ( uspi_size-1 downto 0) );
end component spims;

signal  resetn :  std_logic := '1';
signal  bclk :  std_logic := '0';
signal  start : std_logic := '0';
signal  done :  std_logic := '0';
signal  scsq :  std_logic := '0'; -- spi signal
signal  sclk :  std_logic := '0'; -- spi signal
signal  serial_out :  std_logic := '0'; -- spi signal
signal  serial_in : std_logic := '0'; -- spi signal
signal  snddata : std_logic_vector ( spi_nbits-1 downto 0) := x"5A35";
signal  recvdata : std_logic_vector ( spi_nbits-1 downto 0) := x"0000";

constant clk_period : time := 10 ns;

begin
	uut : spims
		generic map ( uspi_size => spi_nbits )
		port map ( resetn => resetn,
					bclk => bclk,
					start => start,
					done => done,
					scsq => scsq,
					sclk =>  sclk,
					sdo => serial_out,
					sdi => serial_in,
					snddata => snddata,
					recvdata => recvdata );

		clk_p : process
		begin
			bclk <= '0';
			wait for clk_period / 2;
			
			bclk <= '1';
			wait for clk_period / 2;
		end process clk_p;
		
		
		--feedback from sdo->sdi
      serial_in <= NOT serial_out;
		
		stim_p : process
		begin
			wait for clk_period;
			resetn <= '1';
			wait for clk_period;
			resetn <= '0';
			wait for clk_period * 4 ;
			start <= '1';
			wait for clk_period * 4;
			start <= '0';
			wait for clk_period;
			report " test bench report done";
			wait;
		end process stim_p;


end behave;