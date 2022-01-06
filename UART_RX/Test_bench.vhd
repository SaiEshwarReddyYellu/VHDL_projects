library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;

use IEEE.NUMERIC_STD.ALL;


entity uart_rx_tb is
--  Port ( );
end uart_rx_tb;

architecture Behavioral of uart_rx_tb is
component uart_rx is
 generic(   clk_freq : integer := 50_000_000;
            baud_rate : integer := 115200;               --[clk/baud_rate := 50_000_000/115200   = 434.02]
            sam_rate : integer := 20;
            data_width : integer := 8);
    
    port(   rst: in std_logic;
            rx: in std_logic;
            clk: in std_logic;
            data_out: out std_logic_vector(7 downto 0);
            data_ready : out std_logic);
end component;

signal rst,rx,clk: std_logic := '0';
signal data_out : std_logic_vector(7 downto 0) := x"00";
signal data_ready : std_logic := '0';
------------------------------------------------------------
--Memory Array of Array type
type memory is array (0 to 9) of std_logic_vector(7 downto 0);
signal rom : memory := ("11111011","00010010",
"10011011", "10010011", "01011011", "00111010",
"11111011", "00010010", "10100011", "10011010");
--------------------------------------------------------------
constant clk_signal : time := 10ns;                  --100 MHZ CLOCK

constant CLK_FREQ : integer := 50_000_000; 
constant BAUD_RATE : integer := 115200;

constant baud_cnt_depth : integer := (integer(ceil(REAL(CLK_FREQ)/REAL(baud_rate))) - 2);       --433
constant max_time : integer := ((baud_cnt_depth + 1) * 10);       --byte time 


signal baud_cnt : integer range 0 to baud_cnt_depth := 0;  
signal total_cnt : integer range 0 to ((baud_cnt_depth + 1) * 10) + 100 := 0;    --total time for complete data frame + 250 clock cycles(wait time)
signal wr_cnt : integer range 0 to 9 := 0;               --for writting Bytes
signal bit_cnt : integer range 0 to 9 := 0;                 --start + data + stop bit
----------------

signal baud_clk : std_logic;                --Baud rate clock
signal new_data_pulse : std_logic;          --Enables each byte
signal trans_en : std_logic;                --enables transition
----------------
signal rx_data : std_logic_vector (7 downto 0);

signal rx_reg : std_logic;

begin
uut: uart_rx
   generic map(
    clk_freq => CLK_FREQ,
    baud_rate => BAUD_RATE
   )            
  port map (     rst => rst,
                 rx => rx_reg,
                 clk => clk,
                 data_ready => data_ready,
                 data_out => data_out);
  
  clk <= not clk after clk_signal/2;
  
  simulation: process              
  begin
  
    wait for clk_signal;
    rst <= '1';
    wait for clk_signal * 8;
    rst <= '0';
    wait;
    
  end process simulation;
  
  baud_clk1 : process(clk)
  begin
    if rising_edge(clk) then
            if (rst = '1') then
                baud_clk <= '0';
                baud_cnt <= 0;
                else
                if baud_cnt = 4*baud_cnt_depth then
                     baud_clk <= '1';
                     baud_cnt <= 0;
                   else
                    baud_cnt <= baud_cnt + 1;
                    baud_clk <= '0';
                end if;
            end if;
            end if;
  end process baud_clk1;
  
  process(clk) 
begin
    if rising_edge(clk) then
            if (rst = '1') then
                wr_cnt <= 0;
                total_cnt <= 0;
                new_data_pulse <= '0';
                rx_data <= (others => '1');
                
                else
                   total_cnt <= total_cnt + 1; 
                   new_data_pulse <= '0';
                   
                   if total_cnt = (max_time ) * 4 then             --waiting 100 clock cycles
                      rx_data <= rom(wr_cnt);                       --memory values to rx_data
                      
                      new_data_pulse <= '1';
                      total_cnt <= 0;   
                   
                        if wr_cnt < 9 then
                            wr_cnt <= wr_cnt + 1;
                            else
                            wr_cnt <= 0;
                        end if;
                   end if;
            end if;
        end if;   

end process;

process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                rx_reg <= '1';
                bit_cnt <= 0;
                else
                    if new_data_pulse = '1' then
                        trans_en <= '1';
                        bit_cnt <= 0;
                    end if;
                    
                    if baud_clk = '1' then
                        bit_cnt <= bit_cnt + 1;
                        if bit_cnt = 9 then
                            bit_cnt <= 0; 
                        end if;
                    end if;

                    
                    if trans_en = '1' then
                        case bit_cnt is
                            when 0 => rx_reg <= '0';
                            when 1 => rx_reg <= rx_data(0);
                            when 2 => rx_reg <= rx_data(1);
                            when 3 => rx_reg <= rx_data(2);
                            when 4 => rx_reg <= rx_data(3);
                            when 5 => rx_reg <= rx_data(4);
                            when 6 => rx_reg <= rx_data(5);
                            when 7 => rx_reg <= rx_data(6);
                            when 8 => rx_reg <= rx_data(7);
                            when 9 => rx_reg <= '1'; trans_en <= '0';
                            when others => rx_reg <= '1';
                                        
                        end case;
                    end if;
               end if;
          end if;
    end process;

end Behavioral;
