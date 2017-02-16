//boot_lib.ks
//Generalized boot script that initializes basic functions, checks for updates, and runs a startup script.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

FUNCTION NOTIFY {
  PARAMETER message.
  HUDTEXT("kOS: " + message, 5, 2, 50, YELLOW, false).
}

FUNCTION ISH {
  PARAMETER a.
  PARAMETER b.
  PARAMETER ishyiness.

  RETURN a - ishyiness < b AND a + ishyiness > b.
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

// THE ACTUAL BOOTUP PROCESS
NOTIFY("Bootup").

IF NOT ADDONS:RT:HASCONNECTION(SHIP) {
  NOTIFY("Download failed - No connection").
}
ELSE {
  if exists("mission.ks") delete "mission.ks".
  local missionScript is SHIP:NAME + ".ks".
  if not exists(missionScript) {
    copy missionScript from 0.
    NOTIFY("Mission Script Downloaded").
  }
  RENAME missionScript TO "mission.ks".
  NOTIFY("Mission Script Loaded").
  RUN mission.ks.
}
