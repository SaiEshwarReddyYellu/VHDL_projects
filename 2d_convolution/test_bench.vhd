

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.04.2022 17:01:27
-- Design Name: 
-- Module Name: image_ex_tb - Behavioral
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
USE ieee.STD_LOGIC_unsigned.ALL;
USE IEEE.STD_LOGIC_arith.ALL;
USE ieee.STD_LOGIC_misc.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity image_ex_tb is
--  Port ( );
end image_ex_tb;

architecture Behavioral of image_ex_tb is

signal clk : std_logic := '0';
signal rst : std_logic := '1';


constant clk_time : time := 10ns;

begin

    clk <= not clk after clk_time/2;
            
            
matrix_def_uut: entity work.matrix_def
    port map(
        clk => clk,
        rst => rst
            );


process
    begin
        rst <= '1';
        wait for clk_time * 5;    
        rst <= '0';
        wait for clk_time * 5;
        wait;
end process;

end Behavioral;
