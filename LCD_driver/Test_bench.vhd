
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lcd_v_tb is
--  Port ( );
end lcd_v_tb;

architecture Behavioral of lcd_v_tb is

component lcd_v is
port(
        clk_p : in std_logic;
        clk_n : in std_logic;
        rst : in std_logic;
        lcd_out : out std_logic_vector(3 downto 0);
        lcd_e,rs,rw : out std_logic;
        btnl : in std_logic;    --east
        btnr : in std_logic;    --west
        btnd : in std_logic;    --north
        btnc : in std_logic;    --centre
        switches : in std_logic_vector ( 3 downto 0);
        leds : out std_logic_vector ( 7 downto 0) );

end component lcd_v;

signal clk_p :  std_logic := '0';                       
signal clk_n :  std_logic := '0';                       
signal rst :  std_logic := '0';                         
signal lcd_out :  std_logic_vector(3 downto 0) := "0000";                       
signal lcd_e,rs,rw :  std_logic  := '0';
signal btnl :  std_logic :='0';               
signal btnr :  std_logic :='0';             
signal btnd :  std_logic :='0';               
signal btnc :  std_logic :='0';               
signal switches :  std_logic_vector ( 3 downto 0):= x"0";
signal leds :  std_logic_vector ( 7 downto 0) := x"00";  

constant clk_signal : time := 20ns;

begin
 
 
 uut: lcd_v
    port map(
            clk_p => clk_p,
            clk_n => clk_n,
            rst => rst,
            lcd_out => lcd_out,
            lcd_e => lcd_e,
            rs => rs,
            rw => rw,
            btnl => btnl, 
            btnr => btnr,
            btnd => btnd,
            btnc => btnc,
            switches => switches,
            leds => leds);
 
 clk_p <= not clk_p after clk_signal / 2;
 clk_n <= not clk_p;
 

 stim_p : process
    begin
        wait for clk_signal;
           rst <= '1';
        wait for clk_signal * 20;
            rst <= '0';  
        wait for clk_signal;    
           switches <= x"3";
        wait for clk_signal * 10;
            btnd <= '1';
        wait for clk_signal;
            btnd <= '0';
        wait for clk_signal * 10;
            btnl <= '1';
        wait for clk_signal;
            btnl <= '0';
        wait for clk_signal * 50;
            btnr <= '1';
        wait for clk_signal; 
            btnr <= '0';
        wait for clk_signal * 50;
            btnc <= '1';
        wait for clk_signal;
            btnc <= '0';
            wait; 
    end process stim_p; 
         
end Behavioral;
