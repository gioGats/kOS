// Athena-1.5.ks
// The Athena program intends to land kerbalkind on Minmus!
// Athena 1.5 tests establishing a transfer orbit using an already orbiting craft.

copy lib_orbit from 0.
run once lib_orbit.
copy lib_maneuver from 0.
run once lib_maneuver.
copy lib_insertion from 0.
run once lib_insertion.

FUNCTION test {
  set target to Mun.
  TRANSFER_NODE("Mun").

  MNV_EXEC_NODE(FALSE).
  wait 1.
  if not ship:orbit:HASNEXTPATCH {
    AUTOPILOT().
  }

  MUNAR_INSERTION().
}

FUNCTION delta_angle {
  PARAMETER tgt.
  local current_angle is TARGET_ANGLE(tgt).
  wait 1.
  return (TARGET_ANGLE(tgt) - current_angle)/1.
}

FUNCTION collection {
  switch to 0.
  set target to Mun.
  set tgt to "Mun".
  local Pe is (Ship:Apoapsis + Ship:Periapsis)/2.
  local Ap is (Target:Apoapsis + Target:Periapsis)/2.
  set start to TARGET_ANGLE(tgt).
  wait 1.

  until abs(TARGET_ANGLE(tgt) - start) > 10 {
    set warp to 3.
    LOG (TIME:SECONDS) + "," + TRANSFER_ANGLE(tgt, Pe, Ap) + "," + TARGET_ANGLE(tgt) + "," + delta_angle(tgt) TO "testflight.csv".
    wait 1.
  }

  until abs(TARGET_ANGLE(tgt) - start) < 5 {
    set warp to 3.
    LOG (TIME:SECONDS) + "," + TRANSFER_ANGLE(tgt, Pe, Ap) + "," + TARGET_ANGLE(tgt) + "," + delta_angle(tgt) TO "testflight.csv".
    wait 1.
  }
  set warp to 0.
  switch to 1.
}

collection().
