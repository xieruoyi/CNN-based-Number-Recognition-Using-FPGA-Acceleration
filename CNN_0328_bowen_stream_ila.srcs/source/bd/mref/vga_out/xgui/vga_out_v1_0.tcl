# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "COUNTER_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "HORIZONTAL_PIXEL" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INPUT_RGB_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "OUTPUT_RGB_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "VERTICAL_PIXEL" -parent ${Page_0}


}

proc update_PARAM_VALUE.COUNTER_WIDTH { PARAM_VALUE.COUNTER_WIDTH } {
	# Procedure called to update COUNTER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.COUNTER_WIDTH { PARAM_VALUE.COUNTER_WIDTH } {
	# Procedure called to validate COUNTER_WIDTH
	return true
}

proc update_PARAM_VALUE.HORIZONTAL_PIXEL { PARAM_VALUE.HORIZONTAL_PIXEL } {
	# Procedure called to update HORIZONTAL_PIXEL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.HORIZONTAL_PIXEL { PARAM_VALUE.HORIZONTAL_PIXEL } {
	# Procedure called to validate HORIZONTAL_PIXEL
	return true
}

proc update_PARAM_VALUE.INPUT_RGB_WIDTH { PARAM_VALUE.INPUT_RGB_WIDTH } {
	# Procedure called to update INPUT_RGB_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INPUT_RGB_WIDTH { PARAM_VALUE.INPUT_RGB_WIDTH } {
	# Procedure called to validate INPUT_RGB_WIDTH
	return true
}

proc update_PARAM_VALUE.OUTPUT_RGB_WIDTH { PARAM_VALUE.OUTPUT_RGB_WIDTH } {
	# Procedure called to update OUTPUT_RGB_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUTPUT_RGB_WIDTH { PARAM_VALUE.OUTPUT_RGB_WIDTH } {
	# Procedure called to validate OUTPUT_RGB_WIDTH
	return true
}

proc update_PARAM_VALUE.VERTICAL_PIXEL { PARAM_VALUE.VERTICAL_PIXEL } {
	# Procedure called to update VERTICAL_PIXEL when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.VERTICAL_PIXEL { PARAM_VALUE.VERTICAL_PIXEL } {
	# Procedure called to validate VERTICAL_PIXEL
	return true
}


proc update_MODELPARAM_VALUE.INPUT_RGB_WIDTH { MODELPARAM_VALUE.INPUT_RGB_WIDTH PARAM_VALUE.INPUT_RGB_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INPUT_RGB_WIDTH}] ${MODELPARAM_VALUE.INPUT_RGB_WIDTH}
}

proc update_MODELPARAM_VALUE.OUTPUT_RGB_WIDTH { MODELPARAM_VALUE.OUTPUT_RGB_WIDTH PARAM_VALUE.OUTPUT_RGB_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUTPUT_RGB_WIDTH}] ${MODELPARAM_VALUE.OUTPUT_RGB_WIDTH}
}

proc update_MODELPARAM_VALUE.COUNTER_WIDTH { MODELPARAM_VALUE.COUNTER_WIDTH PARAM_VALUE.COUNTER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.COUNTER_WIDTH}] ${MODELPARAM_VALUE.COUNTER_WIDTH}
}

proc update_MODELPARAM_VALUE.HORIZONTAL_PIXEL { MODELPARAM_VALUE.HORIZONTAL_PIXEL PARAM_VALUE.HORIZONTAL_PIXEL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.HORIZONTAL_PIXEL}] ${MODELPARAM_VALUE.HORIZONTAL_PIXEL}
}

proc update_MODELPARAM_VALUE.VERTICAL_PIXEL { MODELPARAM_VALUE.VERTICAL_PIXEL PARAM_VALUE.VERTICAL_PIXEL } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.VERTICAL_PIXEL}] ${MODELPARAM_VALUE.VERTICAL_PIXEL}
}

