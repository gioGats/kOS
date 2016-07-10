// boot_manual.ks

// script for Atlas-1, Low Communications Cluster

// Mission notations from Sage
// Launch to 2.35mm
// Raise Pe to 1.847476mm
// (Raise Pe burn from 2.35mm x 0 orbit to 2.35mm x 1.85mm estimated at 406 m/s)
// Insert each CommSat and circularize, estimated at 53 m/s

FUNCTION MISSION {
    run lib_launch.ks.
    run lib_maneuver.ks.
    run lib_orbit.ks.

    LAUNCH(90, 2350000, TRUE).
    RAISE_PE(1847476).
    MNV_EXEC_NODE(TRUE).
}

FUNCTION PICK_A_SAT {
    local x is 0.
    until false {
        if x > 7 {
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
    NOTIFY("Release" + sat_name).

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

    set sats to LIST("sat1", "sat2", "sat3", "sat4", "sat5", "sat6", "sat7", "sat8").
    set releases to LIST(false, false, false, false, false, false, false, false).

    MISSION().
    until PICK_A_SAT() > 7 {
        RELEASE(PICK_A_SAT()).
    }
    WARPTO(time:seconds + (eta:apoapsis - 20)).
    lock steering to ship:retrograde.
    lock throttle to 1.
}

else {

    until PICK_A_SAT() > 7 {
        RELEASE(PICK_A_SAT()).
    }
    WARPTO(time:seconds + (eta:apoapsis - 20)).
    lock steering to ship:retrograde.
    lock throttle to 1.
}