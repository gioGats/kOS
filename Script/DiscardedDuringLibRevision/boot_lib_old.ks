//boot_lib.ks
//Generalized boot script that initializes basic functions, checks for updates, and runs a startup script.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.



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

  IF NOT HAS_FILE(name, 1) { DOWNLOAD(name). }
  RENAME name TO "tmp.exec.ks".
  RUN tmp.exec.ks.
  RENAME "tmp.exec.ks" TO name.
}

// THE ACTUAL BOOTUP PROCESS
PRINT "Bootup".
SET updateScript TO SHIP:NAME + ".update.ks".

IF ADDONS:RT:HASCONNECTION(SHIP) {
    PRINT "Updating".
  IF HAS_FILE(updateScript, 0) {
    DOWNLOAD(updateScript).
    NOTIFY("Update Downloaded").
    IF HAS_FILE("update.ks", 1) {
      DELETE update.ks.
    }
    RENAME updateScript TO "update.ks".
    RUN update.ks.
    DELETE update.ks.
  }
}