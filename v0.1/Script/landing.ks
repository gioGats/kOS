//Generalized Landing Script
//

NOTIFY("Beginning landing script").

RUN lib_maneuver.ks.
RUN lib_pid.ks.
RUN lib_orbit.ks.

set margin to 100.

FUNCTION UPWARD {
  IF SHIP:VERTICALSPEED < 0 {
    RETURN SRFRETROGRADE.
  } ELSE {
    RETURN HEADING(90, 90).
  }
}

IF SHIP:PERIAPSIS > 10000 {
    NOTIFY("PERIAPSIS TOO HIGH, ADJUSTING").
    IF ETA:PERIAPSIS > 90 {
        WARPTO(TIME:SECONDS + ETA:PERIAPSIS - 60).
        }
    LOCK STEERING TO RETROGRADE.
    wait 5.
    LOCK THROTTLE TO 1.
    WAIT UNTIL SHIP:PERIAPSIS < 0.
    LOCK THROTTLE TO 0.
    }

set landing_mode to 1.
set mode to "Initial descent phase".
NOTIFY(mode).
clearscreen.
set northPole to latlng(90,0).
set msg to "".

until landing_mode = 0 {
    set hdg to mod(360 - northPole:bearing,360).
    if landing_mode = 1 {
        If ALT:RADAR > 51000 {
            SET WARP TO 3.
            WAIT UNTIL ALT:RADAR < 51000.
            SET WARP TO 0.
            }
        ELSE IF ALT:RADAR < 50000 AND ALT:RADAR > 15000 {
            set msg to "Entering low orbit".
            lock steering to UPWARD().
            SET WARP TO 3.
            WAIT UNTIL ALT:RADAR < 15000.
            SET WARP TO 0.
            }
        ELSE IF ALT:RADAR < 10000 {
            set mode to "Initial horizontal burn".
            NOTIFY(mode).
            set landing_mode to 2.
            }
        }
        
    else if landing_mode = 2 {
        if 0.5*TLM_TTI(margin) <= MNV_TIME(ABS(SHIP:GROUNDSPEED)) {
            lock steering to heading(hdg,0).
            lock throttle to 1.
            wait until ship:groundspeed < 10.
            lock throttle to 0.
            set landing_mode to 3.
            set mode to "Initial suicide burn".
            NOTIFY(mode).
            set msg to "Beginning approach".
            GEAR OFF. WAIT 1. GEAR ON.
            Panels off.
            }
        }
    
    else if landing_mode = 3 { 
        lock steering to UPWARD().
        if TLM_TTI(margin) <= MNV_TIME(ABS(SHIP:VERTICALSPEED)) {
            lock throttle to 1.
            wait until ship:verticalspeed > -20.
            lock throttle to 0.
            set mode to "Final horizontal burn".
            NOTIFY(mode).
            set landing_mode to 4.
            }
        }
    
    else if landing_mode = 4 { 
        if abs(ship:groundspeed) > 5 {
            lock steering to heading(hdg,0).
            lock throttle to 0.5.
            wait until abs(ship:groundspeed) < 5.
            lock throttle to 0.
            }
        SET hoverPID TO PID_init(0.05, 0.005, 0.01, 0, 1).
        SET pidThrottle TO 0.
        LOCK THROTTLE TO pidThrottle.
        SET targetDescent to -20.
        set landing_mode to 5.
        set mode to "Final descent over terrain".
        NOTIFY(mode).
        }
    
    else if landing_mode = 5 {
        SET pidThrottle TO PID_seek(hoverPID, targetDescent, SHIP:VERTICALSPEED).
        if ALT:RADAR < 100 AND ALT:RADAR > 20{
            set targetDescent to -5.
            }
        else if ALT:RADAR < 20 {
            set targetDescent to -2.
            LOCK STEETING TO HEADING(90,90).
            }
        if SHIP:STATUS = "Landed" {
            set pidThrottle to 0.
            lock throttle to 0.
            unlock steering.
            set landing_mode to 6.
            set mode to "Ship landed".
            NOTIFY(mode). 
            }
        }
    
    else if landing_mode = 6 {
        Panels on.
        set landing_mode to 0.
        }
    if landing_mode < 5 and landing_mode <> 0{
        print "TLM_TTI:    " + round(TLM_TTI(margin),2) + "      " at (5,8). 
        print "VERT_TIME:  " + round(MNV_TIME(ABS(SHIP:VERTICALSPEED)),2) + "      " at (5,9).
        print "TLM_TTI(2): " + round(0.5*TLM_TTI(margin),2) + "      " at (5,10).
        print "HORZ_TIME:  " + round(MNV_TIME(ABS(SHIP:GROUNDSPEED)),2) + "      " at (5,11).
        }
    print "ALTITUDE:   " + round(ALT:RADAR) + "      " at (5,4).
    print "VSPEED:     " + round(SHIP:VERTICALSPEED,2) + "      " at (5,5).
    print "GSPEED:     " + round(SHIP:GROUNDSPEED,2) + "      " at (5,6).
    print "HDG:        " + round(hdg) + "      " at (5,7).
    print "MODE:       " + mode + "      " at (5,12).
    print "MSG:        " + msg + "      " at (5,13).
    }