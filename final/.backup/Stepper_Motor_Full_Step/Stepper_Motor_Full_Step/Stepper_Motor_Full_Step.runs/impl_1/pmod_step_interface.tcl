proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {Common 17-41} -limit 10000000
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000

start_step init_design
set rc [catch {
  create_msg_db init_design.pb
  set_property design_mode GateLvl [current_fileset]
  set_property webtalk.parent_dir C:/Users/kfranz/Desktop/steppermotorwithfpgainst/Stepper_Motor_Full_Step/Stepper_Motor_Full_Step.cache/wt [current_project]
  set_property parent.project_path C:/Users/kfranz/Desktop/steppermotorwithfpgainst/Stepper_Motor_Full_Step/Stepper_Motor_Full_Step.xpr [current_project]
  set_property ip_repo_paths c:/Users/kfranz/Desktop/steppermotorwithfpgainst/Stepper_Motor_Full_Step/Stepper_Motor_Full_Step.cache/ip [current_project]
  set_property ip_output_repo c:/Users/kfranz/Desktop/steppermotorwithfpgainst/Stepper_Motor_Full_Step/Stepper_Motor_Full_Step.cache/ip [current_project]
  add_files -quiet C:/Users/kfranz/Desktop/steppermotorwithfpgainst/Stepper_Motor_Full_Step/Stepper_Motor_Full_Step.runs/synth_1/pmod_step_interface.dcp
  read_xdc C:/Users/kfranz/Desktop/steppermotorwithfpgainst/Stepper_Motor_Full_Step/claw_constraints.xdc
  link_design -top pmod_step_interface -part xc7a35tcpg236-1
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
}

start_step opt_design
set rc [catch {
  create_msg_db opt_design.pb
  catch {write_debug_probes -quiet -force debug_nets}
  opt_design 
  write_checkpoint -force pmod_step_interface_opt.dcp
  report_drc -file pmod_step_interface_drc_opted.rpt
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
}

start_step place_design
set rc [catch {
  create_msg_db place_design.pb
  catch {write_hwdef -file pmod_step_interface.hwdef}
  place_design 
  write_checkpoint -force pmod_step_interface_placed.dcp
  report_io -file pmod_step_interface_io_placed.rpt
  report_utilization -file pmod_step_interface_utilization_placed.rpt -pb pmod_step_interface_utilization_placed.pb
  report_control_sets -verbose -file pmod_step_interface_control_sets_placed.rpt
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
}

start_step route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force pmod_step_interface_routed.dcp
  report_drc -file pmod_step_interface_drc_routed.rpt -pb pmod_step_interface_drc_routed.pb
  report_timing_summary -warn_on_violation -max_paths 10 -file pmod_step_interface_timing_summary_routed.rpt -rpx pmod_step_interface_timing_summary_routed.rpx
  report_power -file pmod_step_interface_power_routed.rpt -pb pmod_step_interface_power_summary_routed.pb
  report_route_status -file pmod_step_interface_route_status.rpt -pb pmod_step_interface_route_status.pb
  report_clock_utilization -file pmod_step_interface_clock_utilization_routed.rpt
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
}

start_step write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  catch { write_mem_info -force pmod_step_interface.mmi }
  write_bitstream -force pmod_step_interface.bit 
  catch { write_sysdef -hwdef pmod_step_interface.hwdef -bitfile pmod_step_interface.bit -meminfo pmod_step_interface.mmi -file pmod_step_interface.sysdef }
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
}

