//boost.ks

function Launch {
  parameter single_booster is True, launch_heading is 90, launch_target is "", max_twr is -1, log_out is False, verbose is False.
  set runmode to "pre-launch".
  set message to "Beginning pre-launch checks".
  if log_out {
    log "var data = [['Time', 'Tgt_Heading', 'Tgt_Pitch', 'Tgt_Throttle', 'Altitude', 'Apoapsis', 'Periapsis', 'Vertical_Speed', 'Horizontal_Speed', 'Orbital Speed']," to ascent_telemetry.js.
    set start_time to time:seconds.
  }

  until False {
    if runmode = "pre-launch" {
      //TODO Request launch command from user.
      set target_pitch to 90.
      set target_heading to launch_heading.
      lock steering to (target_pitch, target_heading).
      set target_throttle to 1.
      lock throttle to target_throttle.
      if launch_target <> "" { set Target to Orbitable(launch_target). }
      stage.
      set runmode to "liftoff".
    }
    else if runmode = "liftoff" {
      if ship:altiude > 1000 {
        set message to "Begin trajectory guidance".
        set runmode to "boost".
      }
      else if ship:altiude > 100 {
        set message to "Tower clear".
        set target_heading to 88.
      }
    }
    else if runmode = "boost" {
      set target_pitch to update_pitch().
      set target_heading to update_heading(launch_heading, launch_target).
      set target_throttle to update_throttle().

      if staging_check(single_booster) {
        local old_throttle is target_throttle.
        set target_throttle to 0.
        wait 0.1.
        stage.
        wait 0.1.
        // TODO Send activate message to booster CPU(s)
        set target_throttle to old_throttle.
        if single_booster { return. }
        else { set single_booster to True. }
      }
    }
    update_display(runmode, message).
    if log_out { update_log(verbose). }
    }
  if log_out {
    log "];" to ascent.js.
    copy ascent.js to 0.
  }
}

function update_heading {
  parameter input_heading is 90, inclination_target is "".
  if inclination_target <> "" {
    // FUTURE include inc_launch methods
  }
  else { return input_heading. }
}

function update_pitch {
  // FUTURE modify based on booster configuration
  // i.e. steepen trajectory if running low on fuel
  // flatten trajectory if extra
  // But really, just get to the the minimum orbit required
  return -115.23935 * (alt:radar / 100000)^0.4095114 + 88.963.
}

function update_throttle {
  parameter target_twr is -1.
  if (SHIP:APOAPSIS > 0.875*Ap) and (SHIP:APOAPSIS < 0.999*Ap) {
      if ALT:RADAR < 60000 { set TVAL to max(0.05, 8*(1-SHIP:APOAPSIS/Ap)). }
      else { set TVAL to max(0.2, 8*(1-SHIP:APOAPSIS/Ap)). }
      }
  else if target_twr > 0 {
    return max(min(target_twr / Available_twr(), 1), 0).
    // FUTURE Do something smarter
    // Maybe vector dot product code from v0.1?
  }
  else { return 1. }
}

function staging_check {
  parameter last_booster is True.
  parameter error_margin is 0.25.
  if ship:apoapsis >= 100000 { return True. }
  if last_booster {
    // TODO Calculate booster empty_mass
    // TODO Cacluate booster current_mass
    // TODO Calculate horizontal velocity
    // return ((booster_remaining_dv is landing_isp * 9.807 * ln(current_mass/empty_mass)) < ((1 + error_margin)*(required_landing_dv + horizontal_spd))).
    return False.
  }
  else {
    set message to "ERROR: TRIPLE BOOSTER STAGING NOT AVAILABLE".
    return False.
    // FUTURE Handle multi_booster Staging
  }
}

function update_display {
  parameter runmode, message is "".
  // TODO Print a bunch of info
  print(runmode).
  print(message).
  // TODO Format this
}

function update_log {
  parameter verbose is False.
  // TODO output to the log
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
  set output to output + (ship:velocity:orbit:mag).

  set output to output + "],".
  log output to ascent.js.
}
