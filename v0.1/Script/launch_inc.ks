//launch_inc.ks
//Launches craft into the target's orbital plane to specified apoapsis.
//Standardized AG Config
NOTIFY("Loading launch_inc").

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

FUNCTION INC_LAUNCH {
  PARAMETER tgt.
  PARAMETER Ap.
  PARAMETER SRB.
  wait 1.
  set Target to Orbitable(TGT).
  wait 1.
  SAS off.
  RCS off.
  lock throttle to 0.
  clearscreen.

  set l_m to -1.

  SET PID_array TO PID_init(4, 0.033, 0.005, -60, 60).
  set pidHeading to 0.
  set targetPitch to 90.
  set hdg to 90.
  lock steering to heading(HDG, targetPitch).
  set TVAL to 1.
  lock throttle to TVAL.

  until l_m = 0 {
    if l_m > 1 {
      set vec_n to VCRS(Target:Prograde:Vector, Target:Up:Vector).
      set current_angle to VANG(Ship:Prograde:Vector,vec_n).
      set pidHeading to PID_seek(PID_array, 90, current_angle).
      set HDG to 90 + pidHeading.
    }

    if l_m = -1 {
      set vec_n to VCRS(Target:Prograde:Vector, Target:Up:Vector).
      set current_angle to VANG(Ship:UP:Vector,vec_n).
      if abs(current_angle - 90) < 0.01 { set l_m to 1.}
      else if abs(current_angle - 90) < 0.03 { set warp to 0. }
      else if abs(current_angle-90) < 0.1 { set warp to 3. }
      else if abs(current_angle-90) < 0.5 { set warp to 4.}
      else if abs(current_angle-90) < 10 { set warp to 5.}
      else  { set warp to 6. }
      }

    else if l_m = 1 {
      wait 0.01.
      stage.
      if SRB {
          set totalSF to stage:Solidfuel.
          set l_m to 2.
      }
      else {set l_m to 3.}
    }

    else if l_m = 2 { //SRB Stage
      set targetPitch to 90-(ALT:RADAR/500).
      set TVAL to 1 - min(1,((10*stage:SolidFuel)/totalSF)).
      if stage:Solidfuel < 5 {
        set TVAL to 1.
        stage.
        wait 1.
        set l_m to 3.
      }
    }
    else if l_m = 3 { //Gravity Turn
      set targetPitch to max(3, 90 * (1 - ALT:RADAR / 50000)).
      if (SHIP:APOAPSIS > 0.875*Ap) and (SHIP:APOAPSIS < 0.999*Ap) {
        if ALT:RADAR < 60000 {
          set TVAL to max(0.05, 8*(1-SHIP:APOAPSIS/Ap)).
        }
        set TVAL to max(0.2, 8*(1-SHIP:APOAPSIS/Ap)).
      }
      else if SHIP:APOAPSIS > Ap { set l_m to 4. }
      else {
        set srfAng to VANG(SHIP:SRFPROGRADE:FOREVECTOR, SHIP:FACING:FOREVECTOR).
        set orbAng to VANG(SHIP:PROGRADE:FOREVECTOR, SHIP:FACING:FOREVECTOR).
        set theta to min(srfAng, orbAng).
        set TVAL to max(0.2, 2 - (constant:e ^ (theta/90))).
      }
      LOCAL_MNV_BURNOUT(TRUE).
      if (SHIP:ALTITUDE > 50000) and (VERTICALSPEED > 0) { ag10 on. } //Deploy fairings, if any
    }

    else if l_m = 4 { //Coast to Ap
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
        set l_m to 0.
      }
    }
    print "TVALL:   " + round(TVAL,2) at (5,8).
    print "PITCH:   " + round(targetPitch) at (5,9).
    print "HDG:     " + round(HDG, 2) at (5,10).
    print "VANG:    " + round(current_angle, 2) at (5,11).
    print "LMODE:   " + l_m at (5,12).
  }
clearscreen.
}
