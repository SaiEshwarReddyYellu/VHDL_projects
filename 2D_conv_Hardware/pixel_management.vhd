----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.05.2022 11:23:00
-- Design Name: 
-- Module Name: pixel_management - Behavioral
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
use ieee.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pixel_management is
--  Port ( );
    port (
        i_clk : in std_logic;
        i_rstn : in std_logic;
        pixel : in std_logic_vector(7 downto 0);
        pixel_valid : in std_logic;
        pixel_out : out std_logic_vector(71 downto 0);
        pixel_out_valid : out std_logic;
        intrr : out std_logic
            );
end pixel_management;

architecture Behavioral of pixel_management is

signal pixel_counter : std_logic_vector(8 downto 0);
shared variable write_line : std_logic_vector(1 downto 0);
signal line_buf_valid : std_logic_vector(3 downto 0);

signal line_buf_read_data : std_logic_vector(3 downto 0);
signal rd_line : std_logic_vector(1 downto 0);

signal rd_line_buffer : std_logic;
signal rd_counter : std_logic_vector(8 downto 0);

signal lb_out_0 : std_logic_vector(23 downto 0);
signal lb_out_1 : std_logic_vector(23 downto 0);
signal lb_out_2 : std_logic_vector(23 downto 0);
signal lb_out_3 : std_logic_vector(23 downto 0);

signal total_pxels : std_logic_vector(11 downto 0);

 
type state_type is (idle, read);
signal state : state_type;


begin
 
 line_1_ins : entity work.line_buffer
port map(
        i_clk => i_clk,
        i_rstn  => i_rstn,
        i_data => pixel,
        i_valid => line_buf_valid(0),
        o_data => lb_out_0,
        i_rd_data => line_buf_read_data(0)
        );

line_2_ins : entity work.line_buffer
port map(
        i_clk => i_clk,
        i_rstn  => i_rstn,
        i_data => pixel,
        i_valid => line_buf_valid(1),
        o_data => lb_out_1,
        i_rd_data => line_buf_read_data(1)
        );


line_3_ins : entity work.line_buffer
port map(
        i_clk => i_clk,
        i_rstn  => i_rstn,
        i_data => pixel,
        i_valid => line_buf_valid(2),
        o_data => lb_out_2,
        i_rd_data => line_buf_read_data(2)
        );


line_4_ins : entity work.line_buffer
port map(
        i_clk => i_clk,
        i_rstn  => i_rstn,
        i_data => pixel,
        i_valid => line_buf_valid(3),
        o_data => lb_out_3,
        i_rd_data => line_buf_read_data(3)
        );
    
process(i_clk)
variable line_buf_no : integer range 0 to 3;

begin

    pixel_out_valid <= rd_line_buffer;

if rising_edge(i_clk) then
    if i_rstn = '0' then
       total_pxels <= (others =>'0'); 
        else
            if (pixel_valid = '1') and ( rd_line_buffer = '0') then
                total_pxels <= total_pxels + 1;
                elsif (pixel_valid = '0') and ( rd_line_buffer = '1') then
                total_pxels <= total_pxels - 1;
            end if;
    end if;
end if;

if rising_edge(i_clk) then
    if i_rstn = '0' then
        state <= idle;
        rd_line_buffer <= '0';
        intrr <= '0';
        else
        case state is
            when idle => 
                intrr <= '0';
                if (total_pxels >= 1536) then                   ---------
                   rd_line_buffer <= '1';
                   state <= read;
                end if; 
                
            when read => 
                if rd_counter = 511 then
                   state <= idle; 
                   rd_line_buffer <= '0';
                end if; 
                intrr <= '1';   
        end case;
    end if;
end if;


    if rising_edge(i_clk) then
        if i_rstn = '0' then
           pixel_counter <= (others => '0');
           elsif pixel_valid = '1' then
                pixel_counter <= pixel_counter + 1;
        end if;
    end if;
    
    if rising_edge(i_clk) then
        if i_rstn = '0' then
            write_line := b"00";
            line_buf_no := 0; 
            else
                if (pixel_counter = 511) and (pixel_valid = '1') then
                   write_line := write_line + 1;
                   line_buf_no := to_integer(unsigned(write_line)); 
                end if;
        end if;
    end if;
    
--    if rising_edge(i_clk) then
      if i_rstn = '1' then
          line_buf_valid <= "0000"; 
          line_buf_valid (line_buf_no) <= pixel_valid; 
    end if;

if rising_edge(i_clk) then
    if i_rstn = '0' then
        rd_counter <= (others =>'0');
        else
        if (rd_line_buffer = '1') then
            rd_counter <= rd_counter + 1;        
        end if;
    end if;
end if;


if rising_edge(i_clk) then
    if i_rstn = '0' then
        rd_line <= "00";
        else
        if (rd_counter =  511) and (rd_line_buffer = '1') then
            rd_line <= rd_line + 1;        
        end if;
        
        case (rd_line) is

            when "00" =>
                    pixel_out <= lb_out_2 & lb_out_1 & lb_out_0;

            when "01" =>
                    pixel_out <= lb_out_3 & lb_out_2 & lb_out_1;
                    
            when "10" =>
                    pixel_out <= lb_out_0 & lb_out_3 & lb_out_2;
                    
            when "11" =>
                    pixel_out <= lb_out_1 & lb_out_0 & lb_out_3;
                    
            when others =>
                 rd_line <= "00";
                
        end case;
        
    end if;
end if;



case(rd_line) is
    when "00" =>
        line_buf_read_data(0) <= rd_line_buffer;
        line_buf_read_data(1) <= rd_line_buffer;
        line_buf_read_data(2) <= rd_line_buffer;
        line_buf_read_data(3) <= '0';
        
    when "01" =>
        line_buf_read_data(0) <= '0';
        line_buf_read_data(1) <= rd_line_buffer;
        line_buf_read_data(2) <= rd_line_buffer;
        line_buf_read_data(3) <= rd_line_buffer;
        
    when "10" =>
        line_buf_read_data(0) <= rd_line_buffer;
        line_buf_read_data(1) <= '0';
        line_buf_read_data(2) <= rd_line_buffer;
        line_buf_read_data(3) <= rd_line_buffer;
        
    when "11" =>
        line_buf_read_data(0) <= rd_line_buffer;
        line_buf_read_data(1) <= rd_line_buffer;
        line_buf_read_data(2) <= '0';
        line_buf_read_data(3) <= rd_line_buffer;
        
     when others =>
        rd_line <= "00";
end case;
 

    
end process;

end Behavioral;
