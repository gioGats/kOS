//mini_launch.ks
NOTIFY("Loading Mini_Launch").

SET b TO "r".
FUNCTION M_B {
  PARAMETER a.

  IF b = "r" {
    SET b TO MAXTHRUST.
    RETURN FALSE.
  }

  IF b - MAXTHRUST > 10 {
    IF a {
      STAGE.
    }
    SET b TO "r".
    RETURN TRUE.
  }

  RETURN FALSE.
}

FUNCTION LAUNCH {
    PARAMETER HDG.
    PARAMETER Ap.
    PARAMETER SRB.

    SAS off.
    RCS off.
    lock throttle to 0.
    clearscreen.

    set c to false.
    print "Init Count? RCS: Y".
    until c {
        on RCS {
            set c to true.
            }
        }
    set l_m to 1.
    clearscreen.

    until l_m = 0 {
        if l_m = 1 {
            set tP to 90.
            lock steering to heading(HDG, tP).
            set TVAL to 1.
            lock throttle to TVAL.
            stage.
            if SRB {
                set totalSF to stage:Solidfuel.
                set l_m to 2.
                }
            else {set l_m to 3.}
            }

        else if l_m = 2 {
            set tP to 90-(ALT:RADAR/500).
            set TVAL to 1 - min(1,((10*stage:SolidFuel)/totalSF)).
            if stage:Solidfuel < 5 {
                set TVAL to 1.
                stage.
                wait 1.
                set l_m to 3.
                }
            }

        else if l_m = 3 {
            set tP to max(3, 90 * (1 - ALT:RADAR / 50000)).
            if (SHIP:APOAPSIS > 0.875*Ap) and (SHIP:APOAPSIS < 0.999*Ap) {
                if ALT:RADAR < 60000 {set TVAL to max(0.05, 8*(1-SHIP:APOAPSIS/Ap)).}
                set TVAL to max(0.2, 8*(1-SHIP:APOAPSIS/Ap)).
                }
            else if SHIP:APOAPSIS > Ap {set l_m to 4.}
            else {
                set srfAng to VANG(SHIP:SRFPROGRADE:FOREVECTOR, SHIP:FACING:FOREVECTOR).
                set orbAng to VANG(SHIP:PROGRADE:FOREVECTOR, SHIP:FACING:FOREVECTOR).
                set theta to min(srfAng, orbAng).
                set TVAL to max(0.2, 2 - (constant:e ^ (theta/90))).
                }
            M_B(TRUE).
            if (SHIP:ALTITUDE > 50000) and (VERTICALSPEED > 0) {ag10 on.}
            }

        else if l_m = 4 {
            set tP to 0.
            set TVAL to 0.
            if (SHIP:ALTITUDE > 50000) and (VERTICALSPEED > 0) {
                wait 1.
                ag10 on.
                wait 1.
                }
            if ship:altitude > 70000 {
                ag9 on.
                wait 2.
                set l_m to 0.
}}}}
