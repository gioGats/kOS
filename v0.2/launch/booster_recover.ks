//booster_recover.ks
//Function to aid in booster recovery.

function booster_recover {
  parameter log_out is False, verbose is False.

  if log_out {
    log "var data = [['Time', 'Tgt_Heading', 'Tgt_Pitch', 'Tgt_Throttle', 'Altitude', 'Vertical_Speed', 'Horizontal_Speed']," to return_telemetry.js.
    set start_time to time:seconds.
  }

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
        // FUTURE Correction burns
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
      hoverslam().
      // FUTURE If chutes, use them
    }
    else {
      print "Runmode error: " + booster_runmode:tostring.
    }
    update_display(booster_runmode).
    if log_out { update_log(verbose). }
  }
  if log_out {
    log "];" to ascent_telemetry.js.
    upload("return_telemetry.js", True).
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
  parameter runmode, message is "".
  clearscreen.
  print "Runmode: " + runmode at (5,4).
  print "Tgt_Heading: " + round(target_heading, 2) at (5,5).
  print "Tgt_Pitch: " + round(target_pitch, 2) at (5,6).
  print "Tgt_Throttle: " + round(target_throttle, 2) at (5,7).
  print "Message: " + message at (5,8).
}

function update_log {
  parameter verbose is False.
  local output is "[".

  // Time
  set output to output + (time:seconds - start_time) + ",".
  // Target heading
  set output to output + (target_heading) + ",".
  // Target pitch
  set output to output + (target_pitch) + ",".
  // Target throttle
  set output to output + (target_throttle) + ",".
  // Altitude
  set output to output + (ship:Altitude) + ",".
  // Vertical speed
  set output to output + (ship:verticalspeed) + ",".
  // Horizontal speed
  set output to output + (ship:groundspeed) + ",".

  set output to output + "],".
  log output to ascent_telemetry.js.
}

function hoverslam {
  // FUTURE Set radarOffset dynamically
  // TODO Set initial Hard-Coded radarOffset
  set radarOffset to 9.184.	 				// The value of alt:radar when landed (on gear)
  lock trueRadar to alt:radar - radarOffset.			// Offset radar to get distance from gear to ground
  lock g to constant:g * body:mass / body:radius^2.		// Gravity (m/s^2)
  lock maxDecel to (ship:availablethrust / ship:mass) - g.	// Maximum deceleration possible (m/s^2)
  lock stopDist to ship:verticalspeed^2 / (2 * maxDecel).		// The distance the burn will require
  lock idealThrottle to stopDist / trueRadar.			// Throttle required for perfect hoverslam
  lock impactTime to trueRadar / abs(ship:verticalspeed).		// Time until impact, used for landing gear

  WAIT UNTIL ship:verticalspeed < -1.
  	NOTIFY("Preparing for hoverslam...").
  	rcs on.
  	brakes on.
  	lock steering to srfretrograde.
  	when impactTime < 3 then {gear on.}

  WAIT UNTIL trueRadar < stopDist.
  	NOTIFY("Performing hoverslam").
  	lock throttle to idealThrottle.

  WAIT UNTIL ship:verticalspeed > -0.01.
  	NOTIFY("Hoverslam completed").
  	set ship:control:pilotmainthrottle to 0.
  	rcs off.
}
