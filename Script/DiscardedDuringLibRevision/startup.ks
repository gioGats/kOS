//Startup file with a maneuver autopilot
run lib_maneuver.ks.
run lib_orbit.ks.

NOTIFY("Maneuver autopilot initiated").
wait 2.
NOTIFY("RCS: Execute Maneuver. Brakes: Done").

SET done to FALSE.
ON BRAKES  { SET done to TRUE. }

SET rcsState TO RCS.
UNTIL done {
  IF RCS <> rcsState {
    SET rcsState TO RCS.
    NOTIFY("Executing maneuver").
    MNV_EXEC_NODE(TRUE).
    NOTIFY("Done").
  }
  WAIT 0.1.
}

NOTIFY("Maneuver autopilot terminated").