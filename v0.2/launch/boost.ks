//boost.ks

function Launch {
  parameter single_booster is True, launch_heading is 90, launch_target is "", max_twr is -1, log_out is False, verbose is False.
  set runmode to "pre-launch".
  set message to "Beginning pre-launch checks".

  print "Pre-Launch calculations complete." at (5,4).
  print "Press 'enter' to being the launch countdown." at (5,5).
  until False {
    terminalinput:clear().
    if (terminal:input:haschar) {
      if terminal:input:GetChar() = terminal:input:enter {
        break.
      }
    }
    wait 0.1.
  }
  if log_out {
    log "var data = [['Time', 'Tgt_Heading', 'Tgt_Pitch', 'Tgt_Throttle', 'Altitude', 'Apoapsis', 'Periapsis', 'Vertical_Speed', 'Horizontal_Speed', 'Orbital Speed']," to ascent_telemetry.js.
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
      set target_throttle to update_throttle(max_twr).

      if staging_check(single_booster) {
        local old_throttle is target_throttle.
        for p in (list processors) {
          if p:connection:isconnected {
            p:connection:sendMessage("boostback").
          }
        }
        set target_throttle to 0.
        wait 1.
        stage.
        wait 1.
        set target_throttle to old_throttle.
        if single_booster { return. }
        else { set single_booster to True. }
      }
    }
    update_display(runmode, message).
    if log_out { update_log(verbose). }
  }
  if log_out {
    log "];" to ascent_telemetry.js.
    upload("ascent_telemetry.js", True).
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
  if (SHIP:orbit:APOAPSIS > 0.875*Ap) and (SHIP:orbit:APOAPSIS < 0.999*Ap) {
      if ALT:RADAR < 60000 { set TVAL to max(0.05, 8*(1-SHIP:orbit:APOAPSIS/Ap)). }
      else { set TVAL to max(0.2, 8*(1-SHIP:orbit:APOAPSIS/Ap)). }
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
  if ship:orbit:apoapsis >= 100000 { return True. }
  else {
    if last_booster { return booster_check("C"). }
    else { return booster_check("L") or booster_check("R"). }
  }
}

function booster_check {
  parameter booster, error_margin is 0.25.
  local remaining is (landing_isp * 9.807 * ln(booster_mass(booster))).
  local required is ((1 + error_margin) * (required_landing_dv + 1.75 * ship:groundspeed)).
  if booster = "C" { local row is 15. }
  else if booster = "L" { local row is 16.}
  else if booster = "R" { local row is 17. }
  else { local row is 18. }
  print booster at (5, row).
  print "|" at (13,row).
  print round(remaining) at (15, row).
  print "|" at (28,row).
  print round(required) at (30, row).
  return remaining < required.
}

function booster_mass {
  parameter booster.
  local dry_mass is 0.
  local current_mass is 0.
  for part in list parts {
    if (part:tag = booster) and not (part:hasfield("bootfilename")) {
      local booster_root is part.
      break.
    }
  }
  for booster_part in booster_root:children {
    set dry_mass to dry_mass + booster_part:drymass.
    set current_mass to current_mass + booster_part:mass.
  }
  return current_mass/dry_mass.
}

function update_display {
  parameter runmode, message is "".
  clearscreen.
  print "Runmode: " + runmode at (5,4).
  print "Tgt_Heading: " + round(target_heading, 2) at (5,5).
  print "Tgt_Pitch: " + round(target_pitch, 2) at (5,6).
  print "Tgt_Throttle: " + round(target_throttle, 2) at (5,7).
  print "Message: " + message at (5,8).

  print "Last Booster: " + single_booster at (5,10).
  print "Apoapsis: " + round(ship:orbit:apoapsis) + "/100000" + at (5,11).
  print "Periapsis: " + round(ship:orbit:Periapsis) + "/" + min_boost_pe at (5,12).
  print "BOOSTER | REMAINING DV | REQUIRED DV" at (5,14).
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
  set output to output + (ship:velocity:orbit:mag).

  set output to output + "],".
  log output to ascent_telemetry.js.
}
