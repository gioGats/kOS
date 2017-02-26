//boot_launch.ks
//Boot script for master CPU on Recoverable Lifter

if not exists("upper_stage:/lib/main.ks") { COPYPATH("0:/lib/main.ks", "upper_stage:/lib/main.ks"). }
runoncepath("upper_stage:/lib/main.ks").

require("launch/pre_launch.ks", True).
require("launch/boost.ks", True).
require("launch/upper_stage.ks", True).

Launch(True, 90, "", -1, True, True).
Coast().
