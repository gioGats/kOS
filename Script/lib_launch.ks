//lib_launch.ks
//Launches craft with 0 inclination to the specified apoapsis.
//Standardized AG Config
NOTIFY("Loading lib_launch").

SET burnoutCheck TO "reset".
FUNCTION LOCAL_MNV_BURNOUT {
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

FUNCTION LAUNCH {
    PARAMETER HDG.
    PARAMETER Ap.
    PARAMETER SRB.

    //Intial Configuration
    SAS off.
    RCS off.
    lock throttle to 0.
    clearscreen.

    set continue to false.
    print "Initiate Countdown? Activate RCS to Confirm.".
    until continue { on RCS { set continue to true. }}

    wait 1.
    NOTIFY("3...").
    wait 1.
    NOTIFY("2...").
    wait 1.
    NOTIFY("1...").
    wait 1.
    set launch_runmode to 1.
    clearscreen.

    until launch_runmode = 0 {
        if launch_runmode = 1 { //On the pad
            set targetPitch to 90.
            lock steering to heading(HDG, targetPitch).
            set TVAL to 1.
            lock throttle to TVAL.
            stage.
            if SRB {
                set totalSF to stage:Solidfuel.
                set launch_runmode to 2.
                }
            else {set launch_runmode to 3.}
            }

        else if launch_runmode = 2 { //SRB Stage
            set targetPitch to 90-(ALT:RADAR/500).
            set TVAL to 1 - min(1,((10*stage:SolidFuel)/totalSF)).
            if stage:Solidfuel < 5 {
                set TVAL to 1.
                stage.
                wait 1.
                set launch_runmode to 3.
                }
            }

        else if launch_runmode = 3 { //Gravity Turn
            set targetPitch to max(3, 90 * (1 - ALT:RADAR / 50000)).
            if (SHIP:APOAPSIS > 0.875*Ap) and (SHIP:APOAPSIS < 0.999*Ap) {
                if ALT:RADAR < 60000 {
                    set TVAL to max(0.05, 8*(1-SHIP:APOAPSIS/Ap)).
                    }
                set TVAL to max(0.2, 8*(1-SHIP:APOAPSIS/Ap)).
                }
            else if SHIP:APOAPSIS > Ap {
                set launch_runmode to 4.
                }
            else {
                set srfAng to VANG(SHIP:SRFPROGRADE:FOREVECTOR, SHIP:FACING:FOREVECTOR).
                set orbAng to VANG(SHIP:PROGRADE:FOREVECTOR, SHIP:FACING:FOREVECTOR).
                set theta to min(srfAng, orbAng).
                set TVAL to max(0.2, 2 - (constant:e ^ (theta/90))).
                }
            LOCAL_MNV_BURNOUT(TRUE).
            if (SHIP:ALTITUDE > 50000) and (VERTICALSPEED > 0) {
                ag10 on. //Deploy fairings, if any
                }
            }

        else if launch_runmode = 4 { //Coast to Ap
            set targetPitch to 0.
            set TVAL to 0.
            if (SHIP:ALTITUDE > 50000) and (VERTICALSPEED > 0) {
                wait 1.
                ag10 on. //Deploy fairings, if any
                wait 1.
                }
            if ship:altitude > 70000 {
                ag9 on. //Deploy primary antenna, if any
                wait 2.
                set launch_runmode to 0.
                }
            }
            print "ALTITUDE:   " + round(SHIP:ALTITUDE) + "      " at (5,4).
            print "APOAPSIS:   " + round(SHIP:APOAPSIS) + "      " at (5,5).
            print "PERIAPSIS:  " + round(SHIP:PERIAPSIS) + "      " at (5,6).
            print "ETA - AP:  " + round(ETA:APOAPSIS) + "      " at (5,7).
            print "TVALL       " + round(TVAL,2) + "      " at (5,8).
            print "PITCH:   " + round(targetPitch) + "      " at (5,9).
            print "LMODE:   " + launch_runmode + "      " at (5,10).
        }
    clearscreen.
    }
