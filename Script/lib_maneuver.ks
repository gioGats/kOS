NOTIFY("Loading lib_maneuver").

// Returns true if engines have burned out
// Parameter: autoStage (True/False)
SET burnoutCheck TO "reset".
FUNCTION MNV_BURNOUT {
  PARAMETER autoStage.

  IF burnoutCheck = "reset" {
    SET burnoutCheck TO MAXTHRUST.
    RETURN FALSE.
  }

  IF burnoutCheck - MAXTHRUST > 10 {
    IF autoStage {
      STAGE.
    }
    SET burnoutCheck TO "reset".
    RETURN TRUE.
  }

  RETURN FALSE.
}

// Returns estimated time to complete a burn of a certain dV
// Parameter: dV in m/s
function mnv_time {
  parameter dv.
  set ens to list().
  ens:clear.
  set ens_thrust to 0.
  set ens_isp to 0.
  list engines in myengines.

  for en in myengines {
    if en:ignition = true and en:flameout = false {
      ens:add(en).
    }
  }

  for en in ens {
    set ens_thrust to ens_thrust + en:availablethrust.
    set ens_isp to ens_isp + en:isp.
  }

  if ens_thrust = 0 or ens_isp = 0 {
    notify("No engines available!").
    return 0.
  }
  else {
    local f is ens_thrust * 1000.  // engine thrust (kg * m/s²)
    local m is ship:mass * 1000.        // starting mass (kg)
    local e is constant():e.            // base of natural log
    local p is ens_isp/ens:length.               // engine isp (s) support to average different isp values
    local g is ship:orbit:body:mu/ship:obt:body:radius^2.    // gravitational acceleration constant (m/s²)
    return g * m * p * (1 - e^(-dv/(g*p))) / f.
  }
}

// Executes the next maneuver node.
// Parameter: autoWarp (True/False)
FUNCTION MNV_EXEC_NODE {
  PARAMETER autoWarp.

  LOCAL n IS NEXTNODE.
  LOCAL v IS n:BURNVECTOR.

  LOCAL startTime IS TIME:SECONDS + n:ETA - MNV_TIME(v:MAG)/2.
  LOCK STEERING TO n:BURNVECTOR.

  IF autoWarp { WARPTO(startTime - 30). }

  WAIT UNTIL TIME:SECONDS >= startTime.
  LOCK THROTTLE TO MIN(MNV_TIME(n:BURNVECTOR:MAG), 1).
  WAIT UNTIL VDOT(n:BURNVECTOR, v) < 0.
  LOCK THROTTLE TO 0.
  UNLOCK STEERING.
  remove n.
}

// ADDITIONS

// Adds node at next apoapsis to raise periapsis
// Parameter: desired periapsis
FUNCTION RAISE_PE {
    PARAMETER Pe.
    local v0 is CALC(Ship:Apoapsis,Ship:Periapsis,Ship:Apoapsis).
    local v1 is CALC(Ship:Apoapsis,Pe,Ship:Apoapsis).
    local dv is v1 - v0.
    set nd to node(time:seconds+eta:apoapsis,0,0,dv).
    add nd.
    }

// Returns prograde velocity for a given orbital condition.
// Parameters: Apoapsis, Periapsis, Altitude (all meters)
FUNCTION CALC {
    DECLARE PARAMETER Ap.
    DECLARE PARAMETER Pe.
    DECLARE PARAMETER Alt.
    LOCAL mew IS constant:G * Kerbin:Mass.
    LOCAL r IS alt + Kerbin:radius.
    LOCAL a IS (ap+pe+2*kerbin:radius)/2.

    if Pe > 0.99 * Ap {
        RETURN sqrt(mew/r).
    }
    else {
      RETURN sqrt(mew*((2/r)-(1/a))).
    }
}

FUNCTION AUTOPILOT {
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
}
