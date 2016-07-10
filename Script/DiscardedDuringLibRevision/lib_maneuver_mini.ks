print "Running Lib_Maneuver.ks".

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
FUNCTION MNV_TIME {
  PARAMETER dV.

  LIST ENGINES IN en.
  FOR eng IN en {
    IF ENG:IGNITION  {
        set activeEngine to eng.
        }
    }
    //I'd like to come back through and modify this to run calculations for multiple engines
  LOCAL f IS activeEngine:MAXTHRUST * 1000.  // Engine Thrust (kg * m/s²)
  LOCAL m IS SHIP:MASS * 1000.        // Starting mass (kg)
  LOCAL e IS CONSTANT():E.            // Base of natural log
  LOCAL p IS activeEngine:ISP.        // Engine ISP (s)
  LOCAL g IS 9.82.                    // Gravitational acceleration constant (m/s²)

  RETURN g * m * p * (1 - e^(-dV/(g*p))) / f.
}

// Returns LIST(v1, v2) of two burns required to Hohmann transfer to a new orbit
// Parameter: desired altitude
FUNCTION MNV_HOHMANN_DV {
  PARAMETER desiredAltitude.

  SET u  TO SHIP:OBT:BODY:MU.
  SET r1 TO SHIP:OBT:SEMIMAJORAXIS.
  SET r2 TO desiredAltitude + SHIP:OBT:BODY:RADIUS.

  SET v1 TO SQRT(u / r1) * (SQRT((2 * r2) / (r1 + r2)) - 1).

  SET v2 TO SQRT(u / r2) * (1 - SQRT((2 * r1) / (r1 + r2))).

  RETURN LIST(v1, v2).
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
    CALC(Ship:Apoapsis,Ship:Periapsis,Ship:Apoapsis).
    set v0 to v.
    CALC(Ship:Apoapsis,Pe,Ship:Apoapsis).
    set v1 to v.
    set dv to v1 - v0.
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
