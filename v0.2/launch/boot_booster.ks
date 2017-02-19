//boot_booster.ks
//Boot script for slave booster CPU on Recoverable Lifter
//set volume():name to "upper_stage".
//TODO Verify that volume name is automatically set to processor tag
set this_cpu
if not exists(volume():name + ":/lib/main.ks") { COPYPATH("0:/lib/main.ks", volume():name + ":/lib/main.ks"). }
runoncepath(volume():name + ":/lib/main.ks").

Require("booster_recover.ks", True).

if ship:status = "PRELAUNCH" {
  set launchpad_position to ship:GEOPOSITION.
  set landing_height to ship:altiude - alt:radar.
  set booster_runmode to "prelaunch".
  when ship:status = "FLYING" THEN set booster_runmode to "boost".
}
// If there's a message in the queue, change your runmode to the message content.

when activate_message() THEN {
  booster_recover(booster_runmode).
  preserve.
}

function activate_message {
  // TODO check message queue
  // If message, set runmode to it's content and return true.
  // Else, return false.
}
