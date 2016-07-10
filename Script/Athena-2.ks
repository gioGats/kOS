// Athena-2.ks
// The Athena program intends to land kerbalkind on Minmus!
// Athena 2 tests launching to the target plane, burning to a transfer orbit,
// and adjusting the orbit for landing.

FUNCTION dependencies {
  parameter autorun is true.

  for dependency in list(
    // List dependencies
    "launch_inc.ks",
    "lib_pid.ks",
    "lib_maneuver.ks"
  ) if not exists(dependency) copy dependency from 0.
  if autorun {
    run once launch_inc.
    run once lib_pid.
    run once lib_maneuver.
  }

}

FUNCTION LAUNCH_PHASE {
  dependencies().
  INC_LAUNCH("Minmus", 80000, TRUE).
  RAISE_PE(Ship:Apoapsis).
  MNV_EXEC_NODE(TRUE).
}

FUNCTION TRANSFER_PHASE {
  if ship:partstagged("STAGE1D"):length > 0 {
    set stgM to ship:partstagged("STAGE1D")[0]:getModule("ModuleDecouple").
    stgM:DOEVENT("decouple").
  }
  if ship:partstagged("STAGE2E"):length > 0 {
    set stgM to ship:partstagged("STAGE2E")[0]:getModule("ModuleEngines").
    stgM:DOEVENT("activate engine").
  }

  delete launch_inc.
  copy lib_orbit from 0.
  copy lib_insertion from 0.
  //copy lib_comms from 0.
  //run once lib_comms.
  //TODO Fix lib comms.
  run once lib_orbit.
  run once lib_insertion.

  TRANSFER_NODE("Minmus").
  MNV_EXEC_NODE(TRUE).
  wait 1.
  until ship:orbit:HASNEXTPATCH {
    AUTOPILOT().
  }
}

FUNCTION INSERTION_PHASE {
  MUNAR_INSERTION().
}

if status = "PRELAUNCH" {

  LAUNCH_PHASE().

  wait 1.

  TRANSFER_PHASE().

  wait 1.

  INSERTION_PHASE().

}
