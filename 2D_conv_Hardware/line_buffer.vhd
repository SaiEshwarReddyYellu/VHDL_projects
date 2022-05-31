------------------------------------------------------------------------------------
---- Company: 
---- Engineer: 
---- 
---- Create Date: 13.05.2022 10:47:45
---- Design Name: 
---- Module Name: line_buffer - Behavioral
---- Project Name: 
---- Target Devices: 
---- Tool Versions: 
---- Description: 
---- 
---- Dependencies: 
---- 
---- Revision:
---- Revision 0.01 - File Created
---- Additional Comments:
---- 
------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

---- Uncomment the following library declaration if using
---- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx leaf cells in this code.
----library UNISIM;
----use UNISIM.VComponents.all;

entity line_buffer is
--  Port ( );
    port (
        i_clk : in std_logic;
        i_rstn : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        i_valid : in std_logic;
        o_data : out std_logic_vector(23 downto 0);
        i_rd_data : in std_logic
            );
end line_buffer;

architecture Behavioral of line_buffer is

component blk_mem_gen_0 is
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  ); 
 end component;

signal ena_i : std_logic;
signal wea_i : std_logic_vector(0 downto 0);
signal addra_i : std_logic_vector(8 downto 0);
signal enb_i : std_logic;
signal addrb_i : std_logic_vector(8 downto 0);
signal bram_out : std_logic_vector(7 downto 0);

signal pixel_pipeline_1 : std_logic_vector(7 downto 0);
signal pixel_read : std_logic_vector(23 downto 0);

begin

    o_data <= pixel_read;

blk_mem_gen_0_ins : blk_mem_gen_0
port map(
    clka => i_clk,
    ena => ena_i,
    wea => wea_i,
    addra => addra_i,
    dina => pixel_pipeline_1,
    clkb => i_clk,
    enb => enb_i,
    addrb => addrb_i,
    doutb => bram_out
        );

ctrl_proc : process(i_clk)
begin
    if rising_edge(i_clk) then
        if (i_rstn = '0') then
            addra_i <= (others =>'0');
            ena_i <= '0';
        end if;    
                 
                 if i_valid = '1' then
                    pixel_pipeline_1 <= i_data;
                    ena_i <= '1';
                    wea_i <= "1";
                    else
                    ena_i <= '0'; 
                    wea_i <= "0";
                 end if;
                                     
                
                if ena_i = '1' then
                        addra_i <= addra_i + 1;
                        
                        if addra_i = o"777" then
                           addra_i <= o"000"; 
                        end if;
                        
                    else
                         wea_i <= "0";     
                end if;                          
    end if;
    
    if rising_edge(i_clk) then 
         if (i_rstn = '0') then
            addrb_i <= (others =>'0');
            enb_i <= '0';
            
            else
             
                 if i_rd_data = '1' then
                    enb_i <= '1';
                    else
                    enb_i <= '0';
                end if;                 
                   
             if enb_i = '1' then    
                  addrb_i <= addrb_i + 1;
                  pixel_read <= bram_out & pixel_read(23 downto 8);
                  else
                  addrb_i <= o"000";
             end if; 
            
         end if;
    end if;

    
end process ctrl_proc;


end Behavioral;
