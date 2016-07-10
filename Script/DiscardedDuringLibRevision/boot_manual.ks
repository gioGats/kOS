// boot_manual.ks

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

FUNCTION HAS_FILE {
  PARAMETER name.
  LIST FILES IN allFiles.
  FOR file IN allFiles {
    IF file:NAME = name {
      RETURN TRUE.
    }
  }
  RETURN FALSE.
}

FUNCTION DOWNLOAD {
    PARAMETER name.

    IF NOT ADDONS:RT:HASCONNECTION(SHIP) {
        NOTIFY("Download failed - No connection").
        }
    
    ELSE {
      IF HAS_FILE(name) {
        DELETE name.
        }
      COPY name FROM 0.
      }
}

// THE ACTUAL BOOTUP PROCESS
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
NOTIFY("Bootup").
SET missionScript TO SHIP:NAME + ".ks".
IF HAS_FILE(missionScript) {
    NOTIFY("Mission Script Loaded").
}
ELSE {
    DOWNLOAD(missionScript).
    NOTIFY("Update Downloaded").
}
RENAME missionScript TO "mission.ks".
RUN mission.ks.