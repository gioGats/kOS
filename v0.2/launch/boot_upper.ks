//boot_launch.ks
//Boot script for master upper-stage CPU on Recoverable Lifter
set core:volume:name to core:tag.
if not exists(core:volume:name + ":/lib/main.ks") { COPYPATH("0:/lib/main.ks", core:volume:name + ":/lib/main.ks"). }
runoncepath(core:volume:name + ":/lib/main.ks").

require("launch/pre_launch.ks", True).
require("launch/boost.ks", True).
require("launch/upper_stage.ks", True).

Launch(True, 90, "", -1, True, True).
Coast().
