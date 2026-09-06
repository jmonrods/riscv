set_app_var enable_lint true
read_file -format sverilog -top cpu ../../rtl/cpu_single/cpu.sv
check_lint
report_lint -verbose
