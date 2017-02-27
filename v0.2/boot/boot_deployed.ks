//boot_deployed.ks
clearscreen.

if not exists(core:volume:name + ":/lib/main.ks") {COPYPATH("0:/lib/main.ks", core:volume:name + ":/lib/main.ks").}
runoncepath(core:volume:name + ":/lib/main.ks").

local mission_script is "/missions/" + core:tag.
local mission_success is Require(mission_script, True).

print "Enter boot preference: " at (5,9).
if mission_success {print "1 - Mission Script" at (5,5).}
else {print "1 - Mission Script NOT AVAILABLE" at (5,5).}
print "2 - Maneuver Autopilot" at (5,6).
print "3 - Terminal" at (5,7).
print "4 - Shutdown" at (5,8).

until False {
  terminal:input:clear().
  if (terminal:input:haschar) {
    set input to terminal:input:getchar().
    if input = "1" {Mission().}
    else if input = "2" {Autopilot().}
    else if input = "3" {return.}
    else if input = "4" {shutdown.}
    else {print "Invalid input, enter again." at (5,9).}
  }
  wait 0.1.
}
