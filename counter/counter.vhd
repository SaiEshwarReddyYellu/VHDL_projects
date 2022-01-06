entity counter is
    Generic (MAX_VALUE : INTEGER := 2**30;
             sync_reset : boolean := true);
--  Port ( );
    port ( max_count : out std_logic;
            clk : in std_logic;
            reset : in std_logic);
end counter;

architecture Behavioral of counter is

constant bit_depth : integer := integer(ceil(log2(real(MAX_VALUE))));
signal count_reg : unsigned(bit_depth-1 downto 0) := (others => '0');

begin

sync_rst: if sync_reset = true generate
    count_proc: process(clk)
        begin
            if rising_edge(clk) then
                if(reset = '0') or (count_reg = MAX_VALUE)  then
                    count_reg <= (others => '0');
                else 
                    count_reg <= count_reg + 1;
                end if;
            end if;           
        end process count_proc;
end generate;

async_reset: if sync_reset = false generate
    count_proc : process(clk, reset)
        begin
            if (reset = '0') then
                count_reg <= (others => '0');
            elsif rising_edge(clk) then
                if (count_reg = MAX_VALUE) then
                    count_reg <= (others => '0'); 
                else
                    count_reg <= count_reg + 1;
                end if;  
            end if;   
        end process count_proc;
end generate;

output_proc: process(count_reg)
    begin
        max_count <= '0';
        if(count_reg = MAX_VALUE) then
            max_count <= '1';
        end if;
    end process;
end Behavioral;
