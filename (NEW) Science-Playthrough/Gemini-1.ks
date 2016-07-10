// boot_manual.ks
// series of scrips for the Gemini Survey Missions

// script for Gemini-1

FUNCTION MISSION {
    run lib_launch.ks.
    run lib_maneuver.ks.
    run lib_orbit.ks.

    LAUNCH(0, 80000, TRUE).
    RAISE_PE(80000).
    MNV_EXEC_NODE(TRUE).
    
    SET p TO SHIP:PARTSTITLED("Comms DTS-M1")[0].
    SET m TO p:GETMODULE("ModuleRTAntenna").
    m:DOEVENT("Activate").
    m:SETFIELD("target", "Kerbin").

    lock steering to heading(90,90).

    set phase to TARGET_ANGLE("Mun").
    UNTIL ISH(phase, 135, 0.5) {
        set phase to TARGET_ANGLE("Mun").
        print "PHASE ANGLE:  " + TARGET_ANGLE("Mun") + "     " at (5,4).
        if abs(phase - 135) < 5 { set warp to 0. lock steering to prograde.} 
        else if abs(phase-135) < 10 { set warp to 1. }
        else if abs(phase-135) < 15 { set warp to 2.}
        else  { set warp to 3. }
    }

    // Munar Transfer
    SET forward TO PROGRADE.
    LOCK STEERING TO forward.
    LOCK THROTTLE TO 1.
    UNTIL APOAPSIS > 0.95*BODY("Mun"):APOAPSIS {MNV_BURNOUT(TRUE).}
    LOCK THROTTLE TO 0.5.
    WAIT UNTIL SHIP:ORBIT:HASNEXTPATCH.
    LOCK THROTTLE TO 0.
    WAIT 1.
    UNLOCK STEERING.
    PRINT "We choose to go to the Mun".

    // Wait until we're near the mun
    WAIT 10.
    WARPTO(TIME:SECONDS + ETA:TRANSITION - 20).
    WAIT UNTIL SHIP:OBT:BODY:NAME <> "Kerbin".
    PRINT "Entered Mun's sphere of influence.".
    
    gear on.
}

if ship:altitude < 70000 {

    copy lib_launch.ks from 0.
    copy lib_maneuver.ks from 0.
    copy lib_orbit.ks from 0.
    copy lib_general.ks from 0.

    MISSION().
}

else if SHIP:OBT:BODY:NAME <> "Kerbin" {
    WARPTO(TIME:SECONDS + ETA:PERIAPSIS - 30).
    LOCK STEERING TO RETROGRADE.
    WAIT 5.
    LOCK THROTTLE TO 1.
    WAIT UNTIL (APOAPSIS > 0) AND (APOAPSIS < (MUN:SOIRADIUS - MUN:RADIUS - 20000)).
    LOCK THROTTLE TO 0.
    PRINT "We're in orbit!".
    
    LOCK THROTTLE TO 0.5.
    WAIT UNTIL SHIP:PERIAPSIS < 35000.
    LOCK THROTTLE TO 0.
    
    WARPTO(TIME:SECONDS + ETA:PERIAPSIS - 30).
    
    gear on.
}
    
else {
    run lib_maneuver.ks.

    NOTIFY("Maneuver autopilot initiated").
    wait 2.
    NOTIFY("RCS: Execute Maneuver. Brakes: Done").

    SET done to FALSE.
    ON BRAKES  { SET done to TRUE. }

    SET rcsState TO RCS.
    UNTIL done {
      IF RCS <> rcsState {
        SET rcsState TO RCS.
        NOTIFY("Executing maneuver").
        MNV_EXEC_NODE(TRUE).
        NOTIFY("Done").
      }
      WAIT 0.1.
    }

    NOTIFY("Maneuver autopilot terminated").
}