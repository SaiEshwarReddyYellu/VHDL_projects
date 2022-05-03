
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.04.2022 11:41:08
-- Design Name: 
-- Module Name: package_2d - Behavioral
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
-------------------------------------------------------
-- two 8-bit mul is resulted in 16 bit, so multiplied output matrix has 16 bits of each element

--for adding each 16 bit elements there are 9 elements in the matrix(kernel) so output width after adding is 16 + [log(9) base-2]= 16+4 := 20


-----------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library std;
use std.textio.all;
use IEEE.std_logic_textio.all;      --writting/reading std_logic

package sub_routines is
constant data_width : integer := 8;
constant mul_output : std_logic_vector(15 downto 0) := (others =>'0');
constant element_width : integer := 20;

--2D matrix cannot be sliced
--type two_d_matrix_type is array(natural range<>, natural range<>) of std_logic_vector ((data_width-1) downto 0);
--signal matrix : two_d_matrix_type(1 to row_size, 1 to column_size);

--2D matrix with 1D*1D
type row_matrix is array(integer range<>) of std_logic_vector(7 downto 0);
type two_d_matrix_type is array( integer range<>, integer range<> ) of std_logic_vector((data_width-1) downto 0);

type two_d_matrix_type_mul is array( integer range<>, integer range<> ) of std_logic_vector((2*data_width-1) downto 0);

type final_matrix_type is array( integer range<>, integer range<> ) of std_logic_vector(element_width-1 downto 0); 

---files
--file matrix_value : text;


--procedure
procedure matrix_fill(row_size : in integer; column_size : in integer; constant file_name : in string; signal clk : in std_logic;
     signal pixel : out std_logic_vector(7 downto 0); signal file_filled : out std_logic; signal image_from_proc : out two_d_matrix_type);

procedure sub_matrix(row_size : in integer; column_size : in integer;signal input_matrix : in two_d_matrix_type;signal stride_row : in integer;
signal stride_column : in integer; signal clk : in std_logic; signal stride_col1 : out integer; signal stride_row_out : out integer; signal image_from_proc : out two_d_matrix_type);

procedure conv_matrix(row_size : in integer; column_size : in integer;signal input_matrix : in std_logic_vector; signal clk : in std_logic; 
     signal final_matrix : out final_matrix_type);

--functions
function matrix_fill_with_zeros(row_size : integer; column_size : integer) return two_d_matrix_type;
function matrix_transpose(row_size : integer; column_size : integer;  matrix_trans :two_d_matrix_type) return two_d_matrix_type;
function matrix_multiply(row_size_1 : integer; column_size_1 : integer;  sub_matrix :two_d_matrix_type ; matrix_kernel :two_d_matrix_type) 
    return two_d_matrix_type_mul;
function add_elements ( multiplied_matrix : two_d_matrix_type_mul ) return std_logic_vector;
end package;






package body sub_routines is

---------------------   Reset matrix function  -----------------------------------
function matrix_fill_with_zeros(row_size : integer; column_size : integer) return two_d_matrix_type is
variable matrix_in : two_d_matrix_type(0 to (row_size-1),0 to (column_size-1));
begin
    for i in 0 to (row_size-1) loop
        for j in 0 to (column_size-1) loop
           matrix_in(i,j) := x"00";             
        end loop;
    end loop;
    return matrix_in;
end function matrix_fill_with_zeros;

---------------------   filling image matrix procedure  -----------------------------------
procedure matrix_fill(row_size : in integer; column_size : in integer; constant file_name : in string; signal clk : in std_logic;
     signal pixel : out std_logic_vector(7 downto 0); signal file_filled : out std_logic; signal image_from_proc : out two_d_matrix_type) is
file matrix_value : text open read_mode is file_name;
variable file_line : line;
variable element : std_logic_vector(pixel'range);

begin
    
    while not ENDFILE(matrix_value) loop
        for i in 1 to (row_size) loop
            for j in 1 to (column_size) loop
               if rising_edge(clk) then
                    readline(matrix_value,file_line);
                    hread(file_line,element);
                     
                     pixel <= element;
                     image_from_proc(i,j) <= element; 
                     
                          if (i = row_size and j = column_size) then
                             file_filled <= '1';
                             else
                             file_filled <= '0'; 
                          end if; 
                    
                 end if;              
            end loop;
       end loop; 
           
--    wait until rising_edge(clk);     syntax error occuring bcz of sensitivity list
    end loop;

end procedure matrix_fill;

---------------------   transpose matrix function  -----------------------------------
function matrix_transpose(row_size : integer; column_size : integer; matrix_trans :two_d_matrix_type) return two_d_matrix_type is
variable matrix_in : two_d_matrix_type(1 to (row_size),1 to (column_size));
variable matrix_out : two_d_matrix_type(1 to (row_size),1 to (column_size));

begin
    matrix_in := matrix_trans;
    
    for i in 1 to (row_size) loop
        for j in 1 to (column_size) loop
           matrix_out(i,j) :=  matrix_in(j,i);             
        end loop;
    end loop;
    return matrix_out;

end function matrix_transpose;

---------------------  sub matrix procedure  -----------------------------------

procedure sub_matrix(row_size : in integer; column_size : in integer;signal input_matrix : in two_d_matrix_type; signal stride_row : in integer; 
    signal stride_column : in integer; signal clk : in std_logic; signal stride_col1 : out integer; signal stride_row_out : out integer; signal image_from_proc : out two_d_matrix_type) is 

variable matrix_in1 : two_d_matrix_type(1 to (row_size),1 to (column_size));
variable matrix_out : two_d_matrix_type(1 to (row_size-2),1 to (column_size-2));
variable stride1 : integer;
variable stride_row1 : integer;
variable stride_col : integer;

begin
    matrix_in1 := input_matrix;
    stride1 := 0;
    stride_row1 := stride_row;
    stride_col := stride_column;
    
    for i in (1) to (row_size-2) loop
        for j in (1) to (column_size-2) loop
            if rising_edge(clk) then
                matrix_out(i,j) := matrix_in1(i+stride_row1, j+stride_col);
                image_from_proc <= matrix_out;
            end if;
        end loop;
    end loop;
    
    if rising_edge(clk) then
        if stride_col = 2 then
            stride_row_out <= stride_row1 + 1;
            stride_col1 <= 0;
            else
            stride_col1 <= stride_col+1;
        end if;
    end if;
 
    
end procedure;


---------------------  matrices multiply function  -----------------------------------
function matrix_multiply( row_size_1 : integer; column_size_1 : integer;  sub_matrix :two_d_matrix_type ; matrix_kernel :two_d_matrix_type) 
    return two_d_matrix_type_mul is
variable matrix_in1 : two_d_matrix_type(1 to (row_size_1),1 to (column_size_1));
variable matrix_in2 : two_d_matrix_type(1 to (row_size_1),1 to (column_size_1));
variable matrix_out : two_d_matrix_type_mul(1 to (row_size_1),1 to (column_size_1));
--variable accum : std_logic_vector(7 downto 0):= (others =>'0');
variable in1,in2,out1 : integer := 0;

begin
    matrix_in1 := sub_matrix;
    matrix_in2 := matrix_kernel;
    
        for i in matrix_in1'range(1) loop
            for j in matrix_in1'range(2) loop
--                accum := (others =>'0');
--                for k in matrix_in2'range(1) loop
--                    matrix_out(i,j) := matrix_out(i,j) + ((matrix_in1(i,k) * matrix_in2(k,j)));
                       in1 := to_integer(unsigned(matrix_in1(i,j)));
                       in2 := to_integer(unsigned(matrix_in2(i,j)));
                       out1 := (in1 * in2);
                       
                       matrix_out(i,j) := std_logic_vector(to_unsigned(out1,mul_output'length));
--                end loop;
                
            end loop;
        end loop;
    return matrix_out;
end function matrix_multiply;


---------------------  adding elements function  -----------------------------------
function add_elements ( multiplied_matrix :two_d_matrix_type_mul ) return std_logic_vector is
variable matrix_in1 : two_d_matrix_type_mul(1 to 3, 1 to 3);
variable accum : std_logic_vector(19 downto 0):= (others =>'0');
variable in1,in2,out1 : integer := 0;

begin
    matrix_in1 := multiplied_matrix;

    for i in  matrix_in1'range(1) loop
        for j in matrix_in1'range(2) loop
            in1 := to_integer(unsigned(matrix_in1(i,j)));
            in2 := to_integer(unsigned(accum));
            out1 := in1 + in2;
            accum := std_logic_vector(to_unsigned(out1,accum'length)) ;   
        end loop;
    end loop;
return accum;
end function add_elements;



-----------------------  capturing convoluted elements form std logic vector  -----------------------------------
procedure conv_matrix(row_size : in integer; column_size : in integer;signal input_matrix : in std_logic_vector; signal clk : in std_logic; 
     signal final_matrix : out final_matrix_type) is 
    
     variable vector_in : std_logic_vector(179 downto 0):= (others => '0');
     variable vector_sub : std_logic_vector(19 downto 0) := (others => '0');
     variable matrix_out : final_matrix_type(1 to 3, 1 to 3);
begin
    vector_in := input_matrix;

    for i in matrix_out'range(1) loop
        for j in matrix_out'range(2) loop
            if rising_edge(clk) then
                vector_sub := vector_in(19 downto 0);
                vector_in := "--------------------" & vector_in(179 downto 20);
               matrix_out(i,j) := vector_sub;                 
            end if;
        end loop;
    end loop;
    final_matrix <= matrix_out;
    
end procedure conv_matrix;   


end sub_routines;
