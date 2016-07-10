//boot_lib.ks
//Generalized boot script that initializes basic functions, checks for updates, and runs a startup script.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

FUNCTION NOTIFY {
  PARAMETER message.
  HUDTEXT("kOS: " + message, 5, 2, 50, YELLOW, false).
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

FUNCTION UPLOAD {
  PARAMETER name.

  //DELAY(). Function removed.
  IF HAS_FILE(name, 0) {
    SWITCH TO 0. DELETE name. SWITCH TO 1.
  }
  IF HAS_FILE(name, 1) {
    COPY name TO 0.
  }
}

FUNCTION REQUIRE {
  PARAMETER name.

  IF NOT HAS_FILE(name) { DOWNLOAD(name). }
  RENAME name TO "tmp.exec.ks".
  RUN tmp.exec.ks.
  RENAME "tmp.exec.ks" TO name.
}

// THE ACTUAL BOOTUP PROCESS
NOTIFY("Bootup").
SET missionScript TO SHIP:NAME + ".ks".

IF HAS_FILE("mission.ks") {
  DELETE mission.
}
IF HAS_FILE(missionScript) {
    NOTIFY("Mission Script Loaded").
}
ELSE {
    DOWNLOAD(missionScript).
    NOTIFY("Update Downloaded").
}
RENAME missionScript TO "mission.ks".
RUN mission.ks.
