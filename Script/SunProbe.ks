//SunProbe.ks

FUNCTION MISSION {
    REQUIRE("lib_launch.ks").
    REQUIRE("lib_maneuver.ks").

    LAUNCH(90, 35000000, TRUE).


}

if ship:altitude < 70000 {

    copy lib_launch.ks from 0.

    MISSION().
    AUTOPILOT().

}

else {
  AUTOPILOT().
}
