-- traffic controller state machine

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tlctsm is
	port ( reset : in std_logic;
		   clk : in std_logic;
		   start : in std_logic;
		   red : out std_logic;
		   yellow : out std_logic;
		   green : out std_logic );
end tlctsm;

architecture behave of tlctsm is

type state_type is (st_stop, st_red, st_ry, st_green, st_yel);
signal state, next_state : state_type;

constant max_count : integer := 10;
subtype int4 is integer range 0 to max_count-1;
signal timer : int4;

begin

	seq_p : process(clk)
	variable cnt : int4;
	begin
		if rising_edge(clk) then
			if reset = '1' then
				cnt := 0;
				state <= st_stop;
			elsif cnt = timer then
				state <= next_state;
			else 
				state <= next_state;
		end if;              
		end if;
	end process seq_p;
	
	--combinational process
	
	cmb_p : process(state,start)
	begin
		next_state <= state;
		red <= '0';
		yellow <= '0';
		green <= '0';
		timer <= 0;                 --timer is not in code ,so no hyphens
		case state is
			when st_stop =>
				if start = '1' then
					next_state <= st_red;
				end if;
				red <= '1';
			when st_red =>
				timer <= 3;
				red <= '1';
				next_state <= st_ry;
			when st_ry =>
				timer <= 1;
				red <= '1';
				yellow <= '1';
				next_state <= st_green;
			when st_green =>
				timer <= 4;
				green <= '1';
				next_state <= st_yel;
			when st_yel =>
				if start = '0' then
					next_state <= st_stop;
				else 
					next_state <=st_red;
				end if;
				yellow <= '1';
		end case;
	end process cmb_p;
end behave;