puts "======================================================================="
puts "================== vJTAG Interface Control Constants =================="
puts "================================================================tvSh==="

##############################################################################################
##################################### Additional proc ########################################
##############################################################################################

# Sleep 
proc sleep {time} {
	after $time set end 1
	vwait end
}
# sleep 20000

proc hex2dec {largeHex} {
    set res 0
    foreach hexDigit [split $largeHex {}] {
        set new 0x$hexDigit
        set res [expr {16*$res + $new}]
    }
    return $res
}

proc hex2bin {hex} {
  binary scan [binary format H* $hex] B* bin
  return $bin
}


##############################################################################################
################################### Basic vJTAG Interface ####################################
##############################################################################################

global usbblaster_name
global test_device
global open_port_set
# flag_read_write: 0 - read; 1 - write
global flag_read_write
global bash_en

# Set Command line mode
set arg_bash [lsearch -exact $argv "bash"]
if { $arg_bash == -1} {
	set bash_en 0
} else {
	set bash_en 1
	puts "=========================== Command line mode ========================="
}

# # Set Command line mode
# if { $argc > 0 && [lindex $argv] == "bash"} {
# 	set bash_en 1
# 	puts "=========================== Command line mode ========================="
# } else {
# 	set bash_en 0
# }

# Definition $usbblaster_name
puts "\nAll available programming hardwares:"
puts "-----------------------------------------------"
set hardware_list [get_hardware_names]
set hw_list_length [llength $hardware_list]
set num 0
foreach hardware_name $hardware_list {
	puts "$num: $hardware_name"
	set num [expr $num + 1]
}
set arg_hardware [lsearch -exact $argv "hardware"]
if { $arg_hardware == -1 } {
	if { $hw_list_length > 1 } {
		puts "More than one device. Please select the hardware:"
		set hardware_num [gets stdin]
		while { $hardware_num > [expr $hw_list_length - 1] } {
			puts "Wrong JTAG hardware. Try again."
			set hardware_num [gets stdin]
		}
	} else {
		set hardware_num 0
		puts "\nSelect hardware 0 by default."
	}
} else {
	set arg_hardware_num [lindex $argv [expr $arg_hardware + 1]]
	if { $arg_hardware_num == "" || $arg_hardware_num > [expr $hw_list_length - 1] } {
		set hardware_num 0
		puts "\nWrong JTAG hardware. Select hardware 0 by default."
	} else {
		set hardware_num $arg_hardware_num
		puts "\nSelect hardware $hardware_num"
	}
}
set usbblaster_name [lindex $hardware_list $hardware_num]
puts "Select JTAG chain connected to $usbblaster_name."

# puts "\nAll available programming hardwares:"
# puts "-----------------------------------------------"

# foreach hardware_name [get_hardware_names] {
# 	puts "\t- $hardware_name"
# 	# if { [string match "EthernetBlaster*" $hardware_name] } {
# 	# 	set usbblaster_name $hardware_name
# 	# } 
# 	if { [string match "USB-Blaster*" $hardware_name] } {
# 		set usbblaster_name $hardware_name
# 	} 	
# }
# puts "Select JTAG chain connected to $usbblaster_name."

# Definition $test_device
puts "\nAll devices on the chain:"
puts "-----------------------------------------------"
foreach device_name [get_device_names -hardware_name $usbblaster_name] {
	puts "\t- $device_name"
	if { [string match "@1*" $device_name] } {
		set test_device $device_name
	}
}
puts "Select device: $test_device."

# Open device 
proc OpenPort {} {
	global usbblaster_name
	global test_device
	open_device -hardware_name $usbblaster_name -device_name $test_device
}

# Close device.  Just used if communication error occurs
proc ClosePort {} {
	catch {device_unlock}
	catch {close_device}
}

# Data write & transmission 
proc TransDataW {} {
	puts "\nData transmission ("
	puts "-----------------------------------------------"
	
	# Gets IR DR Data
	# IR
	puts -nonewline "IR_DATA: 0x"
	flush stdout
	set ir_data [gets stdin]
	set length_ir [string length $ir_data]
	if {$length_ir == 0 || $length_ir > 4} {
		puts "ERROR: IR_DATA == 0, IR_DATA > 4"
		return 0
	}
	set ir_data [hex2dec $ir_data]
	# DR
	puts -nonewline "DR_DATA: 0x"
	flush stdout
	set dr_data [gets stdin]
	set dr_data [string trim $dr_data]
	set dr_data [string toupper $dr_data]
	set length_dr [string length $dr_data]
	if {$length_dr > 16} {
		puts "ERROR: DR_DATA == 0, DR_DATA > 16"
		return 0
	}
	while {$length_dr < 16 } {
		append dr_data_long "0"
		incr length_dr
	}
	append dr_data_long $dr_data
	
	# Transmission
	OpenPort

	device_lock -timeout 10000
	
	device_virtual_ir_shift -instance_index 0 -ir_value $ir_data -no_captured_ir_value
	set tdi1 [device_virtual_dr_shift -dr_value $dr_data_long -instance_index 0  -length 64 -value_in_hex]
	device_virtual_ir_shift -instance_index 0 -ir_value 0 -no_captured_ir_value
	set tdi [device_virtual_dr_shift -dr_value "0000000000000000" -instance_index 0  -length 64 -value_in_hex]
	
	puts "IR: $ir_data; DR: $dr_data_long"
	puts "OUTPUT: $tdi"
	
	ClosePort
	
}

# Data read & transmission
proc TransData {line} {

	global flag_read_write

	puts "\nData transmission"
	puts "-----------------------------------------------"
	
	# Analysis of data
	set line [string trim $line]
	set line [string toupper $line]
	
	set data_array [split $line]	
	set ir_data [lindex $data_array 0]
	set dr_data [lindex $data_array 1]

	# IR
	set length_ir [string length $ir_data]
	if {$length_ir == 0 || $length_ir > 4} {
		puts "ERROR: IR_DATA == 0, IR_DATA > 4"
		return 0
	}
	set ir_data_long ""
	while {$length_ir < 4 } {
		append ir_data_long "0"
		incr length_ir
	}
	append ir_data_long $ir_data
	set ir_data_long [hex2bin $ir_data_long]
	set flag_read_write [string index $ir_data_long 1]
	
	set ir_data [hex2dec $ir_data]

	# DR
	set length_dr [string length $dr_data]
	if {$length_dr > 16} {
		puts "ERROR: DR_DATA == 0, DR_DATA > 16"
		return 0
	}
	set dr_data_long ""
	while {$length_dr < 16 } {
		append dr_data_long "0"
		incr length_dr
	}
	append dr_data_long $dr_data
		
	
	# Transmission
	OpenPort

	device_lock -timeout 100
	
	device_virtual_ir_shift -instance_index 0 -ir_value $ir_data -no_captured_ir_value
	set tdi1 [device_virtual_dr_shift -dr_value $dr_data_long -instance_index 0  -length 64 -value_in_hex]
	device_virtual_ir_shift -instance_index 0 -ir_value 0 -no_captured_ir_value
	set tdi [device_virtual_dr_shift -dr_value "0000000000000000" -instance_index 0  -length 64 -value_in_hex]
	
	set ir_data_hex [format %x $ir_data]
	
	set lengthIR [string length $ir_data_hex]
	set ir_and_data ""
	
	while {$lengthIR < 4 } {
		append ir_and_data "0"
		incr lengthIR
	}
	
	append ir_and_data "$ir_data_hex"
	append ir_and_data " $tdi"
	
	puts "IR: $ir_data"
	puts "DR: $dr_data_long"
	puts "OUTPUT: $ir_and_data"
	
	ClosePort
	
	if {$flag_read_write == 0} {
#		return $tdi
		return $ir_and_data
	} else {
		return 0
	}
	
}

##############################################################################################
######################################## TCP/IP Server #######################################
##############################################################################################

# Start server with your PORT
proc Start_Server {port} {
	puts "\nStart Server (port: $port)"
	puts "-----------------------------------------------"
	
	global bash_en
	global open_port_set
	
	# Server TCP/IP or Bash mode
	if {$bash_en == 1} {
		# Run TransData always
		while {true} {
			TransDataW
			sleep 1000
		}
		
	} else {
		set open_port_set [socket -server ConnAccept $port]
		puts "Socket return: $open_port_set"
		# puts "Socket fconfigure: [fconfigure $open_port_set]"
		vwait forever
	}
}


proc ConnAccept {sock addr port} {
    global conn

    # Record the client's information

    puts "Accept $sock from $addr port $port"
    set conn(addr,$sock) [list $addr $port]

    # Ensure that each "puts" by the server
    # results in a network transmission

    fconfigure $sock -buffering line
	
    # Set up a callback for when the client sends data

    fileevent $sock readable [list IncomingData $sock]
}

proc IncomingData {sock} {
    global conn
	
    # Check end of file or abnormal connection drop,
    # then write the data to the vJTAG
    if {[eof $sock] || [catch {gets $sock line}]} {
		close $sock
		puts "Close $conn(addr,$sock)"
		unset conn(addr,$sock)

    } else {
		if {$line == ""} {
			puts "TCP/IP ==> NULL"
			return
		}
		set returnTransData [TransData $line]
		if {$returnTransData != 0} {
			puts $sock $returnTransData
			puts "TCP/IP <== $returnTransData"
		}
    }
	
	
}


##############################################################################################
####################################### Start program ########################################
##############################################################################################

set arg_server_port [lsearch -exact $argv "port"]
if { $arg_server_port == -1 } {
	set server_port 2540
	puts "\n No port argument. Select port 2540 by default."
} else {
	set server_port [lindex $argv [expr $arg_server_port + 1]]
	if { $server_port == "" } {
		set server_port 2540
		puts "\nSelect port 2540 by default."
	}
}
Start_Server $server_port
