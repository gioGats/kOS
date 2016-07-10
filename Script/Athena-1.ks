// Athena-1.ks
// The Athena program intends to land kerbalkind on Minmus!
// Athena 1 tests launch scripts to a target's inclination.

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

FUNCTION MISSION {
    INC_LAUNCH("Minmus", 75000, TRUE).

    RAISE_PE(Ship:Apoapsis).
    MNV_EXEC_NODE(TRUE).
}

if ship:altitude < 70000 {
  dependencies().
  MISSION().
}
