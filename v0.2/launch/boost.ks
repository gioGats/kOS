//boost.ks
@lazyglobal off.

function Launch {
  parameter single_booster is True, launch_heading is 90, launch_target is "", log_out is False, verbose is False.

  if runmode = "pre-launch" {
    //TODO Request launch command from user.
    set target_pitch to 90.
    set target_heading to launch_heading.
    lock steering to (target_pitch, target_heading).
    set target_throttle to 1.
    lock throttle to target_throttle.
    stage.
    set runmode to "liftoff".
  }
  else if runmode = "liftoff" {
    if ship:altiude > 1000 {
      set message to "Begin trajectory guidance".
      set runmode to "boost". }
    else if ship:altiude > 100 {
      set message to "Tower clear".
      set target_heading to 88. }
  }
  else if runmode = "boost" {
    set target_pitch to update_pitch().
    set target_heading to update_heading(launch_heading, launch_target).
    set target_throttle to update_throttle().

    if staging_check(single_booster) {
      set old_throttle to target_throttle.
      set target_throttle to 0.
      wait 0.1.
      stage.
      wait 0.1.
      // TODO Send activate message
      set target_throttle to old_throttle.
      if single_booster { return. }
      else { set single_booster to True. }
    }
  }
  update_display(runmode, message).
  if log_out { update_log(verbose). }
}

function update_heading {
  parameter input_heading is 90, inclination_target is "".
  if inclination != "" {
    // TODO include inc_launch methods
  }
  else { return input_heading. }
}

function update_pitch {
  // TODO Figure something out
  return 90.
}

function update_throttle {
  // TODO Figure something out
  return 1.
}

function staging_check {
  parameter last_booster is True.
  if last_booster {
    // TODO handle single_booster staging
  }
  else {
    // TODO Handle multi_booster Staging
  }
  return False.
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
}
