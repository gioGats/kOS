//boot_launch.ks
//Boot script for master CPU on Recoverable Lifter

require('pre_launch.ks').
require('boost.ks').
require('upper_stage.ks').

run once pre_launch.ks.
run once boost.ks.
run upper_stage.ks.
