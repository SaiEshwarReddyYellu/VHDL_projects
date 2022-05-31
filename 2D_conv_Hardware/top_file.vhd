----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.05.2022 15:02:31
-- Design Name: 
-- Module Name: top_file - Behavioral
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
use std.textio.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_file is
--  Port ( );
    port(
        axi_clk : in std_logic;
        axi_rstn : in std_logic;
        -- axi slave
        i_data_valid : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_data_ready : out std_logic;
        
        --axi master
        o_data_valid : out std_logic;
        o_data : out std_logic_vector(7 downto 0);
        i_data_ready : in std_logic;
        
        --interrupt
        intr_out : out std_logic
            );
end top_file;

architecture Behavioral of top_file is

signal pixel_manag_output : std_logic_vector(71 downto 0) := (others =>'0');
signal pixel_manag_valid : std_logic := '0';

signal conv_data_out_i : std_logic_vector(7 downto 0);
signal conv_valid_i : std_logic;

begin

o_data <= conv_data_out_i;
o_data_valid <= conv_valid_i;

pixel_manag_ins: entity work.pixel_management
    port map(
        i_clk => axi_clk,
        i_rstn => axi_rstn,
        pixel => i_data,
        pixel_valid => i_data_valid,
        pixel_out => pixel_manag_output,
        pixel_out_valid => pixel_manag_valid,
        intrr => intr_out
            );
            
conv_ins : entity work.conv
    port map(
        i_clk  => axi_clk,
        i_rstn  => axi_rstn,
        i_pixel_in  => pixel_manag_output,
        i_pixel_valid => pixel_manag_valid,
        conv_data_out  => conv_data_out_i,
        conv_valid => conv_valid_i
            );

end Behavioral;
