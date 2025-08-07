----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/21/2024 12:36:28 PM
-- Design Name: 
-- Module Name: i2c_main - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity i2c_main is

    generic(
        main_clk : integer := 125000000;
        bus_clk : integer := 125000
    );
    
    port(
        sys_clk     : in std_logic;
        sys_rst     : in std_logic;
        start       : in std_logic; 
        rd_wr       : in std_logic;
        slv_addr    : in std_logic_vector(6 downto 0);
        point_reg    : in std_logic_vector(7 downto 0);
        done        : out std_logic;
        scl         : inout std_logic;
        sda         : inout std_logic;
        send_data   : in std_logic_vector(15 downto 0);
        recv_data   : out std_logic_vector(15 downto 0)
    
    );
    
end i2c_main;

architecture Behavioral of i2c_main is


constant clk_div : integer := (main_clk/bus_clk)/4;           --now sclk is 125khz

TYPE state_type IS(idle, start_st, dev_addr,reg_addr, slv_ack1, slv_ack2, slv_ack3, write_data, slv_ack4, read_data, mstr_ack, mstr_nack, stop); --needed states
SIGNAL state         : state_type;                        --state machine

SIGNAL data_clk      : STD_LOGIC;                      
SIGNAL data_clk_prev : STD_LOGIC;                    
SIGNAL scl_clk       : STD_LOGIC;                   
SIGNAL scl_ena       : STD_LOGIC := '0';           
SIGNAL sda_int       : STD_LOGIC := '1';           
SIGNAL sda_ena_n     : STD_LOGIC;                    
signal bit_cnt : integer range 0 to 15 := 15;
signal byte_cnt  : integer range 0 to 1 := 1;
signal stretch : std_logic := '0';


signal repe_start    : std_logic;
signal cmd_buf          : std_logic_vector(7 downto 0);
signal point_register   : std_logic_vector(7 downto 0);
signal shift_reg        : std_logic_vector(15 downto 0);
signal recv_buf         : std_logic_vector(15 downto 0);


begin



process(sys_clk, sys_rst)
variable clk_cnt : integer range 0 to 4*clk_div;

begin
        if sys_rst = '0' then        
            clk_cnt := 0;
            stretch <= '0';
        elsif rising_edge(sys_clk) then  
            data_clk_prev <= data_clk;          
            IF(clk_cnt = clk_div*4-1) THEN      
                clk_cnt := 0;                       
                elsif stretch = '0' then
                clk_cnt := clk_cnt + 1;
            END IF;
        
         CASE clk_cnt IS
            WHEN 0 TO clk_div-1 =>         
              scl_clk <= '0';
              data_clk <= '0';
            WHEN clk_div TO clk_div*2-1 =>    
              scl_clk <= '0';
              data_clk <= '1';
            WHEN clk_div*2 TO clk_div*3-1 =>  
              scl_clk <= '1';                 --release scl
              data_clk <= '1';
              if scl = '0' then
                stretch <= '1';
                else
                stretch <= '0';
              end if;
            WHEN OTHERS =>                   
              scl_clk <= '1';
              data_clk <= '0';
          END CASE;            
                
                
       end if;   
end process;



    --state machine and writing to sda during scl low (data_clk rising edge)
  PROCESS(sys_clk, sys_rst)
  BEGIN
    IF(sys_rst = '0') THEN               
      state <= idle;                     
      scl_ena <= '0';                    
      sda_int <= '1';                    
      bit_cnt <= 7;                      
      byte_cnt <= 1;
      repe_start <= '0';
      cmd_buf <= (others => '0');
      point_register <= (others => '0');
      shift_reg <= (others => '0');
      recv_buf <= (others => '0');
    
    elsif rising_edge(sys_clk) then
      IF(data_clk = '1' AND data_clk_prev = '0') THEN  
        CASE state IS
          WHEN idle =>                      --idle state             
              byte_cnt <= 1;
              bit_cnt <= 7;
            IF(start = '1') THEN              
              cmd_buf <= slv_addr & '0';                
              shift_reg <= send_data(15 downto 0);          
              point_register <= point_reg;     
              done <= '0';
              recv_buf <= (others => '0');
              state <= start_st;              
            ELSE                             
              done <= '1';
              state <= idle;            
            END IF;
          WHEN start_st =>                     
                sda_int <= cmd_buf(bit_cnt);     
                state <= dev_addr;
                
          when dev_addr => 
            IF(bit_cnt = 0) THEN            
                if repe_start = '0' then
                    sda_int <= '1';         
                    bit_cnt <= 7;           
                    state <= slv_ack1;      
                else
                    sda_int <= '1';         
                    bit_cnt <= 7;           
                    state <= slv_ack3;      
              end if;
            ELSE                            
              bit_cnt <= bit_cnt - 1;       
              sda_int <= cmd_buf(bit_cnt-1);
              state <= dev_addr;            
            END IF;
          when slv_ack1 =>              
                if repe_start = '0' then
                    sda_int <= point_register(bit_cnt);   
                    state <= reg_addr; 
                    else
                    sda_int <= '1';
                    state <= read_data;
               end if;
  
                                      
          when reg_addr => 
            IF(bit_cnt = 0) THEN             
              sda_int <= '1';                
              bit_cnt <= 15;            ---for write mode                
              state <= slv_ack2;             			  
            ELSE                            
              bit_cnt <= bit_cnt - 1;      
              sda_int <= point_register(bit_cnt-1);
              state <= reg_addr;                  
            END IF;
          when slv_ack2 => 
                if rd_wr = '0' then
                    sda_int <= shift_reg(bit_cnt);
                    state <= write_data;              
                else
                    repe_start <= '1';
                    cmd_buf <= slv_addr & '1';      
                    state <= start_st;
                    bit_cnt <= 7;
                end if;
          when write_data =>        
            IF(bit_cnt = 8) or (bit_cnt = 0) THEN       
                if (byte_cnt = 1) then
                    sda_int <= '1';             
                    bit_cnt <= 7;              
                    state <= slv_ack3;           	
                elsif (byte_cnt = 0) then
                    bit_cnt <= 7;     
                    sda_int <= '1';     
                    state <= slv_ack4;              
                end if;            		  
            ELSE                           
              bit_cnt <= bit_cnt - 1;      
              sda_int <= shift_reg(bit_cnt-1); 
              state <= write_data;              
            END IF;
                     
          when slv_ack3 =>
            if rd_wr = '0' then
              state <= write_data; 
              byte_cnt <= byte_cnt-1;
              sda_int <= shift_reg(bit_cnt); 
              else
              sda_int <= '1';
              byte_cnt <= 1;
              state <= read_data;
              bit_cnt <= 15;
            end if;
            
           when slv_ack4 => 
                sda_int <= '1';
                state <= stop;
                 
          when read_data => 
            IF(bit_cnt = 0) or (bit_cnt = 8) THEN      
                if (byte_cnt = 1) then
                    sda_int <= '0';              
                    bit_cnt <= 7;                      
                    state <= mstr_ack;                 
                 elsif (byte_cnt = 0) then
                    sda_int <= '1';                    
                    bit_cnt <= 7;                      
                    state <= mstr_nack;                
                 ELSE                                  
                    sda_int <= '1';                    
                END IF;		 
            ELSE                                       
              bit_cnt <= bit_cnt - 1;                  
              state <= read_data; 
              sda_int <= '1';                      
            END IF;              
         
          when mstr_ack =>
                byte_cnt <= byte_cnt-1;
                state <= read_data;
                sda_int <= '1';
                
          when mstr_nack =>
                repe_start <= '0';
                recv_data <= recv_buf;
                state <= stop;
                
          WHEN stop =>                       
            done <= '1';                  
            state <= idle; 
                          
        END CASE;    
      ELSIF(data_clk = '0' AND data_clk_prev = '1') THEN  
        CASE state IS
          WHEN start_st =>                  
            IF(scl_ena = '0') THEN                  
              scl_ena <= '1';                   
            END IF;
          when read_data => 
              recv_buf(bit_cnt) <= sda;                
          
          WHEN stop =>
            done <= '1';
            scl_ena <= '0';                       
          WHEN OTHERS =>
            NULL;
        END CASE;
        end if;
      end if;
   end process;


  --set sda output
  WITH state SELECT
    sda_ena_n <= data_clk_prev WHEN start_st,     --generate start condition
                 NOT data_clk_prev WHEN stop,  --generate stop condition
                 sda_int WHEN OTHERS;          --set to internal sda signal    
      
  --set scl and sda outputs
  scl <= '0' WHEN (scl_ena = '1' AND scl_clk = '0') ELSE '1';       ---master generates clock always
  sda <= '0' WHEN sda_ena_n = '0' ELSE 'Z';


end Behavioral;
