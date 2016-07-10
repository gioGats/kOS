// boot_manual.ks

// script for Atlas-2, High Communications Cluster

// Mission notations from Sage
// Launch to 3.6mm
// Raise Pe to 2.13mm
// (Raise Pe burn from 3.6mm x 0 orbit to 3.6mm x 2.13mm estimated at 356 m/s)
// Insert each CommSat and circularize, estimated at 103 m/s

FUNCTION MISSION {
    run lib_launch.ks.
    run lib_maneuver.ks.
    run lib_orbit.ks.

    LAUNCH(90, 3600000, TRUE).
    RAISE_PE(2134040).
    MNV_EXEC_NODE(TRUE).
}

FUNCTION PICK_A_SAT {
    local x is 0.
    until false {
        if x > 1 {
            return x.
        }
        else if releases[x] = false {
            break.
        }
        set x to x+1.
    }
    return x.
}

FUNCTION RELEASE {
    PARAMETER x.

    set sat_name to sats[x].

    set sat to ship:partstagged(sat_name)[0].
    set satM to sat:getModule("ModuleDecouple").

    WARPTO(time:seconds + (eta:apoapsis - 70)).

    lock steering to ship:prograde.

    until false {
        if ETA:Apoapsis < 60 {
            satM:DOEVENT("decouple").
            set releases[x] to true.
            break.
        }
    }
    local x is 0.
    until x > 120 {
        print 120-x.
        wait 1.
        set x to x+1.
    }
}

if ship:altitude < 70000 {

    copy lib_launch.ks from 0.
    copy lib_maneuver.ks from 0.
    copy lib_orbit.ks from 0.
    copy lib_general.ks from 0.

    set sats to LIST("sat1", "sat2").
    set releases to LIST(false, false).

    MISSION().
    until PICK_A_SAT() > 7 {
        RELEASE(PICK_A_SAT()).
    }
    WARPTO(time:seconds + (eta:apoapsis - 20)).
    lock steering to ship:retrograde.
    lock throttle to 1.
}