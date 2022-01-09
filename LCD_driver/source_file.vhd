

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lcd_v is
--  Port ( );
port(
        clk_p : in std_logic;
        clk_n : in std_logic;
        rst : in std_logic;
        lcd_out : out std_logic_vector(3 downto 0);
        lcd_e,rs,rw : out std_logic;
        btnl : in std_logic;    --east      --display left and LEDS move leftwards
        btnr : in std_logic;    --west      --display right and LEDS move rightwards
        btnd : in std_logic;    --north     --display down and Leds become stable
        btnc : in std_logic;    --centre    --displaying company name
        switches : in std_logic_vector ( 3 downto 0);
        leds : out std_logic_vector ( 7 downto 0)); 
end lcd_v;

architecture Behavioral of lcd_v is


component clk_wiz_0 
 port(
  --// Clock out ports
  clk_out1 : out std_logic;
 --// Clock in ports
  clk_in1_p : in std_logic;
  clk_in1_n : in std_logic
 );
end component clk_wiz_0;


signal sys_clk : std_logic;

----------------------------------------------------------------------------------------------------------------------------------------
type display is(idle,func_set1,func_set2,func_set3, disp_ctrl, disp_clr,entry_mode,char_c,char_h,char_r,char_o,char_m,char_a,char_s,char_e,
char_n,char_2s,char_dash,char_G,char_2m,char_b,char_2H,wait_period,done,char_L, char_2e, char_f, char_t, char_2R, char_i,char_2g,char_3h,char_2t,char_d,char_2o,char_w,char_2n);

signal nx_state : display;
signal i1 : integer range 0 to 50_000_00 := 0;          --100ms period

----------------------------------------------------------------------------------------------------------
type tx_seq is (high_setup, high_hold, twous, low_setup, low_hold, eightyus,done);
signal tx_state : tx_seq := done;
signal tx_byte : std_logic_vector(7 downto 0);
signal bf_reg : std_logic_vector(3 downto 0) := "1000";
signal tx_init : std_logic := '0';
signal i2 : integer range 0 to 100_000 := 0;       --2ms period
----------------------------------------------------------------------------------------------------------

signal tx_wait_done : std_logic := '0';
signal slow_clk : std_logic := '0';
-------------------------------------------------
signal led_reg : std_logic_vector (7 downto 0) := x"91";
signal mv_left : std_logic := '0' ; 
signal mv_right : std_logic := '0';

---------------------------------------------------------
signal count : std_logic_vector(25 downto 0) := (others => '0');        --40 bit counter

signal wait_cnt: integer range 0 to 50_000_0000 := 0;     -- used for wait time after displaying

begin
        leds <= led_reg;
        
 clk_ins: clk_wiz_0
    port map(
        clk_out1 => sys_clk,
        clk_in1_p => clk_p,
        clk_in1_n => clk_n
    ); 

process(sys_clk)
begin
    if rising_edge(sys_clk) then
        slow_clk <= '0';
       if count = x"3ff_fff_f" then
            count <= (others => '0');
            slow_clk <= '1';
       else
            count <= count + 1;      
       end if;
    end if;
end process;



mv_logic : process(sys_clk)
begin
    if rising_edge(sys_clk) then
        if slow_clk = '1' then
            if btnl = '1' then
                mv_left <= '1';
                mv_right <= '0'; 
            elsif btnr = '1' then
                mv_left <= '0';
                mv_right <= '1';
            elsif btnc = '1' then
                mv_left <= '0';
                mv_right <= '0';
            else
                mv_left <= mv_left;
                mv_right <= mv_right;
            end if;
       end if;
    end if;
 end process mv_logic;
 
rotate : process(sys_clk)
begin
    if rising_edge (sys_clk) then 
        if slow_clk = '1' then
            if btnd = '1' then
                led_reg <= "1001" & switches;
            elsif mv_right = '1' then
                led_reg <= led_reg (0) & led_reg (7 downto 1);
            elsif mv_left = '1' then
                led_reg <= led_reg (6 downto 0) & led_reg (7);
            elsif btnc = '1' then
                led_reg <= led_reg;
            end if;
        end if;
 end if;
 end process rotate;
  
operation : process(sys_clk,rst,btnl,btnr,btnc,btnd)            --Initialization and transaction
  begin
    if(rst = '1') then
        nx_state <= idle;
        elsif rising_edge (sys_clk) then
            case nx_state is
                when idle =>
                         
                    if (i1 >= 25_000_00)  and btnc = '1' then        --wait time 50 ms and checking center button
                            nx_state <= func_set1;  
                            i1 <= 0;           
                        else
                            nx_state <= idle; 
                            i1 <= i1+1;
                    end if;
                    
                 when func_set1 =>                  --Function_set_1
                    tx_init <= '1';
                    rs <= '0';
                    rw <= '0';
                    tx_byte <= x"38";
                    
                    if tx_wait_done = '1' then
                        nx_state <= func_set2;
                    end if;   
                 
                 when func_set2 =>                  --Function_set_2
                    tx_init <= '1';
                    rs <= '0';
                     rw <= '0';
                    tx_byte <= x"28";
    
                    if tx_wait_done = '1' then
                        nx_state <= func_set3;
                    end if;  
                   
                    
                  
                 when func_set3 =>                  --Function_set_3               
                    tx_init <= '1';
                    rs <= '0';
                     rw <= '0';
                    tx_byte <= x"28";
                    
                    if tx_wait_done = '1' then
                        nx_state <= disp_ctrl;
                    end if;                    
                    
                 when disp_ctrl =>                   --display ON/OFF control
                    tx_init <= '1';
                    rs <= '0';
                     rw <= '0';
                    tx_byte <= x"0f";                   --blinking off
 
                     if tx_wait_done = '1' then
                        nx_state <= disp_clr;
                    end if;
                                       
                 when disp_clr =>                       --display clear
                    tx_init <= '1';
                    rs <= '0';
                     rw <= '0';
                    tx_byte <= x"01";

                    if tx_wait_done = '1' then
                        nx_state <= entry_mode;
                    end if;
                                        
                 when entry_mode =>                      --display clear
                    tx_init <= '1';
                    rs <= '0';
                    rw <= '0';
                    tx_byte <= x"06";
                 
                    
                  if tx_wait_done = '1' and btnl = '1' then
                           nx_state <= char_L;                --change to idle later
                        elsif tx_wait_done = '1' and btnd = '1' then
                           nx_state <= char_d; 
                        elsif tx_wait_done = '1' and btnr = '1' then
                           nx_state <= char_2R;  
                        elsif tx_wait_done = '1' and btnc = '1' then
                           nx_state <= char_c;
                        else
                            nx_state <= entry_mode;
                  end if;                                     
                                    
                when char_c =>
                    rs <= '1';
                     rw <= '0';
                    tx_init <= '1';
                    tx_byte <= x"63";

                    if tx_wait_done = '1' then
                        nx_state <= char_h;
                    end if;
                                        

                when char_h =>
                    rs <= '1';
                     rw <= '0';
                    tx_init <= '1';
                    tx_byte <= x"68";

                    if tx_wait_done = '1' then
                        nx_state <= char_r;
                    end if;
                
               when char_r =>
                    rs <= '1';
                     rw <= '0';
                    tx_init <= '1';
                    tx_byte <= x"72";
                    
                    if tx_wait_done = '1' then
                        nx_state <= char_o;
                    end if;                    
                                                    
                when char_o =>
                     rs <= '1';
                      rw <= '0';
                     tx_init <= '1';
                     tx_byte <= x"6f";

                    if tx_wait_done = '1' then
                        nx_state <= char_m;
                    end if;
                   
                when char_m =>
                     rs <= '1';
                      rw <= '0';
                     tx_init <= '1';
                     tx_byte <= x"6d";


                    if tx_wait_done = '1' then
                        nx_state <= char_a;
                    end if;
                    
                when char_a =>
                     rs <= '1';
                      rw <= '0';
                     tx_init <= '1';
                     tx_byte <= x"61";



                    if tx_wait_done = '1' then
                        nx_state <= char_s;
                    end if;
                                         
                when char_s =>
                      rs <= '1';
                       rw <= '0';
                      tx_init <= '1';
                      tx_byte <= x"73";


 
                     if tx_wait_done = '1' then
                        nx_state <= char_e;
                    end if;
                                        
                when char_e =>
                     rs <= '1';
                      rw <= '0';
                     tx_init <= '1';
                     tx_byte <= x"65";


                    if tx_wait_done = '1' then
                        nx_state <= char_n;
                    end if;
                     
                when char_n =>
                     rs <= '1';
                      rw <= '0';
                     tx_init <= '1';
                     tx_byte <= x"6e";



                    if tx_wait_done = '1' then
                        nx_state <= char_2s;
                    end if;
                                         
                when char_2s =>
                     rs <= '1';
                      rw <= '0';
                     tx_init <= '1';
                     tx_byte <= x"73";



                    if tx_wait_done = '1' then
                        nx_state <= char_dash;
                    end if;
                                        
                when char_dash =>
                     rs <= '1';
                      rw <= '0';
                     tx_init <= '1';
                     tx_byte <= x"5f";



                    if tx_wait_done = '1' then
                        nx_state <= char_G;
                    end if;
                                    
                when char_G =>
                     rs <= '1';
                      rw <= '0';
                     tx_init <= '1';
                     tx_byte <= x"47";



                    if tx_wait_done = '1' then
                        nx_state <= char_2m;
                    end if;
                                        
                when char_2m =>
                     rs <= '1';
                      rw <= '0';
                     tx_init <= '1';
                     tx_byte <= x"6d";



                    if tx_wait_done = '1' then
                        nx_state <= char_b;
                    end if;
                                         
                when char_b =>
                     rs <= '1';
                      rw <= '0';
                     tx_init <= '1';
                     tx_byte <= x"62";

                    if tx_wait_done = '1' then
                        nx_state <= char_2H;
                    end if;                     
                     
                when char_2H =>
                     rs <= '1';
                      rw <= '0';
                     tx_init <= '1';
                     tx_byte <= x"48";
                    
                     if tx_wait_done = '1' then
                        nx_state <= wait_period;
                    end if; 
                
                when wait_period => 
                     if wait_cnt < 25_000_0000 then
                        rs <= '0';
                        rw <= '0';
                        tx_init <= '0';
                        wait_cnt <= wait_cnt + 1;
                        nx_state <= wait_period; 
                     else
                        wait_cnt <= 0;
                        nx_state <= done;   --change to idle later
                    end if;
                    
                 when char_L =>
                      rs <= '1';
                      rw <= '0';
                      tx_init <= '1';
                      tx_byte <= x"4c";

                    if tx_wait_done = '1' then
                        nx_state <= char_2e;
                    end if;  
                    
                 when char_2e =>
                      rs <= '1';
                      rw <= '0';
                      tx_init <= '1';
                      tx_byte <= x"65";

                    if tx_wait_done = '1' then
                        nx_state <= char_f;
                    end if;  
                    
                 when char_f =>
                      rs <= '1';
                      rw <= '0';
                      tx_init <= '1';
                      tx_byte <= x"66";

                    if tx_wait_done = '1' then
                        nx_state <= char_t;
                    end if;  
                   
                 when char_t =>
                      rs <= '1';
                      rw <= '0';
                      tx_init <= '1';
                      tx_byte <= x"74";

                    if tx_wait_done = '1' then
                        nx_state <= wait_period;
                    end if;     

                when char_2R =>
                           rs <= '1';
                           rw <= '0';
                           tx_init <= '1';
                           tx_byte <= x"52";
                            
                           if tx_wait_done = '1' then
                               nx_state <= char_i;
                           end if; 
                           
                     when char_i =>
                           rs <= '1';
                           rw <= '0';
                           tx_init <= '1';
                           tx_byte <= x"69";
                            
                           if tx_wait_done = '1' then
                               nx_state <= char_2g;
                           end if; 
                     
                      when char_2g =>
                           rs <= '1';
                           rw <= '0';
                           tx_init <= '1';
                           tx_byte <= x"67";
                            
                           if tx_wait_done = '1' then
                               nx_state <= char_3h;
                           end if;  
                              
                      when char_3h =>
                           rs <= '1';
                           rw <= '0';
                           tx_init <= '1';
                           tx_byte <= x"68";
                            
                           if tx_wait_done = '1' then
                               nx_state <= char_2t;
                           end if; 
                      
                     when char_2t =>
                           rs <= '1';
                           rw <= '0';
                           tx_init <= '1';
                           tx_byte <= x"74";
                            
                           if tx_wait_done = '1' then
                               nx_state <= wait_period;
                           end if; 
                    
                    when char_d =>
                           rs <= '1';
                           rw <= '0';
                           tx_init <= '1';
                           tx_byte <= x"44";
                            
                           if tx_wait_done = '1' then      
                               nx_state <= char_2o;
                           end if; 
                    
                    when char_2o =>
                            rs <= '1';
                           rw <= '0';
                           tx_init <= '1';
                           tx_byte <= x"6f";
                            
                           if tx_wait_done = '1' then        
                               nx_state <= char_w;
                           end if;        
                    
                    when char_w =>
                            rs <= '1';
                           rw <= '0';
                           tx_init <= '1';
                           tx_byte <= x"77";
                            
                           if tx_wait_done = '1' then      
                               nx_state <= char_2n;
                           end if; 
                     
                     when char_2n =>
                            rs <= '1';
                           rw <= '0';
                           tx_init <= '1';
                           tx_byte <= x"6e";
                            
                           if tx_wait_done = '1' then      
                               nx_state <= wait_period;
                           end if;       

                    when done =>                   
                           rs <= '0';
                           rw <= '0';
                          tx_init <= '0';
                          if rst = '1' then
                            nx_state <= idle; 
                          else
                             nx_state <= func_set1;   
                          end if;   
                                 
                when others => null;
            end case;
        end if;
  end process operation;    
 
Timing: process(sys_clk)                            --Timing state  
    begin  
        if rising_edge(sys_clk) then
            tx_wait_done <= '0';
            case tx_state is
                when done =>
                    lcd_e <= '0';
                    if (tx_init = '1') then
                        tx_state <= high_setup;
                        i2 <= 0;
                      else
                        tx_state <= done;  
                        i2 <= 0;
                    end if;
                    
                 when high_setup =>
                   lcd_e <= '0';
                    lcd_out <= tx_byte(7 downto 4);
                     if (i2 = 2) then                       --40ns
                        tx_state <= high_hold;
                        i2 <= 0;
                      else
                        tx_state <= high_setup;  
                        i2 <= i2+1;
                    end if;
                    
                  when high_hold =>
                       lcd_e <= '1';
                    lcd_out <= tx_byte(7 downto 4);
                     if (i2 = 12) then                      --240ns
                        tx_state <= twous;
                        i2 <= 0;
                      else
                        tx_state <= high_hold;  
                        i2 <= i2+1;
                    end if;  
                   
                  when twous =>
                    lcd_e <= '0';
                     if (i2 = 1000) then                 --2us
                        tx_state <= low_setup;
                        i2 <= 0;
                      else
                        tx_state <= twous;  
                        i2 <= i2+1;
                    end if;
                   
                   when low_setup =>
                    lcd_e <= '0';
                    lcd_out <= tx_byte(3 downto 0);
                     if (i2 = 2) then
                        tx_state <= low_hold;
                        i2 <= 0;
                      else
                        tx_state <= low_setup;  
                        i2 <= i2+1;
                    end if; 
                   
                    when low_hold =>
                    lcd_e <= '1';
                    lcd_out <= tx_byte(3 downto 0);
                     if (i2 = 12) then
                        tx_state <= eightyus;
                        i2 <= 0;
                      else
                        tx_state <= low_hold;  
                        i2 <= i2+1;
                    end if;
                    
                    when eightyus =>                --100 us
                    lcd_e <= '0';
                     if (i2 = 50_000) then
                        tx_state <= done;
                        --tx_init <= '0';
                        tx_wait_done <= '1';
                        i2 <= 0;
                      else
                        tx_state <= eightyus;           
                        i2 <= i2+1;
                    end if;
                    
                    when others => null;
                      
            end case;
        end if;
    end process Timing;
   
end Behavioral;
