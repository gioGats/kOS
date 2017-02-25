//booster_recover.ks
//Function to aid in booster recovery.

function booster_recover {
  until False {
    if booster_runmode = "prelaunch" or booster_runmode = "boost" or booster_runmode = "landed" {
      return.
    }
    else {
      lock ship_heading to mod(360 - latlng(90,0):bearing, 360).
      local initial_heading is ship_heading.
      local initial_groundspeed is ship:groundspeed.
      local target_throttle is 0.
      lock throttle to target_throttle.
    }

    if booster_runmode = "boostback" {
      engine_updates().
      local reverse_heading is mod(initial_heading + 180, 360).
      local target_groundspeed is 0.85*ship:groundspeed.
      lock steering to heading(reverse_heading, 0).
      set target_throttle to 1.

      when ((reverse_heading - ship_heading) < (initial_heading - ship_heading)) and (ship:groundspeed > target_groundspeed) THEN {
        set target_throttle to 0.
      }
      when (target_throttle = 0) and (ship:VERTICALSPEED < 0) THEN {
        lock steering to ship:SRFRETROGRADE.
        set booster_runmode to "correction".
      }
    }
    else if booster_runmode = "correction" {
      if hoverslam_requirement < engine_updates(True, 1) {
        // TODO Correction burns
        // Generate a correction vector from trajectories
        // Generate a deviation magnitude (no more than 30 degrees)
        // based on magnitude of correction vector.
        // Orient magnitude degrees towards the correction vector.
        // Burn.
      }
      else {
        set booster_runmode to "hoverslam".
      }
    }
    else if booster_runmode = "hoverslam" {
      // TODO HoverSlam
      // TODO If chutes, use them
    }
    else {
      print "Runmode error: " + booster_runmode:tostring.
    }
    update_display().
  }

}

function hoverslam_requirement {
  return 1.5 * ship:termvelocity.
}

function engine_updates {
  parameter dv is false, pressure is -1.
  List engines in ens.
  // Shutdown non-recovery engines.
  for en in ens { if en:tag <> "recovery" { en:shutdown. } }
  if dv { return Available_dv(pressure). }
}

function update_display {
  // TODO Copy and revise from boost.ks
}
