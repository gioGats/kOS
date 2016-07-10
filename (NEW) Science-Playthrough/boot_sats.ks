//Boot file for Sats attached to RT2

FUNCTION NOTIFY {
  PARAMETER message.
  HUDTEXT("kOS: " + message, 5, 2, 50, YELLOW, false).
}

if ship:altitude < 70000 {
    COPY lib_maneuver_mini from 0.
    }
set wakeup to false.

print "Hibernating until wake-up protocol initiated.".

set oldName to ship:name.
until wakeup{
	wait 2.
	if ship:name <> oldName {
		set wakeup to true.
	   }
    }

set TVAL to 0.
lock throttle to TVAL.
RUN lib_maneuver_mini.
clearscreen.

set Eng to ship:partsnamed("microEngine")[0].
set EngM1 to Eng:getModule("ModuleEngines").

set Ant to ship:partsnamed("longAntenna")[0].
set AntM to Ant:getModule("ModuleRTAntenna").
AntM:DOEVENT("activate").

set Ant to ship:partsnamed("commDish")[0].
set AntM to Ant:getModule("ModuleRTAntenna").
AntM:DOEVENT("activate").

panels on.

wait 3.
EngM1:DOEVENT("activate engine").
lock steering to prograde.

wait 3.
RAISE_PE(Ship:apoapsis).
MNV_EXEC_NODE(false).

wait 2.
lock steering to -1*UP.
sas on.
NOTIFY("Insertion Complete").