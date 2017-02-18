//main.ks
//General functions.  Every boot script must require this explicity.

// Global variables
set runmode to "".
set message to "".

FUNCTION NOTIFY {
  PARAMETER message, echo is False.
  HUDTEXT("kOS: " + message, 5, 2, 50, YELLOW, echo).
}

// Get a file from KSC
FUNCTION DOWNLOAD {
  PARAMETER filename, overwrite is False.
  if exists(volume:name + ":" + filename) {
    if not overwrite { return. }
    else { deletepath(volume:name + ":" + filename). }
  }
  copypath("0:" + filename, volume:name + ":" + filename).
}

// Put a file on KSC
FUNCTION UPLOAD {
  PARAMETER filename, overwrite is False.
  if exists("0:" + filename) {
    if not overwrite { return. }
    else { deletepath("0:" + filename). }
  }
  copypath(volume:name + ":" + filename, "0:" + filename).
}

function Require{
  PARAMETER filename, auto_run is False.
  if not exists(volume:name + ":" + filename) { copypath("0:" + filename, volume:name + filename). }
  if auto_run { runoncepath(filename). }
}

FUNCTION ORBITABLE {
  PARAMETER name.

  LIST TARGETS in vessels.
  FOR vs IN vessels {
    IF vs:NAME = name {
      RETURN VESSEL(name).
    }
  }

  RETURN BODY(name).
}

function Available_twr {
  local total_thrust is 0.
  for en in (list engines) {
    if en:ignition = true and en:flameout = False {
      set total_thrust to total_thrust + en:availablethrust.
    }
  }
  return total_thrust/ship:mass.
}

// Execute the next node
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
}

FUNCTION ORBITAL_VELOCITY {
    DECLARE PARAMETER Ap, Pe, Radius.
    LOCAL mew IS constant:G * Kerbin:Mass.
    LOCAL r IS Radius + Kerbin:radius.
    LOCAL a IS (ap+pe+2*kerbin:radius)/2.

    if Pe > 0.99 * Ap { RETURN sqrt((constant:G * Kerbin:Mass)/(Radius + Kerbin:radius)). }
    else { RETURN sqrt((constant:G * Kerbin:Mass)*((2/(Radius + Kerbin:radius))-(1/((ap+pe+2*kerbin:radius)/2)))). }
}

FUNCTION AUTOPILOT {
  // TODO Update for terminal I/O capabilities
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


Notify("Main function load successful.").
