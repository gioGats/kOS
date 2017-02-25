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
    
FUNCTION CALC {
    DECLARE PARAMETER Ap.
    DECLARE PARAMETER Pe.
    DECLARE PARAMETER Alt.
    set mew to constant:G * Kerbin:Mass.
    set r to alt + Kerbin:radius.
    set orbit to ship:orbit.
    set a to (ap+pe+2*kerbin:radius)/2.

    if Pe > 0.99 * Ap {set v to sqrt(mew/r).}
    else {set v to sqrt(mew*((2/r)-(1/a))).}
    }

FUNCTION INC_NODE {
    PARAMETER TGT.
    set Target to Orbitable(TGT).
    set inc to Target:Orbit:Inclination - Ship:Orbit:Inclination.
    
    set node_time to TIME_ASC_NODE(TGT).
    
    set b to sqrt((constant:G * Kerbin:Mass)/(Ship:Orbit:SemiMajorAxis))*2*sin(inc/2).
    set Bp to -1*b*sin(inc/2).
    if (quadrant = 1) or (quadrant = 2) {set Bn to b*cos(inc/2).}
    else if (quadrant = 3) or (quadrant = 4) {set Bn to -1*b*cos(inc/2).}

    add NODE(node_time, 0, Bn, Bp).
}

FUNCTION TIME_ASC_NODE {
    PARAMETER TGT.
    set vec_n to VCRS(Target:Prograde:Vector, Target:Up:Vector).

    set t_0 to time:seconds.
    set theta_0 to VANG(SHIP:UP:VECTOR,vec_n)-90.
    wait 1.
    set t to time:seconds.
    set theta to VANG(SHIP:UP:VECTOR,vec_n)-90.
    set d_theta to (theta-theta_0)/(t-t_0).
    
    if theta > 0 {
        if d_theta > 0 {set quadrant to 3.}
        else {set quadrant to 4.}
        }
    else {
        if d_theta > 0 {set quadrant to 2.}
        else {set quadrant to 1.}   
        }
    
    if status = "ORBITING" {
        set period to SHIP:ORBIT:PERIOD.
        set t to (period/360)*arccos(abs(theta)/inc).
        }
    else {set period to SHIP:BODY:ROTATIONPERIOD.
        set t to (period/360)*arccos(abs(theta-inc)/lat). //REFTODO: latitude
        }
    
    set t to (period/360)*arccos(abs(theta)/inc).
    if (quadrant = 2) or (quadrant = 4) {set node_time to time:seconds + ((period/4)-t).}
    else if (quadrant = 1) or (quadrant = 3) {set node_time to time:seconds + ((period/4)+t).}
    return node_time.
}