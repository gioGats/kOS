//main.ks
//General functions.  Every boot script must require this explicity.

// Global variables
set runmode to "".
set messge to "".

FUNCTION NOTIFY {
  PARAMETER message.
  HUDTEXT("kOS: " + message, 5, 2, 50, YELLOW, false).
}

// Detect whether a file exists on the specified volume
FUNCTION HAS_FILE {
  PARAMETER name.
  PARAMETER vol.

  SWITCH TO vol.
  LIST FILES IN allFiles.
  FOR file IN allFiles {
    IF file:NAME = name {
      SWITCH TO 1.
      RETURN TRUE.
    }
  }

  SWITCH TO 1.
  RETURN FALSE.
}

// Get a file from KSC
FUNCTION DOWNLOAD {
  PARAMETER name, overwrite is False.
  if overwrite {
    IF HAS_FILE(name, 1) {
      DELETE name.
    }
    IF HAS_FILE(name, 0) {
      COPY name FROM 0.
    }
  }
  else {
    if NOT (HAS_FILE(name, 1)) {
      IF HAS_FILE(name, 0) {
        COPY name FROM 0.
      }
    }
  }
}

// Put a file on KSC
FUNCTION UPLOAD {
  PARAMETER name, overwrite is False.
  if overwrite {
    IF HAS_FILE(name, 0) {
      SWITCH TO 0. DELETE name. SWITCH TO 1.
    }
    IF HAS_FILE(name, 1) {
      COPY name TO 0.
    }
  }
  else {
    if NOT (HAS_FILE(name, 0)) {
      IF HAS_FILE(name, 1) {
        COPY name TO 0.
      }
    }
  }
}

function Require{
  PARAMETER name, auto_run is False.
  IF NOT HAS_FILE(name, 1) { DOWNLOAD(name). }
  IF auto_run { runoncepath(name). }
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
