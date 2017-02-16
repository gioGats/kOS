// boot_manual.ks
// series of scrips for the Gemini Survey Missions

// script for Gemini-2

FUNCTION MISSION {
    run lib_launch.ks.
    run lib_maneuver.ks.
    run lib_orbit.ks.

    LAUNCH(0, 251000, TRUE).
    RAISE_PE(251000).
    MNV_EXEC_NODE(TRUE).
}

if ship:altitude < 70000 {

    copy lib_launch.ks from 0.
    copy lib_maneuver.ks from 0.
    copy lib_orbit.ks from 0.
    copy lib_general.ks from 0.

    MISSION().
}