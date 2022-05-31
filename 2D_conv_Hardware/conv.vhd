----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.05.2022 13:06:14
-- Design Name: 
-- Module Name: conv - Behavioral
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

entity conv is
--  Port ( );
    port (
        i_clk : in std_logic;
        i_rstn : in std_logic;
        i_pixel_in : in std_logic_vector(71 downto 0);
        i_pixel_valid : in std_logic;
        conv_data_out : out std_logic_vector(7 downto 0);
        conv_valid : out std_logic
            );
end conv;

architecture Behavioral of conv is

shared variable i : integer;
type kernel is array(integer range <>) of std_logic_vector(7 downto 0);
signal i_kernel : kernel(8 downto 0);

type mul_out is array(integer range <>) of std_logic_vector(15 downto 0);
signal mul_data : mul_out(8 downto 0);

signal sum_out : std_logic_vector(15 downto 0) := (others =>'0');
signal sum_data : std_logic_vector(15 downto 0)  := (others =>'0');

signal final_div : integer := 0;

signal sum_valid : std_logic;
signal mul_valid : std_logic;
signal mul_valid_1 : std_logic;
signal conv_valid_i : std_logic;

begin

    
    conv_valid <= conv_valid_i;

process(i_clk)
begin
      
   if rising_edge(i_clk) then 
        for i in 0 to 8 loop
            i_kernel(i) <= x"01";       
        end loop;
    end if;
    
    if rising_edge(i_clk) then 
        for i in 0 to 8 loop
            mul_data(i) <= i_kernel(i) * i_pixel_in((((i+1)*8)-1) downto (i*8));       
        end loop;
        mul_valid <= i_pixel_valid;
    end if; 
   
     if rising_edge(i_clk) then 
        if mul_valid = '1' then          
            for i in 0 to 8 loop
                sum_data <= mul_data(0)or mul_data(1)or mul_data(2)or mul_data(3)or mul_data(4)or mul_data(5)or mul_data(6)or mul_data(7)or mul_data(8);       
            end loop;
            mul_valid_1 <='1';
        end if;
    end if;
    
    if rising_edge(i_clk) then
        if mul_valid_1 = '1' then
            final_div <= to_integer(unsigned(sum_data)/9);
            conv_data_out <= std_logic_vector(to_unsigned(final_div,conv_data_out'length));
            conv_valid_i <= '1';
        end if;
        
    end if;
end process;

end Behavioral;


