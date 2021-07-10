-- spi Master (transmit and receive)

library ieee;
use ieee.std_logic_1164.all;

entity spims is
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
end spims;

architecture behave of spims is

type state_type is (sidle, sstartx, sstart_lo, sclk_hi, sclk_lo, sstop_hi, sstop_lo);

signal state, next_state : state_type;
signal sclk_i, scsq_i, sdo_i : std_logic;
signal wr_buf : std_logic_vector(uspi_size-1 downto 0);
signal rd_buf : std_logic_vector(uspi_size-1 downto 0);
signal count : integer range 0 to uspi_size-1;	 
-------clock divide
constant clk_div : integer := 3;
subtype clkdiv_type is integer range 0 to clk_div-1;
signal spi_clkp : std_logic;

begin
	recvdata <= rd_buf;
	
	  clk_d : process(bclk)        
	  variable clkd_cnt : clkdiv_type;
	  begin
	  		if rising_edge(bclk) then
	  			spi_clkp <= '0';
	  			if resetn='1' then
	  				clkd_cnt := clk_div-1;
	  			elsif clkd_cnt = 0 then
	  				spi_clkp <= '1';
	  				clkd_cnt := clk_div-1;
	  			else
	  				clkd_cnt := clkd_cnt-1;
	  			end if;
	  		end if;
	  end process clk_d;
	
	---spi logic
	seq_p : process(bclk)
	begin
		if rising_edge(bclk) then
			if resetn = '1' then
				state <= sidle;
			elsif spi_clkp = '1' then          
				if next_state = sstartx then
					wr_buf <= snddata;
					count <= uspi_size-1;
				elsif next_state = sclk_hi then
					count <= count-1;								
				elsif next_state = sclk_lo then    
					wr_buf <= wr_buf(uspi_size-2 downto 0) & '0';   
					rd_buf <= rd_buf(uspi_size-2 downto 0) & sdi ; 
				elsif next_state = sstop_lo then  
					rd_buf <= rd_buf(uspi_size-2 downto 0) & sdi ;     
				end if;
				state <= next_state;
				scsq <= scsq_i;
				sclk <= sclk_i;
				sdo <= sdo_i;
			end if;
		end if;
	end process seq_p;
	
	---comb logic
	cmb_p : process(state, start, count, wr_buf)	
	begin
		--defaults
		next_state <= state;
		done <= '0';
		scsq_i <= '0';
		sclk_i <= '0';
		sdo_i <= '0';
		
		case state is
			when sidle =>
				done <= '1';
				scsq_i <= '1';
				if start = '1' then
				next_state <= sstartx;
				end if;
			when sstartx => 
				next_state <= sstart_lo;
			when sstart_lo =>
				sclk_i <= '1';
				sdo_i <= wr_buf(uspi_size-1);
				next_state <= sclk_hi;
			when sclk_hi =>
				next_state <= sclk_lo;
				sdo_i <= wr_buf(uspi_size-1);
			when sclk_lo =>
				sclk_i <= '1';
				sdo_i <= wr_buf(uspi_size-1);
				if count = 0 then
               next_state <= sstop_hi;
               else
               next_state <= sclk_hi;
               end if;
			when sstop_hi =>
				sdo_i <= wr_buf(uspi_size-1); 
				next_state <= sstop_lo;
			when sstop_lo => 
				scsq_i <= '1';                    
				next_state <= sidle;

		end case ;
	end process cmb_p;

end behave;