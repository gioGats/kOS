//boot_launch.ks
//Boot script for master CPU on Recoverable Lifter
set volume():name to "upper_stage".
if not exists("upper_stage:/lib/main.ks") { COPYPATH("0:/lib/main.ks", "upper_stage:/lib/main.ks"). }
runoncepath("upper_stage:/lib/main.ks").


require('pre_launch.ks').
require('boost.ks').
require('upper_stage.ks').

run once pre_launch.ks.
run once boost.ks.
run upper_stage.ks.
