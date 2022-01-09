
#CLOCKS
set_property PACKAGE_PIN AD12 [get_ports clk_p]
set_property PACKAGE_PIN AD11 [get_ports clk_n]
set_property IOSTANDARD DIFF_HSTL_I [get_ports clk_p]  
set_property IOSTANDARD DIFF_HSTL_I [get_ports clk_n]
create_clock -period 5 -waveform {0 2.5} -name clk_p  [get_ports clk_p]

#reset
set_property PACKAGE_PIN AB7 [get_ports rst]
set_property IOSTANDARD LVCMOS15 [get_ports rst]

#LCD_interface
set_property PACKAGE_PIN AA13 [get_ports lcd_out[0]]
set_property IOSTANDARD LVCMOS15 [get_ports lcd_out[0]]
set_property PACKAGE_PIN AA10 [get_ports lcd_out[1]]
set_property IOSTANDARD LVCMOS15 [get_ports lcd_out[1]]
set_property PACKAGE_PIN AA11 [get_ports lcd_out[2]]
set_property IOSTANDARD LVCMOS15 [get_ports lcd_out[2]]
set_property PACKAGE_PIN Y10 [get_ports lcd_out[3]]
set_property IOSTANDARD LVCMOS15 [get_ports lcd_out[3]]
set_property PACKAGE_PIN AB13 [get_ports rw]
set_property IOSTANDARD LVCMOS15 [get_ports rw]
set_property PACKAGE_PIN Y11 [get_ports rs]
set_property IOSTANDARD LVCMOS15 [get_ports rs]
set_property PACKAGE_PIN AB10 [get_ports lcd_e]
set_property IOSTANDARD LVCMOS15 [get_ports lcd_e]

#LEDS
set_property PACKAGE_PIN AB8 [get_ports leds[0]]
set_property IOSTANDARD LVCMOS15 [get_ports leds[0]]
set_property PACKAGE_PIN AA8 [get_ports leds[1]]
set_property IOSTANDARD LVCMOS15 [get_ports leds[1]]
set_property PACKAGE_PIN AC9 [get_ports leds[2]]
set_property IOSTANDARD LVCMOS15 [get_ports leds[2]]
set_property PACKAGE_PIN AB9 [get_ports leds[3]]
set_property IOSTANDARD LVCMOS15 [get_ports leds[3]]
set_property PACKAGE_PIN AE26 [get_ports leds[4]]
set_property IOSTANDARD LVCMOS25 [get_ports leds[4]]
set_property PACKAGE_PIN G19 [get_ports leds[5]]
set_property IOSTANDARD LVCMOS25 [get_ports leds[5]]
set_property PACKAGE_PIN E18 [get_ports leds[6]]
set_property IOSTANDARD LVCMOS25 [get_ports leds[6]]
set_property PACKAGE_PIN F16 [get_ports leds[7]]
set_property IOSTANDARD LVCMOS25 [get_ports leds[7]]

#set_property PACKAGE_PIN F16 [get_ports GPIO_LED_7_LS]
#set_property IOSTANDARD LVCMOS25 [get_ports GPIO_LED_7_LS]


#GPIO#GPIO DIP 
set_property PACKAGE_PIN Y29 [get_ports switches[0]]
set_property IOSTANDARD LVCMOS25 [get_ports switches[0]]
set_property PACKAGE_PIN W29 [get_ports switches[1]]
set_property IOSTANDARD LVCMOS25 [get_ports switches[1]]
set_property PACKAGE_PIN AA28 [get_ports switches[2]]
set_property IOSTANDARD LVCMOS25 [get_ports switches[2]]
set_property PACKAGE_PIN Y28 [get_ports switches[3]]
set_property IOSTANDARD LVCMOS25 [get_ports switches[3]]

#GPIO PUSHBUTTON SW
set_property PACKAGE_PIN G12 [get_ports btnc]
set_property IOSTANDARD LVCMOS25 [get_ports btnc]
set_property PACKAGE_PIN AG5 [get_ports  btnl]
set_property IOSTANDARD LVCMOS15 [get_ports  btnl]
set_property PACKAGE_PIN AA12 [get_ports btnd]
set_property IOSTANDARD LVCMOS15 [get_ports btnd]
set_property PACKAGE_PIN AC6 [get_ports btnr]
set_property IOSTANDARD LVCMOS15 [get_ports btnr]
#set_property PACKAGE_PIN AB12 [get_ports GPIO_SW_S]      
#set_property IOSTANDARD LVCMOS15 [get_ports GPIO_SW_S]


