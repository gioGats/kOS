//record_lift.ks

set core:volume:name to core:tag.
if not exists(core:volume:name + ":/lib/main.ks") { COPYPATH("0:/lib/main.ks", core:volume:name + ":/lib/main.ks"). }
runoncepath(core:volume:name + ":/lib/main.ks").

function Launch {
  parameter single_booster is True, crossfeed is False, launch_heading is 90, launch_target is "", log_out is False, verbose is False.
  set runmode to "pre-launch".
  set message to "Beginning pre-launch checks".
  clearscreen.
  rcs on.
  print "Pre-Launch calculations complete." at (5,4).
  print "Press 'enter' to being the launch countdown." at (5,5).
  // TODO Update other input loops
  terminal:input:clear().
  until False {
    if (terminal:input:haschar) {
      if terminal:input:GetChar() = terminal:input:enter {
        break.
      }
      else { terminal:input:clear(). }
    }
    wait 0.1.
  }
  clearscreen.
  if log_out {
    log "var data = [['Time', 'Tgt_Heading', 'Tgt_Pitch', 'Tgt_Throttle', 'Altitude', 'Apoapsis', 'Periapsis', 'Vertical_Speed', 'Horizontal_Speed', 'Orbital Speed', 'Delta-V']," to "0:/ascent_telemetry.js".
    set start_time to time:seconds.
  }

  until False {
    if runmode = "pre-launch" {
      set target_pitch to 90.
      set target_heading to launch_heading.
      lock steering to heading(target_heading, target_pitch).
      set target_throttle to 1.
      lock throttle to target_throttle.
      if launch_target <> "" { set Target to Orbitable(launch_target). }
      stage.
      set runmode to "liftoff".
      set message to "Liftoff".
    }
    else if runmode = "liftoff" {
      if ship:airspeed > 50 {
        set message to "Begin trajectory guidance".
        set runmode to "initiate gravity turn".
      }
      else if ship:altitude > 100 {
        set message to "Tower clear".
        set target_throttle to update_throttle(1.5).
        set target_pitch to 88.
      }
    }
    else if runmode = "initiate gravity turn" {
      set target_pitch to 85.
      if (ship:altitude > 2000) or (ship:airspeed > 200) {
        set runmode to "gravity turn".
      }
    }
    else if runmode = "gravity turn" {
      set target_pitch to 90 - VANG(SHIP:UP:FOREVECTOR, SHIP:SRFPROGRADE:FOREVECTOR).
      if (ship:altitude > 30000) {
        set runmode to "boost".
      }
    }
    else if runmode = "boost" {
      set target_pitch to 90 - VANG(SHIP:UP:FOREVECTOR, SHIP:PROGRADE:FOREVECTOR).
      if ship:orbit:apoapsis >= 100000 {
        break.
      }
    }
    set target_heading to update_heading(launch_heading, launch_target).
    set target_throttle to update_throttle(1.5).
    update_display(runmode, message).
    if log_out { update_log(verbose). }
    wait 0.1.
  }
  local dv is ORBITAL_VELOCITY(Ship:Apoapsis,Ship:Apoapsis,Ship:Apoapsis) - ORBITAL_VELOCITY(Ship:Apoapsis,Ship:Periapsis,Ship:Apoapsis).
  set nd to node(time:seconds+eta:apoapsis,0,0,dv).
  add nd.
  if log_out {
    log "];" to "0:/ascent_telemetry.js".
  }
}

function update_heading {
  parameter input_heading is 90, inclination_target is "".
  if inclination_target <> "" {
    // FUTURE include inc_launch methods
  }
  else { return input_heading. }
}

function update_throttle {
  parameter target_twr is -1.
  if (runmode = "gravity turn") or (runmode = "boost") {
    local twr is max(((eta:apoapsis/-30) + 3), 0.5).
    return twr_throttle(twr).
  }
  else if (ship:Apoapsis > 95000) {
    if ALT:RADAR < 60000 {
      set TVAL to max(0.05, 8*(1-(SHIP:orbit:APOAPSIS/100000))).
    }
    else {
      set TVAL to max(0.2, 8*(1-(SHIP:orbit:APOAPSIS/100000))).
    }
  }
  else {
    return twr_throttle(target_twr).
  }
}

function twr_throttle {
  parameter target_twr is -1.
  if target_twr > 0 {
    return max(min(target_twr / Available_twr(), 1), 0).
  }
  else {
    return 1.
  }
}

function update_display {
  parameter runmode, message is "".
  clearscreen.
  print "Runmode: " + runmode at (5,4).
  print "Tgt_Heading: " + round(target_heading, 2) at (5,5).
  print "Tgt_Pitch: " + round(target_pitch, 2) at (5,6).
  print "Tgt_Throttle: " + round(target_throttle, 3) at (5,7).
  print "Apoapsis: " + round(ship:orbit:apoapsis) at (5,8).
  print "Periapsis: " + round(ship:orbit:Periapsis) at (5,9).
  print "Available_twr: " + round(Available_twr(), 2) at (5,10).
  print "Message: " + message at (5,11).
}

function single_stage_dv {
  LIST ENGINES IN shipEngines.
  RETURN shipEngines[0]:ISP * 9.81 * LN(SHIP:MASS / SHIP:DRYMASS).
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
  // Apoapsis
  set output to output + (ship:orbit:Apoapsis) + ",".
  // Periapsis
  set output to output + (ship:orbit:Periapsis) + ",".
  // Vertical speed
  set output to output + (ship:verticalspeed) + ",".
  // Horizontal speed
  set output to output + (ship:groundspeed) + ",".
  // Orbital Speed
  set output to output + (ship:velocity:orbit:mag) + ",".
  // Delta-V
  set output to output + single_stage_dv() + "],".
  log output to "0:/ascent_telemetry.js".
}

Launch(True, False, 90, "", True, True).
