----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.04.2022 11:27:32
-- Design Name: 
-- Module Name: matrix_def - Behavioral
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
use ieee.std_logic_unsigned.all;
use work.sub_routines.all;


entity matrix_def is
    generic(
        image_row_size : integer := 5;
        image_column_size : integer := 5;
        kernel_row_size : integer := 3;
        kernel_column_size : integer := 3
            );
--  Port ( );
    port(
        clk : in std_logic;
        rst : in std_logic
            );
end matrix_def;

architecture Behavioral of matrix_def is

constant total_strides : integer := kernel_row_size * kernel_column_size;
signal stride_row : integer := 0;
signal stride_column : integer := 0;
signal stride_out_col : integer := 0;
signal stride_out_row : integer := 0;


signal matrix_element : std_logic_vector(7 downto 0) := (others => '0');
signal kernel_element : std_logic_vector(7 downto 0) := (others => '0');

signal image_completed_flag : std_logic := '0';
signal kernel_completed_flag : std_logic := '0';

signal image : two_d_matrix_type(1 to image_row_size, 1 to image_column_size) := (others => (others => (others => '0')));
signal kernel : two_d_matrix_type(1 to kernel_row_size, 1 to kernel_column_size) := (others => (others => (others => '0')));

signal kernel_trans : two_d_matrix_type (1 to kernel_row_size, 1 to kernel_column_size) := (others => (others => (others => '0')));

signal matrix_sub : two_d_matrix_type (1 to kernel_row_size, 1 to kernel_column_size) := (others => (others => (others => '0')));

signal image_x_kernel : two_d_matrix_type_mul(1 to kernel_row_size, 1 to kernel_column_size) := (others => (others => (others => '0')));

signal conv_matrix_element : std_logic_vector(19 downto 0) := (others => '0');
signal conv_matrix_elements_buf : std_logic_vector(179 downto 0) := (others => '0');
signal conv_done : std_logic := '0';

signal convoluted_matrix : final_matrix_type(1 to kernel_row_size, 1 to kernel_column_size) := (others => (others => (others => '0')));
-----------------------------------------------------------------------------


----- state machine
type state_type is (idle,image_fill, kernel_fill, transpose,sub_matrix,striding,multiply,adding_elements,last_element, conv_matrix,finished);
signal state, next_state : state_type := idle;


begin
 
    two_D_convolution_seq : process(clk,rst)
        variable result : std_logic_vector(7 downto 0) := (others =>'0');
            
        begin
             
        if rst = '1' then   
            image <= matrix_fill_with_zeros(image_row_size,image_column_size); 
            kernel <= matrix_fill_with_zeros(kernel_row_size,kernel_column_size);
            state <= idle;
            
            elsif rising_edge(clk) then   
                if next_state = image_fill then
                        matrix_fill(image_row_size,image_column_size, "matrix_value.mem",clk,matrix_element,image_completed_flag,image);
                    
                    elsif next_state = kernel_fill then
                        matrix_fill(kernel_row_size,kernel_column_size, "kernel_value.mem",clk,kernel_element,kernel_completed_flag,kernel);
                    
                    elsif next_state = transpose then
                        kernel_trans <= matrix_transpose(kernel_row_size,kernel_column_size,kernel); 
                        
                    elsif next_state = sub_matrix then
                        sub_matrix(image_row_size,image_column_size,image,stride_row,stride_column,clk,stride_out_col,stride_out_row,matrix_sub);
                        
                    elsif next_state = multiply then
                        image_x_kernel <= matrix_multiply(kernel_row_size,kernel_column_size,matrix_sub,kernel_trans);
                        
                    elsif (next_state = adding_elements) or (next_state = last_element) then 
                        conv_matrix_element <= add_elements(image_x_kernel);
                        conv_matrix_elements_buf  <= conv_matrix_element & conv_matrix_elements_buf(179 downto 20);
                        
                    elsif (next_state = conv_matrix) then
                        conv_matrix(kernel_row_size, kernel_column_size, conv_matrix_elements_buf,clk, convoluted_matrix);
                end if; 
                
                state <= next_state;   
        end if;
    end process two_D_convolution_seq;
    
    
    two_D_convolution_comb : process(state, next_state,image_completed_flag,kernel_completed_flag,stride_row,stride_column,stride_out_row,stride_out_col,conv_done)
    begin
        next_state <= state;
    
        case state is
            when idle =>
                next_state <= image_fill;
            when image_fill => 
                  if image_completed_flag = '1' then
                    next_state <= kernel_fill;
                    else
                    next_state <= image_fill;
                  end if;
                  
            when kernel_fill =>
                if kernel_completed_flag = '1' then
                    next_state <= transpose;
                    else
                    next_state <= kernel_fill;
                  end if;
                  
            when transpose =>
                    next_state <= sub_matrix;
                    
            
            when sub_matrix =>
                    next_state <= striding;
                    
            when striding =>
                    next_state <= multiply;
            
            when multiply  =>
                if (stride_out_row = kernel_row_size) then 
                    conv_done <= '1';
                end if;
                    next_state <= adding_elements;
                
            when adding_elements =>                          
                    if ((stride_out_col < 3) or (stride_out_row < 3)) and (conv_done = '0') then 
                        stride_column <= stride_out_col;
                        stride_row <= stride_out_row;
                        next_state <= sub_matrix;
                        
                    elsif (conv_done = '1') then
                        next_state <= last_element;
                 end if;
                 
            when last_element =>
                next_state <= conv_matrix;
            
            when conv_matrix =>
                next_state <= finished;
                
            when finished =>
                conv_done <= '0';
                stride_row <= 0;
                stride_column <= 0;
                
            when others =>
                next_state <= idle;
                
        end case;
    end process two_D_convolution_comb;

end Behavioral;

