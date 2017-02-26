//boot_booster.ks
//Boot script for slave booster CPU on Recoverable Lifter

if not exists(volume():name + ":/lib/main.ks") { COPYPATH("0:/lib/main.ks", volume():name + ":/lib/main.ks"). }
runoncepath(volume():name + ":/lib/main.ks").

Require("booster_recover.ks", True).

if ship:status = "PRELAUNCH" {
  set launchpad_position to ship:GEOPOSITION.
  set landing_height to ship:altiude - alt:radar.
  set booster_runmode to "prelaunch".
  when ship:status = "FLYING" THEN set booster_runmode to "boost".
}

else {
  set booster_runmode to "unknown".
  if ship:status = "PRELAUNCH" { set booster_runmode to "prelaunch". }
  else if ship:status = "LANDED" { set booster_runmode to "prelaunch". }
  // FUTURE determine if boostback or correction or hoverslam
  // Only needed in the event of an in-flight restart
}

when (not core:messages:empty) THEN {
  if core:messages:pop():content:tostring = "boostback" {
    set booster_runmode to "boostback".
    booster_recover().
  }
  preserve.
}

when ship:status = "LANDED" {
  set booster_runmode to "landed".
  shutdown.
  // Future Shutdown proceedure
}
