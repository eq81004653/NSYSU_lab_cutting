onerror {exit -code 1}
vlib work
vlog -work work cutting_top.vo
vlog -work work Waveform3.vwf.vt
vsim -c -t 1ps -L maxv_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate_ver -L altera_lnsim_ver work.cutting_top_vlg_vec_tst
vcd file -direction cutting_top.msim.vcd
vcd add -internal cutting_top_vlg_vec_tst/*
vcd add -internal cutting_top_vlg_vec_tst/i1/*
proc simTimestamp {} {
    echo "Simulation time: $::now ps"
    if { [string equal running [runStatus]] } {
        after 2500 simTimestamp
    }
}
after 2500 simTimestamp
run -all
quit -f


