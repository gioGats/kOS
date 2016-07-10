// lib_general.ks

FUNCTION GENTLE_STAGE {
    // requires that TVAL be set prior to calling function.
    set previous_throttle to TVAL.
    lock throttle to TVAL.
    set TVAL to 0.
    stage.
    wait 1.
    set TVAL to previous_throttle.
}

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

FUNCTION DOWNLOAD {
    PARAMETER name.

    IF NOT ADDONS:RT:HASCONNECTION(SHIP) {
        NOTIFY("Download failed - No connection").
        }
    
    ELSE {
      IF HAS_FILE(name, 1) {
        DELETE name.
        }
      IF HAS_FILE(name, 0) {
        COPY name FROM 0.
        }
      }
}
    
