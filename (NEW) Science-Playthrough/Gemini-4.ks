// boot_manual.ks
// series of scrips for the Gemini Survey Missions

// script for Gemini-3

FUNCTION MISSION {
    REQUIRE("mini_launch.ks").

    LAUNCH(0, 350000, TRUE).
}

if ship:altitude < 70000 {
    MISSION().
}
