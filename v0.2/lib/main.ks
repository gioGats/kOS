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
  if exists(core:volume:name + ":" + filename) {
    if not overwrite { return. }
    else { deletepath(core:volume:name + ":" + filename). }
  }
  copypath("0:" + filename, core:volume:name + ":" + filename).
}

// Put a file on KSC
FUNCTION UPLOAD {
  PARAMETER filename, overwrite is False.
  if exists("0:" + filename) {
    if not overwrite { return. }
    else { deletepath("0:" + filename). }
  }
  copypath(core:volume:name + ":" + filename, "0:" + filename).
}

function Require {
  PARAMETER filename, auto_run is False.
  if exists(core:volume:name + ":" + filename) {
    if auto_run { runoncepath(filename). }
    return True.
  }
  else if exists("0:" + filename) {
    copypath("0:" + filename, core:volume:name + ":" + filename).
    if auto_run { runoncepath(filename). }
    return True.
  }
  else {
    return False.
  }
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
  parameter pressure is -1.
  local total_thrust is 0.
  list engines in ens.
  for en in ens {
    if en:ignition = true and en:flameout = False {
      if pressure = -1 { set total_thrust to total_thrust + en:availablethrust. }
      else { set total_thrust to total_thrust + en:availablethrustat(pressure). }
    }
  }
  return ((total_thrust/ship:mass)/10).
}

function Available_dv {
  parameter pressure is -1.
  local dry_mass is 0.
  local current_mass is 0.
  list parts in pts.
  for part in pts {
    set dry_mass to dry_mass + part:drymass.
    set current_mass to current_mass + part:mass.
  }
  list engines in ens.
  for en in ens {
    if en:ignition = true and en:flameout = False {
      if pressure = -1 { return ln(current_mass/dry_mass)*9.807*en:isp. }
      else { return ln(current_mass/dry_mass)*9.807*en:ispat(pressure). }
      // FUTURE Actually determine cluster isp
    }
  }
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
  NOTIFY("Maneuver autopilot initiated").

  until False {
    terminalinput:clear().
    if (terminal:input:haschar) {
      local input is terminal:input:GetChar().
      if input = terminal:input:enter {
        NOTIFY("Executing maneuver").
        MNV_EXEC_NODE(TRUE).
        NOTIFY("Done").
      }
      else if input = terminal:input:backspace {
        NOTIFY("Maneuver autopilot terminated").
        break.
      }
    }
    wait 0.1.
  }
}

Notify("Main function load successful.").
